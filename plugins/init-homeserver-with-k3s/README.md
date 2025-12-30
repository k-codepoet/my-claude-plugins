# init-homeserver-with-k3s

Linux Ubuntu 홈서버에 K3s를 설치하고 IaC(Infrastructure as Code) 환경을 자동 구성하는 Claude Code 플러그인입니다.

## Features

- **환경 감지**: 기존 Kubernetes 환경(microk8s, minikube, k3s, docker desktop k8s) 자동 감지
- **K3s 설치**: 충돌 환경이 없으면 K3s 기본 설치 수행
- **워커 노드 추가**: 기존 마스터 노드에 추가 워커 노드 조인 (마스터 확인 필수)
- **Git Repo 구성**: `~/k3s` 폴더에 Git 저장소 자동 구성
- **스냅샷**: 클러스터 상태를 YAML 매니페스트로 내보내기
- **복원**: 저장된 스냅샷에서 클러스터 복원

## Commands

- `/init-homeserver-with-k3s:init` - K3s 설치 및 IaC 환경 초기화 (마스터 노드)
- `/init-homeserver-with-k3s:join-node` - 기존 K3s 클러스터에 워커 노드로 조인
- `/init-homeserver-with-k3s:snapshot` - 현재 클러스터 상태 스냅샷 생성
- `/init-homeserver-with-k3s:restore` - 저장된 스냅샷에서 복원

## Natural Language Triggers

에이전트가 다음과 같은 요청에 자동으로 반응합니다:
- "홈서버 구축해줘", "홈서버 환경 만들어줘"
- "쿠버네티스 환경 구축해줘", "K3s 설치해줘"
- "서버 세팅해줘", "서버 환경 초기화"
- "노드 추가해줘", "워커 노드 조인해줘", "K3s 클러스터에 참여시켜줘"

## Prerequisites

- Linux Ubuntu (18.04+)
- sudo 권한
- curl, git 설치됨

## Directory Structure

```
~/k3s/                          # 사용자 K3s 프로젝트
├── k3s/
│   ├── manifest/               # 네임스페이스별 매니페스트
│   └── helm/                   # Helm 차트 및 설정
├── scripts/
│   ├── snapshot-k3s.sh
│   └── restore-k3s.sh
└── .git/

plugins/init-homeserver-with-k3s/
├── snapshots/                  # 스냅샷 정보 (snapshot_{timestamp}.md)
└── ...
```

## Platform

- **Supported**: Linux Ubuntu
- **Not Supported**: macOS, Windows
