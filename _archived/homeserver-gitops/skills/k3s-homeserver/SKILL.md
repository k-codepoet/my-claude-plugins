---
description: K3s 홈서버 설정 스킬. 홈서버 구축, K3s 설치, Kubernetes 클러스터 구성, IaC 초기화, GitOps 설정, 스냅샷/복원 관련 질문에 사용합니다. Linux Ubuntu 전용입니다.
---

# K3s Homeserver Setup Skill

## Overview

This skill enables automated setup of K3s Kubernetes clusters on Linux Ubuntu homeservers with extensible Infrastructure as Code (IaC) management. It handles environment detection, K3s installation, Git repository configuration, Docker Compose GitOps for Portainer, and cluster state management through snapshots.

## Platform Requirement

**CRITICAL**: This skill is only for **Linux Ubuntu** systems. Before any operation:
1. Verify platform is Linux using `uname -s`
2. Verify distribution is Ubuntu using `lsb_release -d` or `/etc/os-release`
3. If not Linux Ubuntu, inform the user and stop

## Core Workflows

### 1. Environment Detection

Before K3s installation, detect existing Kubernetes environments to prevent conflicts:

```bash
# Check for existing Kubernetes installations
which microk8s    # MicroK8s
which minikube    # Minikube
which k3s         # K3s already installed
docker info 2>/dev/null | grep -i kubernetes  # Docker Desktop K8s
```

If any existing environment is detected:
- Inform the user about the detected environment
- Ask if they want to proceed (may cause conflicts)
- Stop if user declines

### 2. IaC Repository Setup

Initialize the IaC repository at `~/my-iac` using `$CLAUDE_PLUGIN_ROOT/scripts/init-iac.sh`:

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/init-iac.sh"
```

The script:
1. Detects the current machine's hostname
2. Creates extensible directory structure
3. Sets up hostname-based Docker Compose structure for Portainer GitOps
4. Initializes git repository with initial commit

This creates the following structure:

```
~/my-iac/
├── k3s/                          # Kubernetes configurations
│   ├── manifest/                 # K8s manifests (declarative)
│   └── helm/                     # Helm charts & values
│
├── {hostname}/                   # Docker Compose services (Portainer GitOps)
│
├── terraform/                    # Terraform infrastructure (placeholder)
│
└── argocd/                       # ArgoCD GitOps (placeholder)
```

### 3. K3s Installation (Master Node)

Execute the installation script at `$CLAUDE_PLUGIN_ROOT/scripts/install-k3s.sh`:

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-k3s.sh"
```

The script performs:
1. Platform verification (Linux Ubuntu only)
2. Existing Kubernetes environment detection
3. K3s installation via official script
4. kubeconfig setup for current user
5. Installation verification

Post-installation verification:
```bash
kubectl get nodes
kubectl cluster-info
```

### 4. Join Worker Node (Multi-Node Cluster)

**CRITICAL: This workflow MUST confirm master node details with the user before proceeding.**

To add a worker node to an existing K3s cluster:

#### Step 1: Confirm Master Node (MANDATORY)

Ask the user to provide:
1. **Master Node IP** - IP address of the K3s server
2. **Node Token** - From master: `sudo cat /var/lib/rancher/k3s/server/node-token`

#### Step 2: Verify Connectivity

```bash
# Test master node connectivity
ping -c 1 <MASTER_IP>

# Test K3s API port
timeout 5 bash -c "</dev/tcp/<MASTER_IP>/6443"
```

