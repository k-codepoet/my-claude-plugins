# Changelog

## [1.0.0] - 2024-12-30

### 🎉 Initial Release

Linux Ubuntu 홈서버를 위한 K3s & GitOps 설정 플러그인 첫 릴리스입니다.

### ✨ Features

#### 1. K3s 클러스터 관리
- 환경 감지 (microk8s, minikube, k3s, docker desktop k8s)
- K3s 자동 설치 (마스터 노드)
- 워커 노드 조인 기능
- 클러스터 스냅샷/복원

#### 2. 확장 가능한 IaC 디렉토리 구조
```
~/my-iac/                         # 기본 경로 (사용자 지정 가능)
├── k3s/
│   ├── manifest/                 # K8s 매니페스트 (선언형)
│   ├── helm/                     # Helm 차트 및 values
│   └── snapshots/                # 스냅샷 정보 파일
├── {hostname}/                   # Docker Compose 서비스 (호스트명 자동 감지)
├── terraform/                    # Terraform 인프라 (placeholder)
└── argocd/                       # ArgoCD GitOps (placeholder)
```

#### 3. 커맨드
- `/homeserver-gitops:help` - 도움말 표시
- `/homeserver-gitops:init` - K3s + IaC 전체 초기화
- `/homeserver-gitops:init-iac` - IaC 저장소만 초기화
- `/homeserver-gitops:join-node` - 워커 노드 조인
- `/homeserver-gitops:snapshot` - 클러스터 스냅샷
- `/homeserver-gitops:restore` - 스냅샷 복원

#### 4. 사용자 지정 디렉토리 지원
- 모든 스크립트에 `-d` / `--directory` 옵션
- 기본값: `~/my-iac`

```bash
# 기본 경로 사용
/homeserver-gitops:init-iac

# 사용자 지정 경로
/homeserver-gitops:init-iac -d ~/projects/my-infrastructure
/homeserver-gitops:snapshot -d ~/projects/my-infrastructure
```

#### 5. Portainer GitOps 지원
- 호스트명 기반 Docker Compose 구조
- Portainer 스택 GitOps와 호환

#### 6. 자연어 에이전트 트리거
- "홈서버 구축해줘", "K3s 설치해줘"
- "IaC 초기화해줘", "GitOps 구조 만들어줘"
- "노드 추가해줘", "스냅샷 만들어줘"

### 📁 Plugin Structure

```
plugins/homeserver-gitops/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   └── homeserver-setup.md
├── commands/
│   ├── help.md
│   ├── init.md
│   ├── init-iac.md
│   ├── join-node.md
│   ├── snapshot.md
│   └── restore.md
├── scripts/
│   ├── init-iac.sh
│   ├── install-k3s.sh
│   ├── join-node.sh
│   ├── snapshot-k3s.sh
│   └── restore-k3s.sh
├── skills/
│   └── k3s-homeserver/
│       ├── SKILL.md
│       └── references/
│           └── k3s-architecture.md
├── CHANGELOG.md
└── README.md
```

### 📋 Prerequisites

- Linux Ubuntu 18.04+
- sudo 권한
- curl, git 설치됨
- (선택) yq, jq
