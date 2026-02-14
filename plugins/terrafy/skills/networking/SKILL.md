---
name: networking
description: Traefik, DNS, 라우팅, Cloudflare, tunnel, TLS, 체인, 인증서, 네트워크, ingress, nginx 관련 작업
allowed-tools: Bash, Read, Write
---

# Network & Ingress Patterns

서비스 트래픽을 외부/내부로 라우팅하는 네트워크 구성 패턴.

## Ingress Backends

| Backend | 상태 | 설명 |
|---------|------|------|
| **Traefik Reverse Proxy Chain** | 현재 사용 | Docker Compose + Traefik labels |
| k8s Ingress Controller | 확장 예정 | k3s/k8s 전환 시 |
| Service Mesh (Istio 등) | 확장 예정 | mTLS, observability |

## Core Patterns (범용)

backend에 무관하게 적용되는 네트워크 설계 패턴.

### 1. Reverse Proxy Chain

복수의 프록시 노드가 순차적으로 트래픽을 전달하는 패턴:

```
Entry Point (TLS 종료)
  → Node A (Host 매칭 → 로컬 서비스 처리)
  → No match → Node B (Host 매칭 → 로컬 서비스 처리)
  → No match → ... → Final Node (404 fallback)
```

- **진입점**은 하나만 유지 — TLS 인증서 중앙 관리
- 체인 내부는 HTTP (TLS 종료 이후)
- 각 노드는 자기 로컬 서비스만 처리, 나머지는 다음 노드로 전달
- 우선순위(priority)로 로컬 서비스 > 체인 fallback 보장

### 2. Split DNS

내부/외부 접속 경로를 도메인 패턴으로 분리:

```
외부 (*.{DOMAIN}):
  Public DNS → Tunnel/CDN → Entry Point → 서비스

내부 (*.{INTERNAL_SUBDOMAIN}.{DOMAIN}):
  Internal DNS → VPN/Tailscale → Entry Point (TLS) → 서비스
```

- 내부 도메인은 VPN DNS resolver를 통해 진입점 IP로 해석
- 외부/내부 모두 동일한 진입점에서 TLS 종료 → HTTPS 일관성 유지
- LAN 전용 기기를 위한 DNS rewrite (예: AdGuard) 설정 가능

### 3. TLS Termination at Edge

인증서 관리를 단일 진입점에 집중:

```
Client (HTTPS) → Edge Proxy (ACME 인증서, TLS 종료) → 내부 HTTP
```

- ACME 와일드카드 인증서를 진입점 하나에서 관리
- 내부 노드는 인증서 관리 불필요 — HTTP만 처리
- DNS Challenge (예: Cloudflare) 사용 시 80/443 포트 개방 불필요

### 4. Service HTTPS Proxy

서비스가 HTTPS URL을 외부에 발행하지만, 실제 내부 트래픽은 HTTP인 패턴:

```yaml
# 서비스 설정
external_url: "https://{SERVICE}.{DOMAIN}"    # 외부에 발행하는 URL
nginx_listen_https: false                       # 내부는 HTTP
trusted_proxies: ["{PROXY_IP}"]

# 리버스 프록시 → 서비스
X-Forwarded-Proto: https    # 프록시가 헤더 삽입
```

- `external_url`을 `https://`로 설정 → redirect, JWT realm, callback URL 모두 HTTPS
- 내부 nginx/서비스는 HTTP 유지 (TLS는 Edge에서 종료됨)
- `X-Forwarded-Proto: https` 헤더로 프록시 뒤에 있음을 인식
- 이 패턴을 따르지 않으면 JWT auth realm HTTP 다운그레이드, mixed content 등 발생

## Current Implementation: Traefik Chain + Cloudflare Tunnel + Split DNS

### Chain Topology

```
외부 (*.{DOMAIN}):
  Internet → Cloudflare → cloudflared ({TUNNEL_DEVICE})
           → Entry Point Traefik ({ENTRY_DEVICE}:443, ACME TLS 종료)
           → Chain Node Traefik ({CHAIN_NODE}:HTTP) → ... → 404 fallback

내부 (*.{INTERNAL_SUBDOMAIN}.{DOMAIN}):
  Split DNS → Entry Point Tailscale IP
            → Entry Point Traefik (:443, TLS 종료)
            → Chain Node Traefik (HTTP) → ... → 404 fallback
```

- 외부/내부 모두 **동일한 Entry Point**에서 TLS 종료
- 별도 디바이스를 체인에 추가: Traefik `HostRegexp(.*) priority:1` fallback router
- 체인 미참여 디바이스: Entry Point에서 호스트 매칭으로 직접 라우팅

### Traefik Label Patterns

