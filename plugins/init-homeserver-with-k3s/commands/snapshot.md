---
description: Create snapshot of current K3s cluster state
allowed-tools: Read, Bash, Write
---

Use the k3s-homeserver skill to create a snapshot of the current K3s cluster state.

## Prerequisites Check

1. Verify kubectl is available and can connect to cluster:
   ```bash
   kubectl cluster-info
   ```

2. If cluster not accessible, inform user and stop.

## Workflow

### Step 1: Execute Snapshot Script

Run the snapshot script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-k3s.sh"
```

### Step 2: Verify Results

Check the snapshot outputs:
- Manifests at `~/k3s/k3s/manifest/`
- Helm resources at `~/k3s/k3s/helm/`
- Snapshot info at `${CLAUDE_PLUGIN_ROOT}/snapshots/`

### Step 3: Report Summary

Report to user:
- Number of namespaces exported
- Number of resources exported
- Location of snapshot info file
- Recommend git commit if changes detected

## Optional: Git Commit

If user wants to commit changes:
```bash
cd ~/k3s
git add .
git commit -m "Snapshot: $(date +%Y-%m-%d)"
```
