# Vault CLI Guide

> Mac Mini의 Vault 컨테이너를 통한 CLI 사용법

## 기본 형식

Vault CLI는 로컬에 설치되어 있지 않으므로, Mac Mini의 vault 컨테이너를 통해 실행:

```bash
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  docker exec -e VAULT_TOKEN=<token> vault vault <command>"
```

## Secrets 관리

### Secret 저장

```bash
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault vault kv put secret/services/myservice \
  DB_PASSWORD=xxx \
  API_KEY=yyy"
```

### Secret 조회

```bash
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault vault kv get secret/services/myservice"
```

### Secret 삭제

```bash
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault vault kv delete secret/services/myservice"
```

## AppRole 관리

### Policy 생성

```bash
# heredoc 대신 echo + pipe 사용 (SSH 호환)
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  echo 'path \"secret/data/services/myservice\" { capabilities = [\"read\"] }' | \
  docker exec -i -e VAULT_TOKEN=hvs.xxx vault vault policy write myservice-policy -"
```

### AppRole 생성

```bash
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault vault write auth/approle/role/myservice \
  token_policies=myservice-policy \
  token_ttl=1h \
  token_max_ttl=4h"
```

### Role ID 확인

```bash
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault vault read auth/approle/role/myservice/role-id"
```

### Secret ID 생성

```bash
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault vault write -f auth/approle/role/myservice/secret-id"
```

### AppRole 정보 저장

```bash
# Role ID, Secret ID를 Vault에 저장 (Portainer에서 조회용)
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault vault kv put secret/services/myservice-approle \
  VAULT_ROLE_ID=<role-id> \
  VAULT_SECRET_ID=<secret-id>"
```

## 상태 확인

### Vault 상태

```bash
curl http://192.168.0.48:28200/v1/sys/seal-status | jq
```

### Secret 경로 목록

```bash
ssh codepoet-mac-mini-1 "export PATH=/opt/homebrew/bin:\$PATH && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault vault kv list secret/services/"
```

## 주의사항

- `VAULT_TOKEN`은 root token 또는 충분한 권한이 있는 토큰 사용
- SSH 환경에서 PATH가 설정되지 않으므로 `export PATH=/opt/homebrew/bin:$PATH` 필요
- heredoc은 SSH에서 동작하지 않으므로 `echo ... | docker exec -i` 패턴 사용

## Git SSH Key 생성

```bash
# SSH 키 생성
ssh-keygen -t ed25519 -C "my-devops" -f ~/.ssh/my-devops

# 공개키 확인
cat ~/.ssh/my-devops.pub
```

GitLab/GitHub에 공개키 등록 후 사용.