서비스 배포 시 Traefik labels로 자동 라우팅. 템플릿: `$CLAUDE_PLUGIN_ROOT/skills/networking/templates/traefik-service-labels.template.yml`

#### 기본 HTTP 서비스

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.{SERVICE}.rule=Host(`{SERVICE}.{DOMAIN}`)"
  - "traefik.http.services.{SERVICE}.loadbalancer.server.port={PORT}"
networks:
  - {NETWORK}  # 디바이스별 네트워크 이름 확인 (docs/machines/ 참조)
```

#### 멀티 서비스 컨테이너 (예: 앱 + registry)

하나의 컨테이너에 서비스가 여러 개인 경우 **라우터마다 `.service` 라벨 명시 필수**:

```yaml
labels:
  - "traefik.http.routers.{SERVICE_A}.rule=Host(`{SERVICE_A}.{DOMAIN}`)"
  - "traefik.http.routers.{SERVICE_A}.service={SERVICE_A}"
  - "traefik.http.services.{SERVICE_A}.loadbalancer.server.port={PORT_A}"
  - "traefik.http.routers.{SERVICE_B}.rule=Host(`{SERVICE_B}.{DOMAIN}`)"
  - "traefik.http.routers.{SERVICE_B}.service={SERVICE_B}"
  - "traefik.http.services.{SERVICE_B}.loadbalancer.server.port={PORT_B}"
```

#### TCP 포워딩 (non-HTTP)

HTTP 체인과 별도로, TCP 포워딩은 진입점에서 대상 서버로 직접 전달:

```yaml
# traefik 설정 (file provider)
tcp:
  routers:
    {SERVICE}-tcp:
      entryPoints: [{ENTRYPOINT}]
      rule: "HostSNI(`*`)"
      service: {SERVICE}-tcp-svc
  services:
    {SERVICE}-tcp-svc:
      loadBalancer:
        servers:
          - address: "{TARGET_IP}:{TARGET_PORT}"
```

### Split DNS Configuration

| 구성 요소 | 역할 |
|-----------|------|
| VPN Split DNS (예: Tailscale Magic DNS) | 내부 도메인 → Entry Point VPN IP |
| LAN DNS (예: AdGuard) | VPN 미설치 LAN 기기 → DNS rewrite |

### ACME 와일드카드 인증서

- 진입점 Traefik에서 DNS Challenge로 와일드카드 인증서 관리
- 인증서 저장 경로는 영속 볼륨에 마운트 (재배포 시 재발급 방지)
- 도메인: `*.{DOMAIN}`, `*.{INTERNAL_SUBDOMAIN}.{DOMAIN}`

### Router Priority 규칙

| Priority | 용도 | 예시 |
|----------|------|------|
| 100 | Dashboard 라우터 | Traefik dashboard |
| 10+ | Docker Provider 자동 발견 서비스 | 기본값 (서비스 labels) |
| 1 | 체인 fallback 라우터 | `HostRegexp(.*) → 다음 노드` |

높은 priority가 먼저 매칭 → 로컬 서비스가 우선 처리됨.

## Guard Rails

### 디바이스별 네트워크 이름

compose 작성 시 **반드시 디바이스에 맞는 네트워크 이름** 사용.
디바이스별 네트워크 이름은 `$CLAUDE_PLUGIN_ROOT/docs/machines/` 참조.

### 포트 충돌 주의

일부 디바이스는 시스템 서비스가 80/443 등 표준 포트를 점유 (예: NAS DSM).
→ 체인 노드 Traefik은 대체 포트(예: 8880) 사용.
→ 디바이스별 상세는 `$CLAUDE_PLUGIN_ROOT/docs/machines/` 참조.

### NAS HTTPS 서비스

NAS에서 HTTPS 서비스 운영 시 **Service HTTPS Proxy 패턴** 적용 필수:
- `external_url`은 `https://`, 내부는 HTTP, `X-Forwarded-Proto: https` 헤더 전달
- 미적용 시 JWT auth, Docker registry, redirect URL 등에서 HTTPS/HTTP 불일치 발생

## Domain Data References

구체적인 IP, 포트, 디바이스별 설정은 아래 문서 참조:

- `$CLAUDE_PLUGIN_ROOT/docs/architecture/traefik-chain.md` — Traefik 체인 토폴로지, 노드별 설정 상세
- `$CLAUDE_PLUGIN_ROOT/docs/architecture/dns-split.md` — Split DNS 설정, 도메인 구조
- `$CLAUDE_PLUGIN_ROOT/docs/reference/ports.md` — 포트 할당표, 도메인 목록

## Templates

- `$CLAUDE_PLUGIN_ROOT/skills/networking/templates/traefik-service-labels.template.yml` — Traefik 라벨 시나리오별 템플릿
