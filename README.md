# my-claude-plugins

Personal collection of Claude Code plugins by k-codepoet.

## Available Plugins

| Plugin | Description | Platform |
|--------|-------------|----------|
| [init-homeserver-with-k3s](./plugins/init-homeserver-with-k3s/) | K3s homeserver setup, multi-node cluster, IaC management | Linux |

## Installation

### From Marketplace URL

```bash
claude plugins add https://raw.githubusercontent.com/k-codepoet/my-claude-plugins/main/marketplace.json
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/k-codepoet/my-claude-plugins.git

# Use plugin directly
claude --plugin-dir ./my-claude-plugins/plugins/init-homeserver-with-k3s
```

## Plugin Details

### init-homeserver-with-k3s (v1.1.0)

Linux Ubuntu homeserver K3s initialization plugin with:

- **Commands**:
  - `/init-homeserver-with-k3s:init` - Install K3s and initialize IaC environment
  - `/init-homeserver-with-k3s:join-node` - Join as worker node to existing cluster
  - `/init-homeserver-with-k3s:snapshot` - Export cluster state to YAML manifests
  - `/init-homeserver-with-k3s:restore` - Restore cluster from saved snapshot

- **Natural Language Triggers**:
  - "Set up homeserver", "Install K3s"
  - "Add worker node", "Join K3s cluster"

- **Prerequisites**: Linux Ubuntu 18.04+, sudo access, curl, git

## Contributing

Feel free to submit issues or pull requests.

## License

MIT
