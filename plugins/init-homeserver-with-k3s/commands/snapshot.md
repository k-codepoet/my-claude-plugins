---
description: Create snapshot of current K3s cluster state
argument-hint: [-d directory]
allowed-tools: Read, Bash, Write
---

Use the k3s-homeserver skill to create a snapshot of the current K3s cluster state.

## Arguments

- `-d <directory>` or `--directory <directory>`: IaC directory path (default: `~/my-iac`)

## Prerequisites Check

1. Verify kubectl is available and can connect to cluster:
   ```bash
   kubectl cluster-info
   ```

2. Verify IaC directory exists

3. If cluster not accessible, inform user and stop.

## Workflow

### Step 1: Execute Snapshot Script

Default path:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-k3s.sh"
```

Custom path:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-k3s.sh" -d /path/to/iac
```

### Step 2: Verify Results

Check the snapshot outputs:
- Manifests at `<iac-directory>/k3s/manifest/`
- Helm resources at `<iac-directory>/k3s/helm/`
- Snapshot info at `<iac-directory>/k3s/snapshots/`

### Step 3: Report Summary

Report to user:
- Number of namespaces exported
- Number of resources exported
- Location of snapshot info file
- Recommend git commit if changes detected

## Examples

```bash
# Default directory ~/my-iac
/init-homeserver-with-k3s:snapshot

# Custom directory
/init-homeserver-with-k3s:snapshot -d ~/projects/my-infrastructure
```

## Optional: Git Commit

If user wants to commit changes:
```bash
cd <iac-directory>
git add .
git commit -m "Snapshot: $(date +%Y-%m-%d)"
```
