---
description: Join this machine to an existing K3s cluster as a worker node
argument-hint: [--master-ip IP] [--token TOKEN] [--node-name NAME]
allowed-tools: Read, Bash, Write
---

Use the k3s-homeserver skill to join this machine to an existing K3s cluster as a worker node.

## CRITICAL: Master Node Confirmation Required

**This command MUST confirm master node details with the user before proceeding.**

The user must provide:
1. **Master Node IP** - IP address of the K3s server (control plane)
2. **Node Token** - Authentication token from the master node

## Prerequisites Check

1. Verify platform is Linux Ubuntu:
   ```bash
   uname -s  # Should return "Linux"
   cat /etc/os-release | grep -i ubuntu
   ```

2. Verify this machine is NOT already a K3s node:
   ```bash
   # Check if already a K3s server
   ls /usr/local/bin/k3s-uninstall.sh 2>/dev/null
   
   # Check if already a K3s agent
   ls /usr/local/bin/k3s-agent-uninstall.sh 2>/dev/null
   ```

3. If prerequisites not met, inform user and stop.

## Arguments

- `--master-ip IP`: IP address of the K3s master node (required)
- `--token TOKEN`: Node token from master (optional, script will prompt)
- `--node-name NAME`: Custom name for this worker node (optional)

## Workflow

### Step 1: Gather Master Node Information

**MANDATORY: Ask user to confirm/provide master node details**

Questions to ask:
1. "What is the IP address of your K3s master node?"
2. "Please provide the node token from the master node."

Provide guidance for getting the token:
```bash
# Run this on the MASTER node to get the token:
sudo cat /var/lib/rancher/k3s/server/node-token
```

### Step 2: Verify Master Node Accessibility

Before installation, verify the master node is reachable:
```bash
# Test connectivity
ping -c 1 <MASTER_IP>

# Test K3s API port
timeout 5 bash -c "</dev/tcp/<MASTER_IP>/6443" && echo "API accessible"
```

If not accessible, inform user about:
- Firewall rules (port 6443 must be open)
- Network connectivity issues
- Verifying K3s server is running on master

### Step 3: Execute Join Script

After user confirms all details, execute:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/join-node.sh" --master-ip <MASTER_IP> --token <TOKEN>
```

Or with custom node name:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/join-node.sh" --master-ip <MASTER_IP> --token <TOKEN> --node-name <NAME>
```

### Step 4: Verify Join Status

After installation, verify the node joined successfully:

1. Check agent service on this node:
   ```bash
   sudo systemctl status k3s-agent
   ```

2. Instruct user to verify on master node:
   ```bash
   kubectl get nodes
   ```

## Completion

Report to user:
- Installation status
- Node name (hostname or custom name)
- How to verify on master node
- Useful commands for managing the agent

## Troubleshooting

### Agent not starting
```bash
# Check logs
sudo journalctl -u k3s-agent -f

# Check status
sudo systemctl status k3s-agent
```

### Node not appearing in cluster
- Wait a few seconds for registration
- Verify network connectivity to master
- Check token is correct
- Verify firewall allows port 6443

### Uninstall agent
```bash
sudo /usr/local/bin/k3s-agent-uninstall.sh
```

## Security Notes

- Never share the node token publicly
- The token grants access to join the cluster
- Consider rotating tokens periodically on production clusters
