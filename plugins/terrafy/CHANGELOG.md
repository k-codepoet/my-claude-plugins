# Changelog

All notable changes to the Terrafy plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2026-02-14

### Added
- **my-devops 통합** - 인프라 프로비저닝 + 앱 배포·운영 통합 플러그인으로 확장
- **skills/** - 운영 스킬 4개 추가 (my-devops `.claude/skills/`에서 harvest)
  - `deploy-stack/SKILL.md` - 서비스 스택 배포 (Portainer GitOps, docker-compose)
  - `secrets/SKILL.md` - Vault 시크릿 관리 (AppRole, Vault Agent sidecar)
  - `networking/SKILL.md` - 네트워크/라우팅 (Traefik chain, Split DNS, TLS)
  - `cicd/SKILL.md` - CI/CD 파이프라인 (GitLab CI, buildx multiplatform)
- **templates/** - 각 스킬별 템플릿 파일
  - deploy-stack: docker-compose.template.yml, portainer-app-stack.template.sh
  - secrets: vault-agent-sidecar.template.yml
  - networking: traefik-service-labels.template.yml
  - cicd: gitlab-ci.template.yml, dockerfile-multistage.template
- **scripts/** - 운영 스크립트 4개 추가
  - `portainer-gitops.sh` - Portainer 스택 CRUD (Hybrid GitOps 지원)
  - `docker-cleanup.sh` - Docker 정리 (로컬 + 리모트)
  - `gitlab-api.sh` - GitLab CE REST API 래퍼
  - `sync-scripts-to-minio.sh` - MinIO 스크립트 배포
- **docs/** - 운영 문서 27개 추가
  - architecture/ (4): current-structure, traefik-chain, dns-split, vault-agent
  - guides/ (6): hybrid-gitops, bootstrap, add-new-service, docker-maintenance, vault-cli, gitlab
  - reference/ (6): ports, secrets-structure, stack-notes, stacks-registry, deployed-services, docker-versions
  - machines/ (4): codepoet-mac-mini-1/2, codepoet-nas, codepoet-linux-1
  - services/ (7): adguard-home, cloudflared, gitlab-ce, portainer, traefik, vault, vaultwarden
- **references/** - 각 스킬별 참조 문서 (progressive disclosure)

### Changed
- **plugin.json** - version 4.0.0, description 확장, keywords 추가 (vault, secrets, cicd, gitlab, deploy, networking, dns)
- **agents/terrafy.md** - 운영 스킬/스크립트 참조 추가, 트리거 예시 확장
- **commands/help.md** - 배포·운영 섹션 추가 (deploy-stack, secrets, networking, cicd)
- **commands/howto.md** - 배포·운영 토픽 추가, 시작하기 가이드 확장

## [3.0.0] - 2026-02-14

### Changed
- **commands → skills 통합** - action commands를 삭제하고 skills로 일원화
  - `commands/setup.md` 삭제 (skills/setup/SKILL.md로 통합)
  - `commands/status.md` 삭제 (skills/status/SKILL.md로 통합)
  - `commands/init-ssh.md` 삭제 (skills/init-ssh/SKILL.md로 통합)
  - `commands/help.md`, `commands/howto.md`만 유지 (문서)
- **skills frontmatter 보강**
  - `setup/SKILL.md`: `allowed-tools: Bash, Read, Write` 추가
  - `status/SKILL.md`: `allowed-tools: Bash, Read` 추가
  - `init-ssh/SKILL.md`: `allowed-tools: Bash, Read` 추가
- **help.md 용어 변경** - "커맨드" → "기능"

## [2.1.0] - 2026-01-18

### Changed
- **help.md 재구성** - ASCII art 제거, 표준 형식으로 통일
  - 태그라인 + 한줄 설명
  - 커맨드 테이블 (카테고리별)
  - 역할 구조 표

### Added
- **howto.md 신규 생성** - 주제별 사용법과 예시
  - 인프라 관리 주제 (status, setup, init-ssh)
  - 구성 예시 (멀티노드, 싱글노드)
  - 시작하기 가이드

## [2.0.0] - 2026-01-17

### Changed
- **전면 재설계** - k3s 중심에서 Docker/Portainer 기반 홈서버 인프라로 전환
- **description 변경** - "물리 자원을 배포 가능한 API로 변환 - 홈서버 인프라 자동화"
- **keywords 변경** - infrastructure, homelab, docker, portainer, traefik, gitops, network, ssh, cluster

### Added
- **agents/terrafy.md** - 새로운 인프라 자동화 에이전트
- **commands/**
  - `init-ssh.md` - SSH 키 설정 및 배포
  - `setup.md` - 클러스터 설정 워크플로우
  - `status.md` - 클러스터 상태 확인 (개선)
  - `help.md` - 도움말 (개선)
- **skills/**
  - `init-ssh/SKILL.md` - SSH 초기화 스킬
  - `setup/SKILL.md` - 설정 워크플로우 스킬
  - `status/SKILL.md` - 상태 확인 스킬
- **scripts/** - 새로운 자동화 스크립트
  - `scan-host.sh`, `scan-network.sh` - 네트워크 스캔
  - `check-docker.sh`, `check-services.sh` - 서비스 상태 확인
  - `init-master.sh`, `add-node.sh` - 노드 관리
  - `install-gateway.sh`, `install-orchestrator.sh` - 컴포넌트 설치
  - `install-traefik-chain.sh`, `install-worker.sh` - 추가 설치
  - `remote-exec.sh`, `verify-cluster.sh` - 유틸리티
- **docs/** - 문서 디렉토리
- **_archived/** - 기존 1.x 파일 아카이브

### Removed
- `agents/infra-setup.md` - 기존 에이전트
- `commands/bootstrap.md` - 기존 부트스트랩 커맨드
- `skills/help/`, `skills/k3s/`, `skills/portainer/`, `skills/terraform/` - k3s 기반 스킬들
- k3s 관련 스크립트들 (install-k3s.sh, join-node.sh, snapshot-k3s.sh, restore-k3s.sh, init-iac.sh)

## [1.0.0] - 2026-01-03

### Added
- 초기 릴리즈 - k3s 기반 홈서버 인프라 자동화
- k3s 클러스터 설치, 노드 조인, 스냅샷/복원
- Portainer, Terraform 스킬
