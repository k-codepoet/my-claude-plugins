# Vault Agent Integration

> 환경변수 관리를 Vault Agent 자동 주입으로 처리

## 아키텍처

```
Vault (Mac Mini:28200)
├── secret/services/n8n              # 서비스 런타임 secrets
└── secret/services/n8n-approle      # AppRole 정보
        ↓
Portainer Stack Variables
├── VAULT_ROLE_ID=...
└── VAULT_SECRET_ID=...
        ↓
Docker Compose (vault-agent 서비스)
├── entrypoint에서 환경변수 → 파일로 변환
├── vault-agent.hcl 동적 생성
└── vault agent 실행 → secrets 렌더링
        ↓
/secrets/{service}.env
        ↓
서비스 컨테이너 (entrypoint에서 source)
```

## Vault 시크릿 구조

```
secret/
├── common/                          # 모든 머신 공통
│   ├── cloudflare                   # TUNNEL_ID, TUNNEL_SECRET, ACCOUNT_TAG
│   ├── cloudflare-approle           # VAULT_ROLE_ID, VAULT_SECRET_ID
│   ├── cloudflare-acme              # CF_DNS_API_TOKEN
│   ├── cloudflare-acme-approle      # traefik-mac용 AppRole
│   ├── portainer                    # URL, API_KEY
│   ├── git                          # REPO_URL, BRANCH, USERNAME, TOKEN
│   └── gitlab                       # URL, USERNAME, TOKEN
│
└── services/                        # 서비스별
    ├── n8n                          # POSTGRES_*, N8N_HOST
    ├── n8n-approle                  # VAULT_ROLE_ID, VAULT_SECRET_ID
    ├── prefect                      # POSTGRES_*
    ├── prefect-approle
    ├── grafana                      # ADMIN_USER, ADMIN_PASSWORD
    ├── grafana-approle
    ├── vaultwarden                  # DOMAIN, ADMIN_TOKEN
    └── vaultwarden-approle
```

## docker-compose.yml 패턴

```yaml
services:
  vault-agent:
    image: hashicorp/vault:1.15
    container_name: ${SERVICE_NAME}-vault-agent
    restart: "no"
    user: root
    environment:
      - VAULT_ADDR=http://192.168.0.48:28200
      - VAULT_ROLE_ID=${VAULT_ROLE_ID}
      - VAULT_SECRET_ID=${VAULT_SECRET_ID}
    entrypoint:
      - sh
      - -c
      - |
        # 환경변수 검증
        if [ -z "$$VAULT_ROLE_ID" ] || [ -z "$$VAULT_SECRET_ID" ]; then
          echo "ERROR: VAULT_ROLE_ID and VAULT_SECRET_ID must be set"
          exit 1
        fi

        # 환경변수 → 파일 변환
        mkdir -p /vault
        echo "$$VAULT_ROLE_ID" > /vault/role-id
        echo "$$VAULT_SECRET_ID" > /vault/secret-id
        chmod 600 /vault/role-id /vault/secret-id

        # vault-agent.hcl 동적 생성
        cat > /vault/agent.hcl << 'AGENT_EOF'
        pid_file = "/tmp/vault-agent.pid"
        vault {
          address = "http://192.168.0.48:28200"
        }
        auto_auth {
          method "approle" {
            config = {
              role_id_file_path   = "/vault/role-id"
              secret_id_file_path = "/vault/secret-id"
              remove_secret_id_file_after_reading = false
            }
          }
          sink "file" {
            config = {
              path = "/vault/token"
            }
          }
        }
        template {
          contents = <<EOF
        KEY1={{ with secret "secret/data/services/${SERVICE}" }}{{ .Data.data.KEY1 }}{{ end }}
        KEY2={{ with secret "secret/data/services/${SERVICE}" }}{{ .Data.data.KEY2 }}{{ end }}
        EOF
          destination = "/secrets/${SERVICE}.env"
        }
        AGENT_EOF

        # vault agent 실행 (timeout 30초)
        vault agent -config=/vault/agent.hcl &
        AGENT_PID=$$!
        for i in $$(seq 1 30); do
          if [ -f /secrets/${SERVICE}.env ]; then
            echo "Secrets file created successfully"
            kill $$AGENT_PID 2>/dev/null || true
            exit 0
          fi
          sleep 1
        done
        echo "ERROR: Secrets file not created within timeout"
        kill $$AGENT_PID 2>/dev/null || true
        exit 1
    volumes:
      - secrets-vol:/secrets

  service:
    depends_on:
      vault-agent:
        condition: service_completed_successfully
    entrypoint:
      - sh
      - -c
      - |
        export $(cat /secrets/${SERVICE}.env | xargs)
        exec /original-entrypoint
    volumes:
      - secrets-vol:/secrets:ro

volumes:
  secrets-vol:
```

## AppRole 정보

| 서비스 | Vault 경로 |
|--------|------------|
| n8n | `secret/services/n8n-approle` |
| prefect | `secret/services/prefect-approle` |
| grafana | `secret/services/grafana-approle` |
| vaultwarden | `secret/services/vaultwarden-approle` |
| cloudflared | `secret/common/cloudflare-approle` |
| traefik-mac | `secret/common/cloudflare-acme-approle` |

## 배포 방법

### 1. Vault에서 AppRole 정보 확인

```bash
ssh codepoet-mac-mini-1 "docker exec -e VAULT_TOKEN=hvs.xxx vault \
  vault kv get secret/services/n8n-approle"
```

### 2. Portainer Stack Variables 설정

Portainer UI → Stack → Environment Variables:
- `VAULT_ROLE_ID`: AppRole Role ID
- `VAULT_SECRET_ID`: AppRole Secret ID

### 3. 검증

```bash
# vault-agent 로그 확인
docker logs n8n-vault-agent

# secrets 파일 확인
docker exec n8n cat /secrets/n8n.env
```

## 새 서비스 추가 시

1. **Vault에 secrets 저장:**
   ```bash
   vault kv put secret/services/{name} KEY1=VALUE1 KEY2=VALUE2
   ```

2. **Policy 생성:**
   ```bash
   vault policy write {name}-policy - <<EOF
   path "secret/data/services/{name}" {
     capabilities = ["read"]
   }
   EOF
   ```

3. **AppRole 생성:**
   ```bash
   vault write auth/approle/role/{name} \
     token_policies="{name}-policy" \
     token_ttl=1h \
     token_max_ttl=4h
   ```

4. **AppRole 정보 저장:**
   ```bash
   ROLE_ID=$(vault read -field=role_id auth/approle/role/{name}/role-id)
   SECRET_ID=$(vault write -f -field=secret_id auth/approle/role/{name}/secret-id)
   vault kv put secret/services/{name}-approle \
     VAULT_ROLE_ID=$ROLE_ID \
     VAULT_SECRET_ID=$SECRET_ID
   ```

5. **docker-compose.yml에 패턴 적용**

6. **Portainer Stack Variables 설정**

## 롤백

문제 발생 시:
1. Portainer Stack Variables에서 직접 환경변수 설정
2. vault-agent 서비스 제거
3. 서비스 재배포
