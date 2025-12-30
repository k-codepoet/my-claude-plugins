---
description: Restore K3s cluster from saved snapshot
argument-hint: [--dry-run] [-n namespace]
allowed-tools: Read, Bash, Write
---

Use the k3s-homeserver skill to restore the K3s cluster from saved manifests.

## Prerequisites Check

1. Verify kubectl is available and can connect to cluster:
   ```bash
   kubectl cluster-info
   ```

2. Verify manifests exist:
   ```bash
   ls ~/k3s/k3s/manifest/
   ```

3. If prerequisites not met, inform user and stop.

## Arguments

- `--dry-run` or `-d`: Preview changes without applying
- `-n <namespace>`: Restore only specific namespace

## Workflow

### Step 1: Execute Restore Script

Build command with arguments:

If dry-run requested:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/restore-k3s.sh" --dry-run $ARGUMENTS
```

If specific namespace:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/restore-k3s.sh" -n <namespace>
```

Otherwise full restore:
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

## Recommendations

- Always run with `--dry-run` first to preview changes
- Check snapshot info files in `${CLAUDE_PLUGIN_ROOT}/snapshots/` for available snapshots
- Use `-n <namespace>` to restore specific namespace only
