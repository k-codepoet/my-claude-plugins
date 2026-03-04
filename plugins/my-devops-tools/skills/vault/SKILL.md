---
description: vault CLI 설치, vault 사용법, vault 명령어, 시크릿 관리, AppRole, 토큰, seal/unseal 관련 작업
allowed-tools: Bash, Read, Write
---

# Vault CLI - 설치 및 사용법 가이드

DevOps 도구 설치 + 커스텀 사용법 관리 플러그인의 Vault 스킬.

## 설치

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/install-vault.sh
```

## 환경 설정

```bash
# Vault 서버 주소 (필수)
export VAULT_ADDR="https://vault.example.com"

# 인증 (택1)
export VAULT_TOKEN="hvs.xxxxx"              # 토큰 직접 지정
vault login -method=userpass username=admin  # userpass 인증
vault login -method=approle \               # AppRole 인증
  role_id="xxx" secret_id="yyy"
```

## 내 커스텀 사용법

### 기본 CRUD

```bash
# KV v2 시크릿 엔진 (현재 사용 중)

# 읽기
vault kv get secret/services/{name}

# 쓰기 (key=value 쌍)
vault kv put secret/services/{name} key1=val1 key2=val2

# 특정 필드만 추출
vault kv get -field=DB_PASSWORD secret/services/{name}

# JSON 출력
vault kv get -format=json secret/services/{name}

# 삭제
vault kv delete secret/services/{name}

# 버전 히스토리
vault kv metadata get secret/services/{name}
```

### 시크릿 경로 규칙

```
secret/services/{name}          # 런타임 시크릿 (API key, DB password 등)
secret/services/{name}-approle  # AppRole credentials (role_id, secret_id)
```

### AppRole 관리

```bash
# AppRole 생성
vault auth enable approle  # 최초 1회
vault write auth/approle/role/{service} \
  token_policies="{service}-policy" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=0

# role_id 조회
vault read auth/approle/role/{service}/role-id

# secret_id 발급
vault write -f auth/approle/role/{service}/secret-id

# AppRole로 로그인
vault write auth/approle/login \
  role_id="xxx" secret_id="yyy"
```

### Policy 관리

```bash
# 정책 생성 (HCL)
vault policy write {service}-policy - <<'EOF'
path "secret/data/services/{service}" {
  capabilities = ["read"]
}
path "secret/data/services/{service}-approle" {
  capabilities = ["read"]
}
EOF

# 정책 목록 / 조회
vault policy list
vault policy read {service}-policy
```

### Seal / Unseal

```bash
# 상태 확인
vault status

# Unseal (sealed 상태일 때 - 키 3개 중 2개 필요)
vault operator unseal <key1>
vault operator unseal <key2>

# Seal (긴급 시)
vault operator seal
```

### Vault CLI 없이 사용 (docker exec)

```bash
# Vault 컨테이너에서 직접 실행
docker exec -e VAULT_TOKEN=$VAULT_TOKEN vault-server \
  vault kv get secret/services/{name}
```

## Security Rules

- **Root Token** — 절대 파일/커밋에 저장 금지. 환경변수로만 전달
- **스크립트 실행 시** — `export VAULT_TOKEN=...` → 작업 후 `unset VAULT_TOKEN`
- **시크릿 값 로그 노출 금지** — `set +x`, `> /dev/null` 활용
- **AppRole secret_id** — Portainer Stack Variable 등 안전한 경로로만 전달
- **새 시크릿 추가 시** — 반드시 policy 확인/생성 후 연결

## 자주 쓰는 조합

```bash
# 서비스 시크릿 전체 조회 (경로 목록)
vault kv list secret/services/

# 특정 서비스 시크릿을 .env 형태로 추출
vault kv get -format=json secret/services/{name} \
  | jq -r '.data.data | to_entries[] | "\(.key)=\(.value)"'

# 시크릿 복사 (서비스 간)
vault kv get -format=json secret/services/source \
  | jq -r '.data.data' \
  | vault kv put secret/services/target -
```
