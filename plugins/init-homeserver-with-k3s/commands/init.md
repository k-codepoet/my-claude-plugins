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

### Step 2: K3s Installation

Execute the installation script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-k3s.sh"
```

Wait for installation to complete and verify with:
- `kubectl get nodes`
- `kubectl cluster-info`

### Step 3: IaC Repository Setup

Create the IaC repository at `~/k3s`:

```bash
mkdir -p ~/k3s/{k3s/{manifest,helm},scripts}
cd ~/k3s && git init
```

Copy management scripts from plugin:
```bash
cp "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-k3s.sh" ~/k3s/scripts/
cp "${CLAUDE_PLUGIN_ROOT}/scripts/restore-k3s.sh" ~/k3s/scripts/
chmod +x ~/k3s/scripts/*.sh
```

### Step 4: Initial Snapshot

Run snapshot to save initial cluster state:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-k3s.sh"
```

### Step 5: Initial Git Commit

```bash
cd ~/k3s
git add .
git commit -m "Initial K3s IaC setup

- K3s cluster initialized
- Snapshot and restore scripts configured
- Initial cluster state captured"
```

## Completion

Report to user:
- K3s installation status
- IaC repository location (`~/k3s`)
- Available scripts
- Next steps (deploy applications, create snapshots)
