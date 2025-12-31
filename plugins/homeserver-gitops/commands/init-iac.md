---
name: init-iac
description: Initialize IaC repository with extensible structure for GitOps
argument-hint: [-d directory]
allowed-tools: Read, Bash, Write
---

Use this command to initialize the IaC (Infrastructure as Code) repository.

## What This Command Does

1. Creates the IaC directory structure (default: `~/my-iac`)
2. Detects the current machine's hostname
3. Sets up directories for:
   - `k3s/manifest/` - Kubernetes manifests (declarative)
   - `k3s/helm/` - Helm charts & values
   - `{hostname}/` - Docker Compose services (Portainer GitOps ready)
   - `terraform/` - Terraform infrastructure (placeholder)
   - `argocd/` - ArgoCD GitOps (placeholder)
4. Initializes a Git repository with initial commit

## Arguments

- `-d <directory>` or `--directory <directory>`: Custom IaC directory path (default: `~/my-iac`)

## Prerequisites Check

1. Verify git is installed:
   ```bash
   git --version
   ```

2. Check if target directory already exists

3. If directory exists with .git, ask user if they want to proceed.

## Workflow

### Step 1: Execute Init Script

Run the initialization script:

Default path:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-iac.sh"
```

Custom path:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-iac.sh" -d /path/to/custom/iac
```

### Step 2: Verify Results

Check the created structure:
```bash
tree <iac-directory> -L 2 2>/dev/null || find <iac-directory> -type d | head -20
```

### Step 3: Report Summary

Report to user:
- IaC root location
- Detected hostname
- Created directories
- Git repository status
- Next steps (add remote, create snapshots, etc.)

## Directory Structure Created

```
<iac-directory>/
├── k3s/
│   ├── manifest/                 # K8s manifests (declarative)
│   └── helm/                     # Helm charts & values
├── {hostname}/                   # Docker Compose services (Portainer GitOps)
├── terraform/                    # Terraform infrastructure (placeholder)
└── argocd/                       # ArgoCD GitOps (placeholder)
```

## Examples

```bash
# Default directory ~/my-iac
/homeserver-gitops:init-iac

# Custom directory
/homeserver-gitops:init-iac -d ~/projects/my-infrastructure

# Absolute path
/homeserver-gitops:init-iac -d /opt/iac
```

## Next Steps After Init

1. Add git remote: `cd <iac-directory> && git remote add origin <url>`
2. If K3s is installed, run snapshot: `/homeserver-gitops:snapshot -d <iac-directory>`
3. Add docker-compose stacks for Portainer GitOps
