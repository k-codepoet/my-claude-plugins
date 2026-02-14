# Harvest Scan Targets

harvest 스킬의 2단계(스캔)에서 탐색하는 파일/디렉토리 목록.

## 1차 스캔: 핵심 파일 (항상 탐색)

| 파일/패턴 | 카테고리 | 추출 대상 |
|-----------|----------|-----------|
| `CLAUDE.md` | all | 프로젝트 규칙, guard rails, 워크플로우 전체 |
| `AGENTS.md` | all | 위와 동일 (심링크 가능) |
| `README.md` | architecture, development | 프로젝트 개요, 설치 방법, 사용법 |
| `docs/**/*.md` | all | 아키텍처, 가이드, 참조 문서 |
| `scripts/**/*.{sh,py,js,ts}` | operations | 자동화 스크립트, CLI 도구 |
| `.claude/` | all | 기존 Claude Code 설정, 스킬, 에이전트 |

## 2차 스캔: CI/CD

| 파일/패턴 | 카테고리 | 추출 대상 |
|-----------|----------|-----------|
| `.github/workflows/*.yml` | ci-cd | GitHub Actions 파이프라인 |
| `.gitlab-ci.yml` | ci-cd | GitLab CI 파이프라인 |
| `Jenkinsfile` | ci-cd | Jenkins 파이프라인 |
| `.circleci/config.yml` | ci-cd | CircleCI 파이프라인 |
| `bitbucket-pipelines.yml` | ci-cd | Bitbucket Pipelines |
| `.github/CODEOWNERS` | development | 코드 소유권 |
| `.github/PULL_REQUEST_TEMPLATE.md` | development | PR 프로세스 |

## 3차 스캔: 인프라/컨테이너

| 파일/패턴 | 카테고리 | 추출 대상 |
|-----------|----------|-----------|
| `docker-compose*.yml` | infrastructure | 컨테이너 구성, 서비스 관계 |
| `Dockerfile*` | infrastructure | 빌드 패턴, 멀티스테이지 |
| `terraform/**/*.tf` | infrastructure | IaC 패턴 |
| `helm/**/*.yaml` | infrastructure | Kubernetes Helm charts |
| `k8s/**/*.yaml`, `kubernetes/**/*.yaml` | infrastructure | Kubernetes manifests |
| `ansible/**/*.yml` | infrastructure | Ansible playbooks |
| `pulumi/**/*` | infrastructure | Pulumi IaC |

## 4차 스캔: 빌드/개발 도구

| 파일/패턴 | 카테고리 | 추출 대상 |
|-----------|----------|-----------|
| `Makefile` | development | 빌드/개발 태스크 정의 |
| `package.json` | development | npm scripts, 의존성 관리 |
| `pyproject.toml`, `setup.py`, `setup.cfg` | development | Python 프로젝트 구조 |
| `go.mod` | development | Go 모듈 구조 |
| `Cargo.toml` | development | Rust 프로젝트 구조 |
| `pom.xml`, `build.gradle` | development | Java/Kotlin 빌드 |
| `turbo.json`, `nx.json` | development | 모노레포 구조 |
| `.eslintrc*`, `.prettierrc*` | development | 코드 스타일 규칙 |
| `.editorconfig` | development | 에디터 설정 |
| `tsconfig.json` | development | TypeScript 설정 |

## 5차 스캔: 보안/설정

| 파일/패턴 | 카테고리 | 추출 대상 |
|-----------|----------|-----------|
| `.env.example`, `.env.template` | security | 환경변수 구조 (값은 읽지 않음) |
| `vault*.hcl`, `vault*.json` | security | Vault 설정 |
| `config/**/*` | operations | 설정 관리 패턴 |
| `.sops.yaml` | security | Secret 암호화 |
| `renovate.json`, `.dependabot/config.yml` | operations | 의존성 자동 업데이트 |

## 6차 스캔: 모니터링/운영

| 파일/패턴 | 카테고리 | 추출 대상 |
|-----------|----------|-----------|
| `prometheus*.yml` | operations | 모니터링 설정 |
| `grafana/**/*` | operations | 대시보드 정의 |
| `alertmanager*.yml` | operations | 알림 규칙 |
| `nginx*.conf`, `traefik*.yml` | infrastructure | 리버스 프록시/라우팅 |
| `crontab`, `*.cron` | operations | 스케줄링 |

## 스캔 전략

1. **1차 스캔은 항상 실행** - 핵심 파일은 모든 repo에 적용
2. **2~6차는 1차 결과에 따라 선택적 실행** - 관련 파일이 없으면 건너뜀
3. **Glob으로 존재 여부 먼저 확인** → 존재하는 파일만 Read
4. **대용량 파일 처리**: 500줄 이상이면 처음 100줄 + 목차/구조만 파악
5. **바이너리/민감 파일 제외**: `.env` (값 있는), `*.key`, `*.pem` 등은 존재 여부만 기록
