# Traefik BasicAuth — 외부 접근만 인증, 내부는 패스

> 외부(codepoet.site)에는 BasicAuth를 걸고, 내부(home.codepoet.site)는 인증 없이 통과시키는 방법.

## 전제 조건

- Traefik chain 구조 (Mac Mini → NAS → Linux)
- 서비스가 Docker labels로 Traefik에 등록되어 있음
- 외부: Cloudflare Tunnel (`*.codepoet.site`), 내부: Split DNS (`*.home.codepoet.site`)

## 핵심 원리

하나의 서비스에 라우터 2개를 만들어 도메인별로 미들웨어를 분리한다.

```
내부 라우터 (no middleware) ← home.codepoet.site
외부 라우터 (BasicAuth)    ← codepoet.site
둘 다 같은 service(loadbalancer) 참조
```

## 1단계: htpasswd 해시 생성

```bash
htpasswd -nb username password
# 출력: username:$apr1$xxxx$xxxx
```

`htpasswd` 없으면 openssl로 대체:

```bash
printf "username:$(openssl passwd -apr1 password)\n"
```

## 2단계: docker-compose.yml labels 수정

기존 단일 라우터를 내부/외부 2개로 분리.

**Before (단일 라우터):**

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.my-svc.rule=Host(`my-svc.home.codepoet.site`) || Host(`my-svc.codepoet.site`)"
  - "traefik.http.routers.my-svc.entrypoints=web"
  - "traefik.http.services.my-svc.loadbalancer.server.port=3000"
```

**After (내부/외부 분리):**

```yaml
labels:
  - "traefik.enable=true"
  # 내부 접근 (인증 없음)
  - "traefik.http.routers.my-svc-internal.rule=Host(`my-svc.home.codepoet.site`)"
  - "traefik.http.routers.my-svc-internal.entrypoints=web"
  - "traefik.http.routers.my-svc-internal.service=my-svc"
  # 외부 접근 (BasicAuth)
  - "traefik.http.routers.my-svc-external.rule=Host(`my-svc.codepoet.site`)"
  - "traefik.http.routers.my-svc-external.entrypoints=web"
  - "traefik.http.routers.my-svc-external.middlewares=my-svc-auth"
  - "traefik.http.routers.my-svc-external.service=my-svc"
  # BasicAuth middleware
  - "traefik.http.middlewares.my-svc-auth.basicauth.users=username:$$apr1$$xxxx$$xxxx"
  # Service (공유)
  - "traefik.http.services.my-svc.loadbalancer.server.port=3000"
```

### 주의사항

| 항목 | 설명 |
|------|------|
| **`$$` 이스케이프** | docker-compose에서 `$`는 `$$`로 이스케이프 필수 |
| **service 명시** | 라우터가 2개이므로 `.service=my-svc` 를 양쪽 모두에 명시해야 함 |
| **라우터 이름** | `-internal` / `-external` 접미사로 구분. 이름 충돌 주의 |
| **middleware 이름** | `my-svc-auth` — 서비스별로 고유하게 |

## 3단계: 재배포

```bash
export VAULT_TOKEN='hvs.xxxxx'
./scripts/portainer-gitops.sh update my-svc
```

## 4단계: 검증

```bash
# 내부 — 200 (인증 없이 통과)
curl -sk -o /dev/null -w "%{http_code}" https://my-svc.home.codepoet.site

# 외부 — 401 (인증 필요)
curl -sk -o /dev/null -w "%{http_code}" https://my-svc.codepoet.site

# 외부 — 200 (인증 통과)
curl -sk -o /dev/null -w "%{http_code}" -u username:password https://my-svc.codepoet.site
```

## 실제 적용 사례: rehab-crm

```
my-devops/services/codepoet-linux-1/rehab-crm/docker-compose.yml
```

- 내부: `rehab-crm.home.codepoet.site` → 200 (패스)
- 외부: `rehab-crm.codepoet.site` → 401 → BasicAuth → 200
