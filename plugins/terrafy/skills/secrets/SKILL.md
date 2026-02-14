---
name: secrets
description: Vault, secret, 시크릿, AppRole, 환경변수 주입, vault agent, secrets operator, SOPS 관련 작업
allowed-tools: Bash, Read, Write
---

# Secrets Management

시크릿 중앙 저장 → 접근 제어 → 런타임 주입의 범용 시크릿 관리 프레임워크.

## 참조 문서 (필수)

**스킬 실행 전 반드시 읽기:**
- `$CLAUDE_PLUGIN_ROOT/docs/architecture/vault-agent.md` - Vault Agent 아키텍처
- `$CLAUDE_PLUGIN_ROOT/docs/reference/secrets-structure.md` - 시크릿 구조 참조
- `$CLAUDE_PLUGIN_ROOT/docs/guides/vault-cli.md` - Vault CLI 사용법

## Secrets Backends (확장 가능)

| Backend | Status | Use Case |
|---------|--------|----------|
| Vault + Agent sidecar | **현재 사용** | Docker Compose 환경 |
| k8s Secrets + External Secrets Operator | 확장 예정 | k8s 클러스터 환경 |
| SOPS | 확장 예정 | Git-native 암호화 |

## Core Pattern (범용)

Backend 무관하게 적용되는 원칙:

1. **시크릿 중앙 저장소에 저장** — 하나의 source of truth
2. **접근 제어 설정** — AppRole / RBAC / ServiceAccount 등
3. **런타임 주입** — sidecar / init container / CSI driver / env injection
4. **Git에 시크릿 절대 저장 금지** — 평문, 암호문 모두 커밋 불가

## Current Implementation: Vault Agent Sidecar

### Sidecar 패턴 개요

Vault 의존 서비스 (Bootstrap Layer 4)는 Vault Agent sidecar로 secrets를 주입:

1. Vault Agent 컨테이너가 AppRole로 인증
2. 시크릿을 템플릿 렌더링하여 `.env` 파일 생성 → shared volume에 저장
3. 메인 서비스가 entrypoint에서 `.env` 파일을 로드하여 환경변수로 주입
4. Vault Agent는 `restart: no`로 1회 실행 후 종료

```yaml
# 패턴 요약 (상세 템플릿 → $CLAUDE_PLUGIN_ROOT/skills/secrets/templates/)
services:
  vault-agent:
    image: hashicorp/vault:{VERSION}
    restart: "no"
    environment:
      - VAULT_ADDR={VAULT_URL}
      - VAULT_ROLE_ID=${VAULT_ROLE_ID}
      - VAULT_SECRET_ID=${VAULT_SECRET_ID}
    volumes:
      - secrets:/secrets

  {SERVICE}:
    entrypoint: [sh, -c, "export $$(cat /secrets/{SERVICE}.env | xargs) && exec {CMD}"]
    depends_on:
      vault-agent: { condition: service_completed_successfully }
    volumes:
      - secrets:/secrets

volumes:
  secrets:
```

### AppRole 메커니즘

- 각 서비스마다 고유 AppRole 생성
- `role_id`는 고정, `secret_id`는 Portainer Stack Variable로 주입
- 시크릿 경로에 대한 최소 권한 정책(policy) 연결

### 시크릿 경로 규칙

```
secret/services/{name}          # 런타임 시크릿 (API key, DB password 등)
secret/services/{name}-approle  # AppRole credentials (role_id, secret_id)
```

### Entrypoint Injection 패턴

```bash
# Vault Agent가 렌더링한 .env 파일을 환경변수로 로드
entrypoint: [sh, -c, "export $$(cat /secrets/{SERVICE}.env | xargs) && exec {CMD}"]
```

- `$$` — compose의 `$` 이스케이프
- `xargs` — 줄바꿈 구분 KEY=VALUE를 공백 구분으로 변환
- `exec` — PID 1 교체로 시그널 전달 보장

### Security Rules

- **Root Token** — 시크릿 저장소의 credential 파일에서만 추출, 절대 파일/커밋에 저장 금지
- **스크립트 실행 시** — env var로 전달 (`export VAULT_TOKEN=...`), 명령 종료 후 unset
- **Vault CLI 미설치 환경** — `docker exec` 패턴 사용
- **Vault sealed 상태** — 모든 Agent 의존 서비스 시작 실패 → Bootstrap Guide 참조

## Guard Rails

- **새 시크릿 추가 시** 반드시 Vault policy 확인/생성
- **AppRole secret_id는 Portainer Stack Variable로만 전달** — compose 파일에 하드코딩 금지
- **시크릿 값은 로그/출력에 노출 금지** — `set +x`, `> /dev/null` 활용

## Domain Data References

> 아래 문서에서 Vault 주소, 시크릿 구조, CLI 사용법 등 도메인 데이터를 참조하세요.

| 참조 | 경로 |
|------|------|
| 시크릿 구조 참조 | `$CLAUDE_PLUGIN_ROOT/docs/reference/secrets-structure.md` |
| Vault Agent 아키텍처 | `$CLAUDE_PLUGIN_ROOT/docs/architecture/vault-agent.md` |
| Vault CLI 사용법 | `$CLAUDE_PLUGIN_ROOT/docs/guides/vault-cli.md` |

## Templates

→ `$CLAUDE_PLUGIN_ROOT/skills/secrets/templates/` 참조
