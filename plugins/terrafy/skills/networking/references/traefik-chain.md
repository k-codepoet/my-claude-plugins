# Traefik Chain Architecture

> 외부/내부 모두 Mac Mini가 진입점. ACME TLS 종료 후 체인.

## 핵심 구조

```
외부 트래픽 (*.codepoet.site):
  Internet → Cloudflare → cloudflared (NAS에서 실행)
           → Mac Mini Traefik (:80/443) [진입점, ACME TLS]
           → NAS Traefik (:8880) → Linux Traefik (:80) → 404

내부 트래픽 (*.home.codepoet.site):
  Split DNS → Mac Mini Tailscale IP (100.108.195.20)
            → Mac Mini Traefik (:443) [TLS 종료]
            → NAS Traefik (:8880, HTTP)
            → Linux Traefik (:80) → 404
```

**핵심 포인트:**
- **외부/내부 모두 Mac Mini가 진입점** (Split DNS도 Mac Mini로 해석됨)
- ACME 인증서(`*.codepoet.site`, `*.home.codepoet.site`)는 Mac Mini에서 중앙 관리
- Mac Mini에서 TLS 종료 → 이후 체인은 전부 HTTP
- NAS/Linux Traefik은 인증서 관리 없음

## HTTPS 트래픽 흐름 (중요)

모든 `*.home.codepoet.site` HTTPS 트래픽은 동일 경로를 따릅니다:

```
Client (HTTPS)
  → Split DNS: *.home.codepoet.site → 100.108.195.20 (Mac Mini Tailscale)
  → Mac Mini Traefik :443
     ├─ TLS 종료 (ACME *.home.codepoet.site 와일드카드 인증서)
     ├─ Host 매칭: grafana.home, n8n.home 등 → Mac Mini 로컬 서비스
     └─ No match → chain-to-nas-secure (HTTP로 NAS에 전달)
         → NAS Traefik :8880 (HTTP)
            ├─ Host 매칭: gitlab.home, gitlab-registry.home 등 → NAS 서비스
            └─ No match → Linux Traefik :80 → 404
```

**NAS 서비스(GitLab 등)가 HTTPS로 동작하기 위한 조건:**
- `external_url`에 `https://` 사용
- 내부 nginx는 HTTP 유지: `nginx['listen_https'] = false`
- `X-Forwarded-Proto: https` 헤더 전달 (프록시 뒤에 있음을 인식)
- 이렇게 하면 서비스가 생성하는 URL(redirect, JWT realm 등)이 `https://`로 나옴

이 패턴을 따르지 않으면 (예: `external_url`이 `http://`인 경우):
- Docker registry JWT realm이 `http://`로 응답 → Docker client가 HTTPS→HTTP 다운그레이드 거부
- 브라우저에서 mixed content 경고 발생 가능

## 체인 노드별 역할

| 노드 | 역할 | 포트 | 네트워크 | TLS |
|------|------|------|----------|-----|
| **Mac Mini** (.48) | 진입점 (외부+내부), ACME, TCP 포워딩 | 80, 443, 20022 | `traefik` | 종료 |
| **NAS** (.14) | Chain Node | 8880 | `gateway` | 없음 (HTTP) |
| **Linux** (.34) | Chain Node, 404 fallback | 80 | `traefik` | 없음 (HTTP) |

## TCP 포워딩 (non-HTTP)

HTTP 체인과 별도로, Mac Mini Traefik은 TCP 포워딩도 처리합니다:

```
GitLab SSH:
  Client → Mac Mini:20022 (TCP entryPoint)
         → NAS:20022 (TCP loadBalancer)
         → GitLab Container:22
```

TCP 트래픽은 체인을 타지 않고 Mac Mini에서 대상 서버로 직접 포워딩됩니다.

## 각 노드 설정

### Mac Mini Traefik (진입점)

