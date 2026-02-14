# Traefik

> 리버스 프록시 체인. 3개 머신에서 실행, Mac Mini가 진입점.

## 체인 구조

```
외부: Cloudflare Tunnel → Mac Mini (.48:80/443) → NAS (.14:8880) → Linux (.34:80) → 404
내부: Split DNS → Mac Mini Tailscale IP → 동일 체인
```

> 상세 아키텍처: [traefik-chain.md](../../architecture/traefik-chain.md)

## 머신별 차이

### Mac Mini 1 — Chain Node 1 (진입점)

| 항목 | 값 |
|------|-----|
| 포트 | 80, 443, 8080 (dashboard), 20022 (TCP) |
| 네트워크 | `traefik` |
| TLS | ACME 와일드카드 (Cloudflare DNS Challenge) |
| Vault Agent | CF_DNS_API_TOKEN 주입 |

- ACME 인증서 저장: `/Volumes/mac-ext-storage/.traefik/letsencrypt/acme.json`
- HTTP/HTTPS fallback → NAS
- TCP 포워딩: GitLab SSH (20022 → NAS:20022)
- init-config 컨테이너로 설정 생성 (named volume)

### NAS — Chain Node 2

| 항목 | 값 |
|------|-----|
| 포트 | 8880 (DSM이 80/443 점유) |
| 네트워크 | `gateway` |
| TLS | 없음 (HTTP only) |

- Mac Mini에서 매칭되지 않은 트래픽 수신
- NAS 서비스 (GitLab, AdGuard 등) 라우팅
- 미매칭 시 Linux로 체인
- init-config 컨테이너로 설정 생성

### Linux — Chain Node 3 (404 fallback)

| 항목 | 값 |
|------|-----|
| 포트 | 80, 8080 (dashboard) |
| 네트워크 | `traefik` |
| TLS | 없음 (HTTP only) |

- 체인의 마지막 노드
- 매칭되지 않는 모든 트래픽에 404 반환
- init-config 컨테이너로 설정 생성

### Mac Mini 2 — Standalone

| 항목 | 값 |
|------|-----|
| 포트 | 80, 8080 (dashboard) |
| 네트워크 | `traefik` |
| TLS | 없음 (HTTP only) |

- 체인 미참여
- Mac Mini 1/NAS에서 특정 호스트 규칙으로 직접 라우팅
- 자체 404 fallback

## 우선순위

| Priority | 용도 |
|----------|------|
| 100 | Dashboard 라우터 |
| 10+ | Docker Provider 자동 발견 서비스 |
| 1 | 체이닝 라우터 (fallback) |

## NAS 서비스 HTTPS 패턴

NAS에서 서비스를 HTTPS로 제공하는 표준 패턴:

1. 서비스의 `external_url`은 `https://` 사용
2. 서비스 내부는 HTTP로 동작
3. `X-Forwarded-Proto: https` 헤더 전달
4. Traefik labels의 entrypoints는 `web` (NAS Traefik은 HTTP만)
5. TLS는 Mac Mini Traefik이 일괄 처리

## 관련 문서

- [Traefik Chain 아키텍처 (상세)](../../architecture/traefik-chain.md)
- [codepoet-mac-mini-1](../machines/codepoet-mac-mini-1.md)
- [codepoet-nas](../machines/codepoet-nas.md)
- [codepoet-linux-1](../machines/codepoet-linux-1.md)
