---
name: deploy-stack
description: 서비스 추가, 스택 배포, deploy, portainer, gitops, helm, terraform, k8s, docker-compose 관련 작업
allowed-tools: Bash, Read, Write
---

# Service Deployment

서비스 정의 → 인그레스 → 오케스트레이터 등록 → 배포 실행의 범용 배포 프레임워크.

## 참조 문서 (필수)

**스킬 실행 전 반드시 읽기:**
- `$CLAUDE_PLUGIN_ROOT/docs/guides/add-new-service.md` - 새 서비스 추가 절차
- `$CLAUDE_PLUGIN_ROOT/docs/reference/stacks-registry.md` - 등록된 스택 목록
- `$CLAUDE_PLUGIN_ROOT/docs/reference/ports.md` - 포트 할당표

## Deployment Backends (확장 가능)

| Backend | Status | Use Case |
|---------|--------|----------|
| Docker Compose + Portainer GitOps | **현재 사용** | 홈랩 단일/소수 노드 |
| Helm + k3s/k8s | 확장 예정 | 멀티 노드, 스케일링 필요 시 |
| Terraform/Terragrunt | 확장 예정 | 클라우드/IaC 프로비저닝 |

## Core Process (범용)

Backend 무관하게 적용되는 4단계:

1. **서비스 정의** — compose 파일 / manifest / Helm chart 작성
2. **인그레스 설정** — reverse proxy labels / ingress rules 추가
3. **오케스트레이터 등록** — GitOps source에 스택 등록
4. **배포 실행** — Git push → auto-deploy (또는 수동 trigger)

## Current Implementation: Docker Compose + Portainer GitOps

### Compose 파일 위치 규칙

```
infra/{device}/{service}/docker-compose.yml      # 인프라 스택
services/{device}/{service}/docker-compose.yml    # 서비스 스택
```

- `infra/` — 네트워크, 시크릿, 오케스트레이션 등 플랫폼 계층
- `services/` — 애플리케이션 계층

### 하이브리드 GitOps 구조

하나의 repo를 GitHub ↔ GitLab CE 미러링:

```
my-devops repo ── GitHub ◄──mirror──► GitLab CE (SSOT)
                     │                    │
           Portainer 인프라 스택    Portainer 서비스 스택
             (infra/ 폴더)          (services/ 폴더)
```

| 폴더 | Portainer 소스 | 이유 |
|------|---------------|------|
| `infra/` | **GitHub** | 순환 의존성 해소 — GitLab/NAS 다운에도 배포 가능 |
| `services/` | **GitLab CE** | GitLab CI 빌드/배포 자동화 연동 |

### portainer-gitops.sh 사용법

```bash
./scripts/portainer-gitops.sh list          # 스택 목록
./scripts/portainer-gitops.sh create <name> # 생성
./scripts/portainer-gitops.sh update <name> # 업데이트 (delete+recreate, 주의!)
```

**주의:** `update`는 delete+recreate 방식이므로 데이터 손실 가능성 확인 필요.

### Bootstrap 레이어 개념

서비스 간 의존성에 따른 배포 순서:

| Layer | 설명 | 배포 방식 |
|-------|------|----------|
| **1** | 오케스트레이터 (Portainer + Agents) | 수동 compose |
| **2** | 시크릿 저장소 (Vault 등) | Portainer 스택 |
| **3** | Vault 무관 서비스 | Portainer GitOps |
| **4** | Vault 의존 서비스 | Portainer GitOps (Vault Agent sidecar) |

### Docker 정리

```bash
./scripts/docker-cleanup.sh          # 로컬
./scripts/docker-cleanup.sh all      # 모든 디바이스 (SSH)
```

### 포트 할당 규칙

- 호스트 포트: **20000-29999** 범위 사용
- 컨테이너 내부 포트: 원본 유지 (예: `{PORT}:3000`)
- 할당 전 반드시 기존 포트표 확인 → `$CLAUDE_PLUGIN_ROOT/docs/reference/ports.md`

## Guard Rails

- **영속 데이터 경로는 반드시 사용자에게 확인** — 디바이스마다 저장 정책이 다름
- **NAS 볼륨** — 영속 데이터는 절대경로 호스트 마운트, 런타임 전용은 named volume OK
- **Docker 네트워크 이름** — 디바이스별로 다름 (CLAUDE.md 참조)
- **새 서비스 추가 절차** — 상세: `$CLAUDE_PLUGIN_ROOT/docs/guides/add-new-service.md`

## Domain Data References

> 아래 문서에서 디바이스별 IP, 포트 할당, 스택 목록 등 도메인 데이터를 참조하세요.

| 참조 | 경로 |
|------|------|
| 포트 할당표 | `$CLAUDE_PLUGIN_ROOT/docs/reference/ports.md` |
| 등록된 스택 목록 | `$CLAUDE_PLUGIN_ROOT/docs/reference/stacks-registry.md` |
| 새 서비스 추가 가이드 | `$CLAUDE_PLUGIN_ROOT/docs/guides/add-new-service.md` |

## Templates

→ `$CLAUDE_PLUGIN_ROOT/skills/deploy-stack/templates/` 참조
