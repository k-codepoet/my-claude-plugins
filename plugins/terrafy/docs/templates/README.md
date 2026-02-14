# Terrafy Documentation Templates

이 디렉토리는 인프라 문서의 **템플릿**을 제공합니다.
실제 인프라 데이터는 사용자 프로젝트의 `docs/` 디렉토리에 작성합니다.

## 사용법

1. 프로젝트에 `docs/` 디렉토리 생성
2. 필요한 템플릿을 복사하여 `{PLACEHOLDER}` 값을 실제 인프라 데이터로 교체
3. terrafy 스킬이 작업 시 프로젝트 `docs/`를 참조하여 정확한 명령어 생성

## 템플릿 목록

| Template | Purpose | Create As |
|----------|---------|-----------|
| `machine.template.md` | Device/node documentation | `docs/machines/{device-name}.md` |
| `service.template.md` | Per-service operations | `docs/services/{service-name}.md` |
| `ports-registry.template.md` | Port allocation table | `docs/reference/ports.md` |
| `stacks-registry.template.md` | Stack registration | `docs/reference/stacks-registry.md` |
| `secrets-structure.template.md` | Vault secret paths | `docs/reference/secrets-structure.md` |
| `traefik-chain.template.md` | Network topology | `docs/architecture/traefik-chain.md` |
| `dns-split.template.md` | DNS configuration | `docs/architecture/dns-split.md` |
| `add-new-service.template.md` | Service onboarding | `docs/guides/add-new-service.md` |
| `bootstrap-layers.template.md` | Deployment order | `docs/guides/bootstrap.md` |
| `vault-agent.template.md` | Vault sidecar architecture | `docs/architecture/vault-agent.md` |

## Placeholder Convention

- `{UPPER_SNAKE_CASE}` — replace with actual value
- Common placeholders:
  - `{DOMAIN}` — your domain (e.g., example.com)
  - `{INTERNAL_SUBDOMAIN}` — internal subdomain (e.g., home)
  - `{DEVICE_NAME}` — device hostname
  - `{LAN_IP}` — device LAN IP address
  - `{VPN_IP}` — device VPN IP address
  - `{DOCKER_NETWORK}` — Docker network name per device
  - `{STORAGE_BASE}` — persistent storage base path
  - `{VAULT_URL}` — Vault server URL
  - `{PORT_RANGE_START}` — host port range start (recommended: 20000)

## Project Docs Structure

After filling templates, your project should have:

```
your-project/
├── docs/
│   ├── architecture/
│   │   ├── traefik-chain.md
│   │   ├── dns-split.md
│   │   └── vault-agent.md
│   ├── guides/
│   │   ├── add-new-service.md
│   │   └── bootstrap.md
│   ├── machines/
│   │   ├── {device-1}.md
│   │   └── {device-2}.md
│   ├── reference/
│   │   ├── ports.md
│   │   ├── stacks-registry.md
│   │   └── secrets-structure.md
│   └── services/
│       ├── {service-1}.md
│       └── {service-2}.md
```
