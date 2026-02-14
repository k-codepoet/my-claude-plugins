---
name: cicd
description: "CI/CD, 파이프라인, buildx, 멀티플랫폼, GitLab, runner, glab, MR, registry, gitlab-ci, GitHub Actions, ArgoCD 관련 작업"
allowed-tools: Bash, Read, Write
---

# CI/CD Pipeline

코드 빌드 → 레지스트리 push → 매니페스트 업데이트 → 자동 배포 파이프라인.

## CI/CD Backends

| Backend | 상태 | 설명 |
|---------|------|------|
| **GitLab CI + Portainer GitOps polling** | 현재 사용 | Self-hosted GitLab CI + buildx + Portainer 5분 polling |
| GitHub Actions + ArgoCD | 확장 예정 | k8s 전환 시 |
| GitLab CI + Flux/ArgoCD on k8s | 확장 예정 | GitOps k8s 방식 |

## Core Process (범용)

CI/CD backend에 무관하게 적용되는 빌드-배포 흐름:

```
1. Build     → 멀티플랫폼 컨테이너 이미지 (buildx arm64+amd64)
2. Push      → 컨테이너 레지스트리
3. Update    → 배포 매니페스트(compose/chart)의 이미지 태그 업데이트
4. Deploy    → 오케스트레이터가 변경 감지 → 자동 재배포
```

### 멀티플랫폼 빌드 (buildx)

홈랩은 arm64 + amd64 혼합 환경 → **buildx 멀티플랫폼 빌드 필수**:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t {REGISTRY}/{IMAGE}:{TAG} \
  --push .
```

- arm64 네이티브 Runner에서 빌드 권장 (amd64 QEMU 에뮬레이션이 반대보다 빠름)
- QEMU arm64 에뮬레이션은 Rust 빌드 등 무거운 작업에서 비현실적으로 느림

### 앱 서비스 분리 원칙

```
{INFRA_REPO}/       ← 인프라/플랫폼 repo (IaC)
{APP_REPO}/         ← 별도 repo → 오케스트레이터 Stack으로 배포
```

앱 서비스는 인프라 repo와 분리. CI에서 빌드/push, GitOps가 배포.

## Current Implementation: GitLab CI + buildx + Portainer GitOps

### Pipeline Flow

```
태그 push (v*) → build stage → deploy stage → Portainer polling → 재배포
                  |                |
                  +- buildx 멀티플랫폼  +- docker-compose.yml 태그 업데이트
                  +- Registry push     +- git push [skip ci]
```

### 필수 파일 (각 앱 repo)

| 파일 | 용도 |
|------|------|
| `Dockerfile` | 멀티스테이지 빌드 (템플릿: `$CLAUDE_PLUGIN_ROOT/skills/cicd/templates/dockerfile-multistage.template`) |
| `.gitlab-ci.yml` | build + deploy stages (템플릿: `$CLAUDE_PLUGIN_ROOT/skills/cicd/templates/gitlab-ci.template.yml`) |
| `docker-compose.yml` | Traefik labels + image 태그 (Portainer GitOps 대상) |

### Runner 관리 패턴

| Runner 유형 | 아키텍처 | 용도 | CI tags |
|------------|---------|------|---------|
| Build Runner | arm64 native | Docker buildx 멀티플랫폼 (arm64 네이티브 + amd64 QEMU) | `tags: [{BUILD_RUNNER_TAG}]` |
| General Runner | amd64 | 경량 작업 (deploy, test, lint) | 미지정 또는 `tags: [{GENERAL_RUNNER_TAG}]` |

- 두 Runner 모두 `run_untagged: true` → tag 없는 job은 양쪽 모두 수용
- **빌드(buildx)는 반드시 arm64 Runner** 지정 → 네이티브 빌드 + amd64 QEMU
- **경량 작업은 tag 미지정** → 어느 Runner든 실행 가능

### Runner 네트워크 패턴

Runner가 Git 서버/Registry에 접근하는 표준 패턴:

```
Runner → HTTPS → Reverse Proxy (TLS 종료) → Git 서버 / Registry
```

- `url`, `clone_url` 모두 HTTPS 도메인 사용 (IP 직접 접근 금지)
- DinD `extra_hosts`: Git 서버/Registry 도메인 → Reverse Proxy IP (TLS 종료 지점)
- DinD `dns`: VPN DNS 또는 public DNS
- **NAS:443 등 시스템 포트를 점유하는 디바이스 IP는 extra_hosts에 사용 금지** (인증서 불일치)

```toml
# config.toml 패턴
[[runners]]
  clone_url = "https://{GIT_DOMAIN}"
  [runners.docker]
    extra_hosts = ["{GIT_DOMAIN}:{PROXY_IP}", "{REGISTRY_DOMAIN}:{PROXY_IP}"]
    dns = ["{VPN_DNS}", "{PUBLIC_DNS}"]
```

### Registry Workflow

```bash
# 로그인 (CI에서는 CI_REGISTRY_USER/CI_REGISTRY_PASSWORD 자동 주입)
docker login {REGISTRY_DOMAIN} -u {USERNAME}

# 빌드 + Push
docker buildx build --platform linux/amd64,linux/arm64 \
  -t {REGISTRY_DOMAIN}/{GROUP}/{PROJECT}/{IMAGE}:{TAG} \
  --push .

