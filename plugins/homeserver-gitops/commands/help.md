---
name: help
description: Show available commands and usage for homeserver-gitops plugin
allowed-tools: Read
---

# homeserver-gitops Plugin Help

Display this help information to the user.

## Available Commands

| Command | Description |
|---------|-------------|
| `/homeserver-gitops:init` | K3s 설치 + IaC 환경 전체 초기화 (마스터 노드) |
| `/homeserver-gitops:init-iac` | IaC 저장소만 초기화 (K3s 없이) |
| `/homeserver-gitops:join-node` | 기존 K3s 클러스터에 워커 노드로 조인 |
| `/homeserver-gitops:snapshot` | 현재 클러스터 상태 스냅샷 생성 |
| `/homeserver-gitops:restore` | 저장된 스냅샷에서 복원 |
| `/homeserver-gitops:help` | 이 도움말 표시 |

## Common Options

모든 IaC 관련 커맨드는 사용자 지정 경로를 지원합니다:

```
-d, --directory <path>    IaC 저장소 경로 (기본값: ~/my-iac)
```

## Usage Examples

### 1. 홈서버 전체 설정 (K3s + IaC)
```bash
/homeserver-gitops:init
```

### 2. IaC 저장소만 초기화
```bash
# 기본 경로 ~/my-iac
/homeserver-gitops:init-iac

# 사용자 지정 경로
/homeserver-gitops:init-iac -d ~/projects/my-infrastructure
```

### 3. 워커 노드 추가
```bash
/homeserver-gitops:join-node --master-ip 192.168.1.100
```

### 4. 클러스터 스냅샷
```bash
# 기본 경로
/homeserver-gitops:snapshot

# 사용자 지정 경로
/homeserver-gitops:snapshot -d ~/projects/my-infrastructure
```

### 5. 클러스터 복원
```bash
# 미리보기 (dry-run)
/homeserver-gitops:restore --dry-run

# 실제 복원
/homeserver-gitops:restore

# 특정 네임스페이스만 복원
/homeserver-gitops:restore -n default
```

## IaC Directory Structure

```
~/my-iac/                           # IaC 프로젝트 루트 (사용자 지정 가능)
├── k3s/                            # Kubernetes (K3s) 구성
│   ├── manifest/                   # K8s 매니페스트 (선언형)
│   ├── helm/                       # Helm 차트 및 values
│   └── snapshots/                  # 스냅샷 정보 파일
│
├── {hostname}/                     # Docker Compose 서비스 (호스트별)
│                                   # Portainer GitOps용
│
├── terraform/                      # Terraform 인프라 프로비저닝
│
└── argocd/                         # ArgoCD GitOps 구성
```

## Prerequisites

- **Platform**: Linux Ubuntu 18.04+
- **Required**: sudo, curl, git
- **Optional**: yq, jq (YAML/JSON 처리용)

## Natural Language Support

에이전트가 다음과 같은 자연어 요청에 자동으로 반응합니다:

- "홈서버 구축해줘", "K3s 설치해줘"
- "홈랩 구축하고 싶어", "서버 환경 초기화해줘"
- "IaC 초기화해줘", "GitOps 구조 만들어줘"
- "노드 추가해줘", "워커 노드 조인해줘"
- "스냅샷 만들어줘", "클러스터 백업해줘"

## More Information

- Plugin Version: 1.0.0
- GitHub: https://github.com/k-codepoet/my-claude-plugins
