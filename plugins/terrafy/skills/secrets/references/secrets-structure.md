# Vault Secrets Structure

> Vault 시크릿 경로 및 구조

## 경로 구조

```
secret/
├── common/                          # 모든 머신 공통
│   ├── cloudflare                   # Tunnel credentials
│   ├── cloudflare-approle           # cloudflared용 AppRole
│   ├── cloudflare-acme              # ACME DNS Challenge용 API Token
│   ├── cloudflare-acme-approle      # traefik-mac용 AppRole
│   ├── portainer                    # Portainer API
│   ├── git                          # Git credentials
│   └── gitlab                       # GitLab credentials
│
└── services/                        # 서비스별
    ├── n8n                          # n8n 런타임 secrets
    ├── n8n-approle                  # n8n용 AppRole
    ├── prefect
    ├── prefect-approle
    ├── grafana
    ├── grafana-approle
    ├── vaultwarden
    └── vaultwarden-approle
```

## 분류 기준

| 분류 | 경로 | 기준 |
|------|------|------|
| **common** | `secret/common/` | 모든 머신에서 동일한 값 |
| **services** | `secret/services/{name}/` | 서비스별 고유, 어느 머신이든 동일 |
| **{name}-approle** | `secret/{path}/{name}-approle` | 해당 서비스의 AppRole 인증 정보 |

## 상세 내용

### secret/common/cloudflare

```
TUNNEL_ID       # Cloudflare Tunnel ID
TUNNEL_SECRET   # Tunnel Secret
ACCOUNT_TAG     # Account Tag
```

### secret/common/cloudflare-acme

```
CF_DNS_API_TOKEN   # Cloudflare DNS API Token (ACME용)
```

### secret/common/portainer

```
URL        # https://192.168.0.48:29443
API_KEY    # Portainer API Key
```

### secret/common/gitlab

```
GITLAB_URL     # http://gitlab.home.codepoet.site
GITLAB_TOKEN   # Personal Access Token (glpat-xxx)
```

### secret/common/git

```
REPO_URL    # https://github.com/k-codepoet/my-devops.git
BRANCH      # main
USERNAME    # Git username
TOKEN       # Personal Access Token
```

### secret/services/n8n

```
POSTGRES_USER
POSTGRES_PASSWORD
POSTGRES_DB
N8N_HOST
N8N_ENCRYPTION_KEY
```

### secret/services/grafana

```
GF_SECURITY_ADMIN_USER
GF_SECURITY_ADMIN_PASSWORD
```

### secret/services/vaultwarden

```
DOMAIN
ADMIN_TOKEN
SIGNUPS_ALLOWED
```

### secret/services/{name}-approle

```
VAULT_ROLE_ID      # AppRole Role ID
VAULT_SECRET_ID    # AppRole Secret ID
```

## 조회 방법

```bash
# Secret 조회
ssh codepoet-mac-mini-1 "docker exec -e VAULT_TOKEN=hvs.xxx vault \
  vault kv get secret/services/n8n"

# 경로 목록
ssh codepoet-mac-mini-1 "docker exec -e VAULT_TOKEN=hvs.xxx vault \
  vault kv list secret/services/"
```

## AppRole 정보

| 서비스 | Role ID | Vault 경로 |
|--------|---------|------------|
| n8n | `7bb27be2-...` | `secret/services/n8n-approle` |
| prefect | `d7b8c5bc-...` | `secret/services/prefect-approle` |
| grafana | `a90e5eba-...` | `secret/services/grafana-approle` |
| vaultwarden | `b2ad5ae9-...` | `secret/services/vaultwarden-approle` |
| cloudflared | `138abcba-...` | `secret/common/cloudflare-approle` |
| traefik-mac | - | `secret/common/cloudflare-acme-approle` |