# Pull
docker pull {REGISTRY_DOMAIN}/{GROUP}/{PROJECT}/{IMAGE}:{TAG}
```

### GitLab API / CLI

#### API Helper Script

```bash
$CLAUDE_PLUGIN_ROOT/scripts/gitlab-api.sh test                    # 연결 테스트
$CLAUDE_PLUGIN_ROOT/scripts/gitlab-api.sh projects list           # 프로젝트 목록
$CLAUDE_PLUGIN_ROOT/scripts/gitlab-api.sh mrs list {PROJECT_ID}   # MR 목록
$CLAUDE_PLUGIN_ROOT/scripts/gitlab-api.sh mrs create {PROJECT_ID} --source {BRANCH} --target main --title "title"
```

- Vault에서 PAT를 자동 로드 (`VAULT_TOKEN` 필요)
- 또는 환경변수 직접 설정: `GITLAB_URL`, `GITLAB_TOKEN`

#### glab CLI

```bash
# 대화형 로그인
glab auth login --hostname {GIT_DOMAIN}

# 프로젝트 조회
glab repo view {GROUP}/{PROJECT} --output json

# MR 생성
glab mr create --source-branch {BRANCH} --target-branch main --title "title" --repo {GROUP}/{PROJECT}

# MR 목록/조회
glab mr list --output json --repo {GROUP}/{PROJECT}
glab mr view {IID} --output json --repo {GROUP}/{PROJECT}
```

- 설정 파일: Linux `~/.config/glab-cli/config.yml`, macOS `~/Library/Application Support/glab-cli/config.yml`
- PAT 필요 스코프: `api`, `write_repository`
- 일부 디바이스는 TLS 경로 문제로 glab 미사용 → `$CLAUDE_PLUGIN_ROOT/scripts/gitlab-api.sh` (REST API) 대체

### 앱 서비스 Portainer 등록 (초기 1회)

앱 서비스는 별도 Git repo이므로 인프라 GitOps 스크립트가 아닌 직접 API 호출:

```bash
curl -s -k -X POST \
  -H "X-API-Key: $PORTAINER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "{SERVICE}",
    "repositoryURL": "https://{GIT_DOMAIN}/{GROUP}/{PROJECT}.git",
    "repositoryReferenceName": "refs/heads/main",
    "composeFile": "docker-compose.yml",
    "autoUpdate": {"interval": "5m"},
    "repositoryAuthentication": true,
    "repositoryUsername": "gitlab-ci-token",
    "repositoryPassword": "{GIT_PAT}"
  }' \
  "${PORTAINER_URL}/api/stacks/create/standalone/repository?endpointId={ENDPOINT_ID}"
```

### GitOps Polling Mechanism

Portainer가 Git repo를 주기적으로 polling (기본 5분):
1. CI가 `docker-compose.yml`의 이미지 태그를 새 버전으로 업데이트
2. `git push [skip ci]` (deploy stage에서 무한 루프 방지)
3. Portainer가 다음 polling 시 변경 감지 → compose 기반 재배포

### Monorepo 태그 기반 빌드

monorepo에서 패키지별 태그로 빌드 트리거:

```
태그 규칙: {package-path}/{version}
예: web/react-router-spa/v2026.02.08
```

```yaml
build-{package}:
  extends: .docker-build
  rules:
    - if: '$CI_COMMIT_TAG =~ /^{package-path}\/v.+/'
  variables:
    PKG_DIR: {package-path}
    IMAGE_NAME: ${REGISTRY_URL}/{GROUP}/{PROJECT}/{package-path}
  script:
    - VERSION=${CI_COMMIT_TAG##*/}
    - docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest ${PKG_DIR}
    - docker push ${IMAGE_NAME}:${VERSION}
    - docker push ${IMAGE_NAME}:latest
```

## Guard Rails

### 빌드

- **buildx 멀티플랫폼(arm64+amd64) 빌드 필수** — 혼합 아키텍처 환경
- arm64 Runner에서 빌드 → amd64 QEMU이 반대보다 빠름

### 배포

- deploy stage에서 manifest git push 시 **반드시 `[skip ci]`** 포함 (무한 루프 방지)
- GitLab 프로젝트 설정: `ci_push_repository_for_job_token_allowed: true` (deploy stage git push 권한)

### Runner

- `extra_hosts`에 **시스템 포트 점유 디바이스 IP 사용 금지** (인증서 불일치)
- config.toml은 호스트 마운트에 저장 → Stack 재배포해도 유지
- Runner 등록 후 config.toml 수동 편집 필요 (`clone_url`, `extra_hosts`, `dns`)

## Domain Data References

구체적인 URL, Runner 구성, SSH 설정 등은 아래 문서 참조:

- `$CLAUDE_PLUGIN_ROOT/skills/cicd/references/gitlab.md` — GitLab CE + Registry + CI/CD Runner 설정 전문
- `$CLAUDE_PLUGIN_ROOT/skills/cicd/references/gitlab-ce.md` — GitLab CE 운영 노트

## Templates

- `$CLAUDE_PLUGIN_ROOT/skills/cicd/templates/gitlab-ci.template.yml` — 멀티플랫폼 build + deploy 파이프라인
- `$CLAUDE_PLUGIN_ROOT/skills/cicd/templates/dockerfile-multistage.template` — 멀티플랫폼 Dockerfile 템플릿
