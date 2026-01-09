---
name: k3s
description: 쿠버네티스(K3s) 환경 구축 스킬. 쿠버네티스 클러스터 설치, Pod 배포, Helm 차트 사용, GitOps 설정이 필요할 때 사용합니다. Linux Ubuntu 전용입니다.
---

# K3s Setup Skill

## Overview

K3s 기반 쿠버네티스 클러스터를 구축합니다. 경량 Kubernetes로 홈서버, 엣지 컴퓨팅, 개발 환경에 적합합니다.

## Platform Requirement

**Linux Ubuntu 전용**. 작업 전 반드시 확인:
1. `uname -s` → Linux
2. `/etc/os-release` → Ubuntu

## Trigger Context

사용자가 다음과 같은 맥락일 때 이 스킬 활성화:
- "쿠버네티스 환경 구축해줘"
- "k8s 클러스터 필요해"
- "Pod 배포할 환경 만들어줘"
- "Helm 차트 배포하고 싶어"
- "GitOps 설정해줘"
- "k3s 설치해줘"

## Core Workflows

### 1. Environment Detection

K3s 설치 전 기존 Kubernetes 환경 감지:

```bash
which microk8s    # MicroK8s
which minikube    # Minikube
which k3s         # K3s already installed
docker info 2>/dev/null | grep -i kubernetes  # Docker Desktop K8s
```

충돌 가능성 있으면 사용자에게 경고 후 확인.

### 2. K3s Installation (Master Node)

스크립트 실행:
```bash
bash "$CLAUDE_PLUGIN_ROOT/skills/k3s/scripts/install-k3s.sh"
```

수행 작업:
1. 플랫폼 검증 (Linux Ubuntu)
2. 기존 K8s 환경 감지
3. K3s 공식 스크립트로 설치
4. kubeconfig 설정
5. 설치 검증

설치 후 확인:
```bash
kubectl get nodes
kubectl cluster-info
```

### 3. Join Worker Node (Multi-Node)

**CRITICAL**: 마스터 노드 정보 반드시 확인 후 진행

#### Step 1: 마스터 정보 확인 (필수)
- **Master IP**: K3s 서버 IP
- **Node Token**: `sudo cat /var/lib/rancher/k3s/server/node-token`

#### Step 2: 연결 테스트
```bash
ping -c 1 <MASTER_IP>
timeout 5 bash -c "</dev/tcp/<MASTER_IP>/6443"
```

#### Step 3: 조인 실행
```bash
bash "$CLAUDE_PLUGIN_ROOT/skills/k3s/scripts/join-node.sh" --master-ip <IP> --token <TOKEN>
```

#### Step 4: 검증
```bash
# 워커 노드에서
sudo systemctl status k3s-agent

# 마스터 노드에서
kubectl get nodes
```

### 4. IaC Repository Setup

IaC 저장소 초기화:
```bash
bash "$CLAUDE_PLUGIN_ROOT/skills/k3s/scripts/init-iac.sh"
```

생성되는 구조:
```
~/my-iac/
├── k3s/
│   ├── manifest/     # K8s manifests
│   └── helm/         # Helm charts
├── {hostname}/       # Docker Compose (Portainer GitOps)
├── terraform/        # Terraform (placeholder)
└── argocd/           # ArgoCD (placeholder)
```

### 5. Cluster Snapshot

클러스터 상태 내보내기:
```bash
bash "$CLAUDE_PLUGIN_ROOT/skills/k3s/scripts/snapshot-k3s.sh"
```

내보내는 리소스:
- Namespaced: deployments, services, configmaps, secrets, ingresses, PVCs
- Cluster: namespaces, clusterroles, PVs, storageclasses
- K3s-specific: HelmCharts, HelmChartConfigs
- CRDs (K3s 내부 제외)

출력 위치:
- Manifests: `~/my-iac/k3s/manifest/`
- Helm: `~/my-iac/k3s/helm/`
- Info: `~/my-iac/k3s/snapshots/snapshot_{timestamp}.md`

### 6. Cluster Restore

저장된 매니페스트에서 복원:
```bash
# 전체 복원
bash "$CLAUDE_PLUGIN_ROOT/skills/k3s/scripts/restore-k3s.sh"

# 미리보기
bash "$CLAUDE_PLUGIN_ROOT/skills/k3s/scripts/restore-k3s.sh" --dry-run

# 특정 네임스페이스만
bash "$CLAUDE_PLUGIN_ROOT/skills/k3s/scripts/restore-k3s.sh" -n <namespace>
```

## Script Reference

| Script | Purpose |
|--------|---------|
| `install-k3s.sh` | K3s 마스터 노드 설치 |
| `join-node.sh` | 워커 노드 조인 |
| `init-iac.sh` | IaC 저장소 초기화 |
| `snapshot-k3s.sh` | 클러스터 상태 내보내기 |
| `restore-k3s.sh` | 매니페스트에서 복원 |

## Prerequisites

필수:
- `curl` - K3s 설치
- `git` - 저장소 관리
- `sudo` - 설치 권한

권장:
- `yq` - YAML 처리
- `jq` - JSON 처리

## Error Handling

| Issue | Solution |
|-------|----------|
| kubectl not found | PATH에 `/usr/local/bin` 포함 확인 |
| Permission denied | sudo 권한 확인 |
| Cluster unreachable | `sudo systemctl status k3s` |
| IaC not found | `/terrafy:bootstrap` 먼저 실행 |

## Additional Resources

- `references/k3s-architecture.md` - K3s 아키텍처 상세
