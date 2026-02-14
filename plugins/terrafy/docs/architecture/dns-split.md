# Split DNS Architecture

> Tailscale Magic DNS를 통한 내부 서비스 접근

## 도메인 구조

| 패턴 | 용도 | 접근 경로 |
|------|------|----------|
| `*.codepoet.site` | 외부 공개 | Cloudflare Tunnel → Mac Mini |
| `*.home.codepoet.site` | 내부 전용 | Split DNS → Mac Mini Tailscale IP (TLS 종료 후 체인) |

## Split DNS 설정

### Tailscale Magic DNS (권장)

Tailscale Admin Console에서 Split DNS 설정:

```
도메인: home.codepoet.site
Nameservers: 100.108.195.20 (Mac Mini 1 Tailscale IP)
```

**장점:**
- VPN 연결 시 자동으로 내부 서비스 접근
- 어디서든 동일한 도메인 사용 가능
- Mac Mini에서 TLS 종료 → 각 머신에 인증서/insecure 설정 불필요

### AdGuard Home (LAN 기기용)

LAN 내 Tailscale 미설치 기기를 위한 설정:

```
URL: http://192.168.0.14:3080
Filters → DNS rewrites:

*.home.codepoet.site → 100.125.241.80 (NAS Tailscale IP)
```

## 트래픽 흐름

### 외부 접속 (Tailscale 미연결)

```
User → *.codepoet.site
     → Cloudflare DNS (공개)
     → Cloudflare Tunnel
     → Mac Mini Traefik (진입점)
     → 서비스
```

### 내부 접속 (Tailscale 연결)

```
User → *.home.codepoet.site
     → Tailscale Split DNS
     → Mac Mini Tailscale IP (100.108.195.20:443)
     → Mac Mini Traefik (TLS 종료, ACME *.home.codepoet.site)
        ├─ Mac Mini 서비스 → 직접 처리
        └─ NAS 서비스 → HTTP로 NAS Traefik (:8880) → 서비스
```

## 왜 Mac Mini Tailscale IP?

**내부 진입점도 Mac Mini로 설정한 이유:**

1. **TLS 인증서 중앙 관리**: Mac Mini만 ACME 인증서를 가지고 있음
2. **HTTPS 통합**: 외부/내부 모두 Mac Mini에서 TLS 종료 → 일관된 HTTPS 경험
3. **서비스 URL 일관성**: `external_url`을 `https://`로 설정 가능 → JWT realm, redirect URL 모두 HTTPS

**NAS를 내부 진입점으로 하면:**
- NAS Traefik에 별도 ACME 설정 필요 또는 인증서 복사 필요
- NAS에 인증서가 없으면 HTTP만 가능 → Docker registry JWT auth 등에서 문제 발생
- 각 머신마다 `insecure-registries` 등 추가 설정 필요

## 내부 서비스 목록

| 서비스 | 도메인 | 위치 |
|--------|--------|------|
| GitLab | `gitlab.home.codepoet.site` | NAS |
| GitLab Registry | `gitlab-registry.home.codepoet.site` | NAS |
| Grafana | `grafana.home.codepoet.site` | Mac Mini |
| n8n | `n8n.home.codepoet.site` | Mac Mini |
| Prefect | `prefect.home.codepoet.site` | Mac Mini |
| Vault | `vault.home.codepoet.site` | Mac Mini |
| Vaultwarden | `vaultwarden.home.codepoet.site` | Mac Mini |
| Portainer | `portainer.home.codepoet.site` | Mac Mini |

## HTTPS (TLS)

내부 접속은 기본 HTTPS:

- Split DNS → Mac Mini Traefik(:443)에서 TLS 종료
- `*.home.codepoet.site` ACME 와일드카드 인증서 (Cloudflare DNS Challenge)
- TLS 종료 후 체인은 전부 HTTP (NAS :8880, Linux :80)
- NAS 서비스는 `external_url`을 `https://`로 설정하고 내부는 HTTP 유지
- `X-Forwarded-Proto: https` 헤더로 프록시 뒤에 있음을 인식

상세: [Traefik Chain Architecture](./traefik-chain.md) → "NAS 서비스 HTTPS 패턴" 참조

## 설정 확인

```bash
# Tailscale Split DNS 확인
tailscale status

# DNS 조회 테스트 (Tailscale 연결 상태에서)
dig grafana.home.codepoet.site

# 서비스 접속 테스트
curl -I https://grafana.home.codepoet.site
```

## 관련 문서

- [Traefik Chain Architecture](./traefik-chain.md)
- [Tailscale Split DNS](https://tailscale.com/kb/1054/dns)
