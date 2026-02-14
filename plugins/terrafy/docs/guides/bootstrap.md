# Bootstrap Guide

> 인프라 시작/재부팅 시 서비스 시작 순서

## 체크리스트

```bash
# === Layer 1: Portainer (수동 compose) ===

# 1. Mac Mini - Portainer
ssh codepoet-mac-mini-1
cd /Volumes/mac-ext-storage/k-codepoet/my-devops/infra/codepoet-mac-mini-1/portainer
docker network create traefik 2>/dev/null || true
docker compose up -d
# → https://192.168.0.48:29443 접속하여 초기 설정 (최초 1회)

# 2. NAS - Portainer Agent
ssh codepoet-nas
cd /volume1/workspaces/k-codepoet/my-devops/infra/codepoet-nas/portainer-agent
docker compose up -d

# 3. Linux - Portainer Agent
ssh codepoet-linux-1
cd /home/choigawoon/k-codepoet/my-devops/infra/codepoet-linux-1/portainer-agent
docker compose up -d

# === Layer 2: Vault + Vaultwarden (Portainer 스택) ===
# Portainer UI에서 Vault 스택 배포
# → http://192.168.0.48:28200 접속하여 Unseal 수행
# Vaultwarden 스택 배포

# === Layer 3+: 나머지 스택 (Portainer GitOps) ===
# Vault 무관 서비스 먼저 (GitHub 소스): traefik-nas, gitlab-ce, traefik-mac2, traefik-linux, adguard-home, cloudflared
# Vault 무관 서비스 (GitLab 소스): gitlab-runner-mac, gitlab-runner-linux
# Vault 의존 서비스: traefik-mac (GitHub), grafana, n8n, prefect (GitLab)
```

## Layer 구조

### Layer 0: 시스템

각 머신에서 Docker daemon 실행 (보통 자동 시작)

### Layer 1: Portainer (수동)

Portainer만 수동 compose로 관리. 나머지는 모두 Portainer 스택으로 배포.

| 순서 | 서비스 | 위치 | 데이터 저장 |
|------|--------|------|------------|
| 1-1 | Portainer | Mac Mini | 외장 하드 (`/Volumes/mac-ext-storage/.portainer/data`) |
| 1-2 | Portainer Agent | NAS | - |
| 1-3 | Portainer Agent | Linux | - |

### Layer 2: Vault + Vaultwarden (Portainer 스택)

| 스택 | 위치 | 데이터 저장 | 비고 |
|------|------|------------|------|
| vault | Mac Mini | 외장 하드 (`/Volumes/mac-ext-storage/.vault/`) | Unseal 필요 |
| vaultwarden | Mac Mini | named volume | GitLab 소스 |

### Layer 3: Vault 무관 서비스 (Portainer 스택)

Vault 없이 먼저 배포 가능:

| 스택 | 위치 | Git Source |
|------|------|------------|
| traefik-nas | NAS | GitHub |
| gitlab-ce | NAS | GitHub |
| traefik-mac2 | Mac Mini 2 | GitHub |
| traefik-linux | Linux | GitHub |
| adguard-home | NAS | GitHub |
| cloudflared | NAS | GitHub |
| gitlab-runner-mac | Mac Mini | GitLab |
| gitlab-runner-linux | Linux | GitLab |

### Layer 4: Vault 의존 서비스 (Portainer 스택)

Vault Unseal 후 배포:

| 스택 | 위치 | 의존성 |
|------|------|--------|
| traefik-mac | Mac Mini | ACME 토큰 |
| cloudflared | NAS | Tunnel credentials |
| grafana | Mac Mini | AppRole |
| n8n | Mac Mini | AppRole |
| prefect | Mac Mini | AppRole |

## 의존성 다이어그램

```
Docker (system) ─────────────────────────────────────────────
    │
    ▼
  Portainer (수동) ──→ Portainer Agents
    │
    │ (스택 배포)
    ▼
┌─────────────────────────────────────────────────────────┐
│  Layer 2: Vault + Vaultwarden (스택)                     │
│    → Vault Unseal 필요                                   │
└─────────────────────────────────────────────────────────┘
    │
    ├── Vault 무관 ──→ traefik-nas, adguard-home,
    │                  gitlab-ce
    │
    └── Vault 의존 ──→ traefik-mac, cloudflared,
                       grafana, n8n, prefect
```

## Vault Unseal

Vault 스택 배포 후 반드시 unseal 필요:

**자동 Unseal (vault-init 컨테이너):**
- credentials.json이 있으면 자동 unseal 시도
- 외장 하드: `/Volumes/mac-ext-storage/.vault/init/credentials.json`

**수동 Unseal:**
1. http://192.168.0.48:28200 접속
2. Unseal Key 3개 중 2개 입력
3. Root Token으로 로그인 확인

**API로 Unseal:**
```bash
# credentials.json에서 키 추출
KEYS=$(cat /Volumes/mac-ext-storage/.vault/init/credentials.json | jq -r '.unseal_keys_b64[0:3][]')

# Unseal (3개 중 2개 필요)
curl -X PUT http://192.168.0.48:28200/v1/sys/unseal -d "{\"key\": \"$KEY1\"}"
curl -X PUT http://192.168.0.48:28200/v1/sys/unseal -d "{\"key\": \"$KEY2\"}"
```

Vault sealed 상태 → 모든 Vault Agent 의존 서비스 시작 실패

## 문제 해결

### Vault sealed

```bash
# Vault 상태 확인
curl http://192.168.0.48:28200/v1/sys/seal-status | jq
```

### Portainer Agent 연결 실패

```bash
# Agent 상태 확인
docker logs portainer-agent

# 포트 확인
netstat -tlnp | grep 900
```

### Traefik 체인 확인

```bash
# 외부 접속 테스트
curl -I https://n8n.codepoet.site

# 내부 접속 테스트 (Tailscale 연결 상태)
curl -I https://grafana.home.codepoet.site
```

## 데이터 백업

Docker 초기화 시에도 보존되는 외장 하드 마운트:

| 서비스 | 경로 |
|--------|------|
| Portainer | `/Volumes/mac-ext-storage/.portainer/data` |
| Vault | `/Volumes/mac-ext-storage/.vault/` |

Named volume 사용 서비스는 Docker 초기화 시 데이터 손실 주의.