```yaml
# infra/codepoet-mac-mini-1/traefik/docker-compose.yml
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"
  gitlab-ssh:
    address: ":20022"

# ACME 인증서 (Cloudflare DNS Challenge)
certificatesResolvers:
  cloudflare:
    acme:
      email: ...
      dnsChallenge:
        provider: cloudflare

# HTTPS Fallback to NAS
http:
  routers:
    chain-to-nas-secure:
      rule: "HostRegexp(`.*`)"
      priority: 1
      entryPoints: [websecure]
      service: nas-traefik
      tls:
        certResolver: cloudflare
        domains:
          - main: "codepoet.site"
            sans: ["*.codepoet.site"]
          - main: "home.codepoet.site"
            sans: ["*.home.codepoet.site"]

    # HTTP Fallback to NAS
    chain-to-nas:
      rule: "HostRegexp(`.*`)"
      priority: 1
      entryPoints: [web]
      service: nas-traefik

  services:
    nas-traefik:
      loadBalancer:
        servers:
          - url: "http://192.168.0.14:8880"

# TCP Forwarding (GitLab SSH)
tcp:
  routers:
    gitlab-ssh:
      entryPoints: [gitlab-ssh]
      rule: "HostSNI(`*`)"
      service: gitlab-ssh-svc
  services:
    gitlab-ssh-svc:
      loadBalancer:
        servers:
          - address: "192.168.0.14:20022"
```

### NAS Traefik (Chain Node)

```yaml
# infra/codepoet-nas/traefik/docker-compose.yml
entryPoints:
  web:
    address: ":80"  # 컨테이너 내부

ports:
  - "8880:80"  # DSM이 80/443 점유

# Fallback to Linux
http:
  routers:
    chain-to-linux:
      rule: "HostRegexp(`.*`)"
      priority: 1
      service: linux-traefik
  services:
    linux-traefik:
      loadBalancer:
        servers:
          - url: "http://192.168.0.34:80"
```

### Linux Traefik (404 Fallback)

```yaml
# infra/codepoet-linux-1/traefik/docker-compose.yml
entryPoints:
  web:
    address: ":80"

# 404 Fallback
http:
  routers:
    fallback-404:
      rule: "PathPrefix(`/`)"
      priority: 1
      service: fallback-404-svc
```

## NAS 서비스 HTTPS 패턴

NAS에서 서비스를 HTTPS로 제공하는 표준 패턴:

```yaml
# docker-compose.yml (NAS 서비스)
services:
  myservice:
    environment:
      # external_url은 https:// (클라이언트가 보는 URL)
      EXTERNAL_URL: 'https://myservice.home.codepoet.site'
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myservice.rule=Host(`myservice.home.codepoet.site`)"
      - "traefik.http.routers.myservice.entrypoints=web"
      - "traefik.http.services.myservice.loadbalancer.server.port=8080"
    networks:
      - gateway
```

**원칙:**
1. 서비스의 `external_url`/공개 URL은 `https://` 사용
2. 서비스 내부는 HTTP로 동작 (TLS 없음)
3. `X-Forwarded-Proto: https` 헤더 전달 (리버스 프록시 뒤에 있음을 인식)
4. Traefik labels의 entrypoints는 `web` (NAS Traefik은 HTTP만)
5. TLS는 Mac Mini Traefik이 일괄 처리

## 서비스 추가 방법

서비스를 배치할 노드에서 Traefik labels만 추가하면 자동 라우팅됩니다.

### Mac Mini 서비스

```yaml
services:
  myservice:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myservice.rule=Host(`myservice.codepoet.site`)"
      - "traefik.http.services.myservice.loadbalancer.server.port=8080"
    networks:
      - traefik
```

### NAS 서비스

```yaml
services:
  myservice:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myservice.rule=Host(`myservice.home.codepoet.site`)"
      - "traefik.http.services.myservice.loadbalancer.server.port=8080"
    networks:
      - gateway  # NAS는 gateway 네트워크 사용
```

## 우선순위 (Priority)

- **Priority 100**: Dashboard 라우터
- **Priority 10+**: Docker Provider 자동 발견 서비스 (기본값)
- **Priority 1**: 체이닝 라우터 (fallback)

높은 priority가 먼저 매칭되므로, 로컬 서비스가 우선 처리됩니다.

## 네트워크

| 노드 | 네트워크 이름 | 이유 |
|------|--------------|------|
| Mac Mini | `traefik` | 표준 |
| NAS | `gateway` | DSM 환경 분리 |
| Linux | `traefik` | 표준 |

## 관련 파일

- `infra/codepoet-mac-mini-1/traefik/docker-compose.yml`
- `infra/codepoet-nas/traefik/docker-compose.yml`
- `infra/codepoet-linux-1/traefik/docker-compose.yml`
- `infra/codepoet-nas/cloudflared/docker-compose.yml`
