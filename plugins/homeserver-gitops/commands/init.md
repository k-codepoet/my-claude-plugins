---
description: Initialize K3s homeserver with IaC setup
allowed-tools: Read, Bash, Write, Glob, Grep
---

Use the k3s-homeserver skill to initialize a K3s cluster on this Linux Ubuntu homeserver.

## Prerequisites Check

1. Verify platform is Linux Ubuntu:
   - Check `uname -s` returns "Linux"
   - Check `/etc/os-release` contains Ubuntu

2. If not Linux Ubuntu, inform the user and stop.

## Workflow

### Step 1: Environment Detection

Check for existing Kubernetes installations:
- MicroK8s: `which microk8s`
- Minikube: `which minikube`
- K3s: `which k3s` or `/usr/local/bin/k3s`
- Docker Desktop K8s: `docker info 2>/dev/null | grep -i kubernetes`

If any found, warn user and ask whether to proceed.

### Step 2: IaC Repository Setup

First, initialize the IaC repository at `~/my-iac`:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-iac.sh"
```

This creates the extensible IaC structure with:
- K3s manifests and Helm configurations
- Docker Compose stacks (hostname-based, Portainer GitOps ready)
- Placeholders for Terraform, ArgoCD, Ansible

### Step 3: K3s Installation

Execute the installation script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-k3s.sh"
```

Wait for installation to complete and verify with:
- `kubectl get nodes`
- `kubectl cluster-info`

### Step 4: Initial Snapshot

Run snapshot to save initial cluster state:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-k3s.sh"
```

### Step 5: Git Commit

```bash
cd ~/my-iac
git add .
git commit -m "K3s cluster initialized

- Initial cluster state captured
- Ready for GitOps deployments"
```

## Completion

Report to user:
- K3s installation status
- IaC repository location (`~/my-iac`)
- Detected hostname (for docker-compose structure)
- Directory structure overview
- Next steps:
  - Add git remote: `cd ~/my-iac && git remote add origin <url>`
  - Deploy applications
  - Create snapshots regularly
  - Add docker-compose stacks for Portainer
