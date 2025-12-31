---
description: Restore K3s cluster from saved snapshot
argument-hint: [--dir directory] [--dry-run] [-n namespace]
allowed-tools: Read, Bash, Write
---

Use the k3s-homeserver skill to restore the K3s cluster from saved manifests.

## Arguments

- `--dir <directory>`: IaC directory path (default: `~/my-iac`)
- `--dry-run` or `-d`: Preview changes without applying
- `-n <namespace>`: Restore only specific namespace

## Prerequisites Check

1. Verify kubectl is available and can connect to cluster:
   ```bash
   kubectl cluster-info
   ```

2. Verify manifests exist:
   ```bash
   ls <iac-directory>/k3s/manifest/
   ```

3. If prerequisites not met, inform user and stop.

## Workflow

### Step 1: Execute Restore Script

Build command with arguments:

Default path with dry-run:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/restore-k3s.sh" --dry-run
```

Custom path:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/restore-k3s.sh" --dir /path/to/iac
```

Specific namespace:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/restore-k3s.sh" -n <namespace>
```

Full restore:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/restore-k3s.sh"
```

### Step 2: Verify Results

After restore, verify cluster state:
```bash
kubectl get pods -A
kubectl get services -A
```

### Step 3: Report Summary

Report to user:
- Resources restored
- Any failures or warnings
- Cluster status after restore

## Examples

```bash
# Preview changes (recommended first)
/homeserver-gitops:restore --dry-run

# Restore all from default directory
/homeserver-gitops:restore

# Restore from custom directory
/homeserver-gitops:restore --dir ~/projects/my-infrastructure

# Restore specific namespace only
/homeserver-gitops:restore -n default
```

## Recommendations

- Always run with `--dry-run` first to preview changes
- Check snapshot info files in `<iac-directory>/k3s/snapshots/` for available snapshots
- Use `-n <namespace>` to restore specific namespace only
