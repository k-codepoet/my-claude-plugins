---
name: status
description: 현재 인프라 상태 확인
---

현재 인프라 환경 상태를 확인합니다.

## 확인 항목

### 1. IaC 저장소
```bash
ls -la ~/my-iac/
```

### 2. Docker 상태
```bash
docker --version
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 3. Kubernetes (K3s) 상태
```bash
kubectl get nodes 2>/dev/null || echo "K3s not installed"
kubectl get pods -A 2>/dev/null | head -20
```

### 4. Portainer 상태
```bash
docker ps --filter "name=portainer" --format "{{.Names}}: {{.Status}}"
```

## 출력 형식

```
=== Terrafy Status ===

IaC Repository: ~/my-iac/
├── k3s/           [OK]
├── {hostname}/    [OK]
├── terraform/     [placeholder]
└── argocd/        [placeholder]

Docker: v24.0.7
└── Running containers: 3

Kubernetes (K3s): v1.28.5+k3s1
├── Nodes: 1 Ready
└── Pods: 15 Running

Portainer: Running
└── URL: https://localhost:9443
```
