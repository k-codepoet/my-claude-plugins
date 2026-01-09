# homeserver-gitops

Linux Ubuntu 홈서버에 K3s를 설치하고 IaC(Infrastructure as Code) 환경을 자동 구성하는 Claude Code 플러그인입니다.

## Features

- **환경 감지**: 기존 Kubernetes 환경(microk8s, minikube, k3s, docker desktop k8s) 자동 감지
- **K3s 설치**: 충돌 환경이 없으면 K3s 기본 설치 수행
- **워커 노드 추가**: 기존 마스터 노드에 추가 워커 노드 조인 (마스터 확인 필수)
- **IaC 저장소**: `~/my-iac` 폴더에 확장 가능한 GitOps 구조 자동 구성
- **Docker Compose**: 호스트명 기반 docker-compose 구조 (Portainer GitOps 지원)
- **스냅샷**: 클러스터 상태를 YAML 매니페스트로 내보내기
- **복원**: 저장된 스냅샷에서 클러스터 복원

## Commands

- `/homeserver-gitops:help` - 도움말 및 사용법 표시
- `/homeserver-gitops:bootstrap` - K3s 설치 및 IaC 환경 초기화 (마스터 노드)
- `/homeserver-gitops:bootstrap-iac` - IaC 저장소만 초기화 (K3s 없이)
- `/homeserver-gitops:join-node` - 기존 K3s 클러스터에 워커 노드로 조인
- `/homeserver-gitops:snapshot` - 현재 클러스터 상태 스냅샷 생성
- `/homeserver-gitops:restore` - 저장된 스냅샷에서 복원

## Directory Structure

```
~/my-iac/                           # IaC 프로젝트 루트
├── k3s/                            # Kubernetes (K3s) 구성
│   ├── manifest/                   # K8s 매니페스트 (선언형)
│   └── helm/                       # Helm 차트 및 values
│
├── {hostname}/                     # Docker Compose 서비스 (호스트별)
│                                   # Portainer GitOps용
│
├── terraform/                      # Terraform 인프라 프로비저닝
│
└── argocd/                         # ArgoCD GitOps 구성
```

## Platform

- **Supported**: Linux Ubuntu
- **Not Supported**: macOS, Windows
