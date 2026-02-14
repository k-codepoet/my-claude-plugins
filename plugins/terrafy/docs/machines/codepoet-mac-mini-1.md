# codepoet-mac-mini-1 (Mac Mini M1)

> 메인 엔트리포인트. TLS 종료, Vault 마스터, 주요 서비스 호스팅.

## 하드웨어/OS

| 항목 | 값 |
|------|-----|
| 모델 | Mac Mini M1 |
| Arch | ARM64 |
| LAN IP | 192.168.0.48 |
| Tailscale | codepoet-mac-mini-1 / 100.108.195.20 |

## 역할

- **Traefik Chain Node 1 (진입점)**: 외부/내부 모든 트래픽의 시작점
- **ACME TLS 종료**: `*.codepoet.site`, `*.home.codepoet.site` 와일드카드 인증서 관리
- **Vault 마스터**: 시크릿 관리 중앙 서버
- **주요 서비스 호스팅**: Grafana, n8n, Prefect, Vaultwarden, Portainer Server

## Docker 환경

| 항목 | 값 |
|------|-----|
| Engine | 29.1.3 |
| API | 1.52 |
| Compose | v5.0.1 |
| Platform | Docker Desktop |

> 전체 디바이스 비교: [docker-versions.md](../docker-versions.md)

### Docker Desktop 특이사항

non-interactive SSH에서 `docker` 명령이 PATH에 없음:

```bash
# SSH 실행 시 전체 경로 사용
/usr/local/bin/docker ps

# 또는 PATH 설정
PATH=/usr/local/bin:$PATH docker compose up -d
```

## 영속 데이터

외장하드 `/Volumes/mac-ext-storage/`에 저장:

| 서비스 | 경로 |
|--------|------|
| Vault | `/Volumes/mac-ext-storage/.vault/` |
| Vaultwarden | `/Volumes/mac-ext-storage/.vaultwarden/` |
| Grafana | `/Volumes/mac-ext-storage/.grafana/` |
| n8n | `/Volumes/mac-ext-storage/.n8n/` |
| Prefect | `/Volumes/mac-ext-storage/.prefect/` |
| Traefik (ACME) | `/Volumes/mac-ext-storage/.traefik/letsencrypt/` |
| Portainer | `/Volumes/mac-ext-storage/.portainer/data` |
| GitLab Runner | `/Volumes/mac-ext-storage/.gitlab-runner/config/` |

## 서비스별 참고

- **Grafana UID**: `472:0` (user: grafana, group: root)
- **n8n**: `N8N_SECURE_COOKIE=false` (Cloudflare Tunnel 호환)
- **Vault Agent**: 여러 서비스(Traefik, Grafana, n8n, Prefect)에서 sidecar로 사용

## 네트워크

- Docker 네트워크 이름: **`traefik`**

## 포트 사용 현황

| 포트 | 서비스 | 용도 |
|------|--------|------|
| 80, 443 | Traefik | 외부/내부 진입점 |
| 8080 | Traefik | Dashboard |
| 20022 | Traefik (TCP) | GitLab SSH 포워딩 → NAS |
| 23000 | Grafana | Monitoring |
| 24200 | Prefect | Workflow orchestration |
| 25678 | n8n | Workflow automation |
| 28200 | Vault | Secrets management |
| 28888 | Vaultwarden | Password manager |
| 29000, 29443 | Portainer | Docker management |

> 전체 포트 할당표: [ports.md](../ports.md)

## 작업 경로

```
/Volumes/mac-ext-storage/k-codepoet/my-devops/
```

## 관련 문서

- [Docker 버전 현황](../docker-versions.md)
- [Traefik Chain 아키텍처](../../architecture/traefik-chain.md)
- [스택별 운영 노트](../stack-notes.md)
- [포트 할당표](../ports.md)