#### Step 3: Execute Join Script

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/join-node.sh" --master-ip <MASTER_IP> --token <TOKEN>
```

Options:
- `--master-ip IP`: Master node IP (required)
- `--token TOKEN`: Node token (will prompt if not provided)
- `--node-name NAME`: Custom node name (optional)

#### Step 4: Verify Join

On worker node:
```bash
sudo systemctl status k3s-agent
```

On master node:
```bash
kubectl get nodes
```

### 5. Docker Compose for Portainer GitOps

The `{hostname}/` directory enables Portainer GitOps:

1. Each service has its own directory:
   ```
   {hostname}/
   ├── traefik/
   │   └── docker-compose.yml
   ├── portainer/
   │   └── docker-compose.yml
   └── monitoring/
       └── docker-compose.yml
   ```

2. In Portainer, configure GitOps:
   - Go to **Stacks** → **Add Stack** → **Git Repository**
   - Repository URL: your Git repo URL
   - Compose path: `{hostname}/{service-name}/docker-compose.yml`
   - Enable auto-update for GitOps

### 6. Cluster Snapshot (Master Node Only)

Create a snapshot of the current cluster state using `$CLAUDE_PLUGIN_ROOT/scripts/snapshot-k3s.sh`:

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/snapshot-k3s.sh"
```

The script exports:
- **Namespaced resources**: deployments, services, configmaps, secrets, ingresses, PVCs, serviceaccounts, roles, rolebindings
- **Cluster resources**: namespaces, clusterroles, clusterrolebindings, PVs, storageclasses, ingressclasses
- **K3s-specific**: HelmCharts, HelmChartConfigs
- **CRDs**: Custom Resource Definitions (excluding K3s internal)

Output locations:
- Manifests: `~/my-iac/k3s/manifest/`
- Helm resources: `~/my-iac/k3s/helm/`
- Snapshot info: `~/my-iac/k3s/snapshots/snapshot_{timestamp}.md`

### 7. Cluster Restore

Restore cluster from saved manifests using `$CLAUDE_PLUGIN_ROOT/scripts/restore-k3s.sh`:

```bash
# Full restore
bash "$CLAUDE_PLUGIN_ROOT/scripts/restore-k3s.sh"

# Dry run (preview changes)
bash "$CLAUDE_PLUGIN_ROOT/scripts/restore-k3s.sh" --dry-run

# Restore specific namespace only
bash "$CLAUDE_PLUGIN_ROOT/scripts/restore-k3s.sh" -n <namespace>
```

Restoration order:
1. Cluster-scoped resources (namespaces first)
2. Namespaced resources (configmaps -> secrets -> services -> deployments)
3. Helm configurations

## Script Reference

All scripts located at `$CLAUDE_PLUGIN_ROOT/scripts/`:

| Script | Purpose |
|--------|---------|
| `init-iac.sh` | Initialize extensible IaC repository at ~/my-iac |
| `install-k3s.sh` | K3s master node installation with environment detection |
| `join-node.sh` | Join worker node to existing K3s cluster (requires master confirmation) |
| `snapshot-k3s.sh` | Export cluster state to YAML manifests |
| `restore-k3s.sh` | Apply saved manifests to cluster |

## Excluded Resources

The following are excluded from snapshots:
- **System namespaces**: kube-system, kube-public, kube-node-lease
- **Runtime fields**: creationTimestamp, resourceVersion, uid, generation, managedFields
- **K3s internal CRDs**: helmcharts, helmchartconfigs, addons

## Prerequisites

Required tools:
- `curl` - For K3s installation
- `git` - For repository management
- `sudo` - For K3s installation

Optional but recommended:
- `yq` - For YAML cleanup (runtime fields removal)
- `jq` - For JSON processing (Helm resource export)

## Error Handling

Common issues and solutions:

| Issue | Solution |
|-------|----------|
| kubectl not found | K3s installs its own kubectl, ensure PATH includes `/usr/local/bin` |
| Permission denied | Ensure user has sudo privileges for installation |
| Cluster unreachable | Check if K3s service is running: `sudo systemctl status k3s` |
| Manifests empty | Verify resources exist in cluster before snapshot |
| IaC directory not found | Run `/homeserver-gitops:bootstrap-iac` first |

## Additional Resources

### Reference Files

For detailed information, consult:
- **`references/k3s-architecture.md`** - K3s architecture and components

### Scripts

Working scripts in `scripts/`:
- **`init-iac.sh`** - IaC repository initialization
- **`install-k3s.sh`** - Complete K3s installation script
- **`join-node.sh`** - Worker node join script
- **`snapshot-k3s.sh`** - Cluster state export script
- **`restore-k3s.sh`** - Cluster state restore script
