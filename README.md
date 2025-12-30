# my-claude-plugins

Personal collection of Claude Code plugins by k-codepoet.

## Available Plugins

| Plugin | Description | Platform |
|--------|-------------|----------|
| [homeserver-gitops](./plugins/homeserver-gitops/) | K3s homeserver & GitOps setup with extensible IaC | Linux |

## Installation

### Add Marketplace (Recommended)

```bash
# Add marketplace from GitHub
/plugin marketplace add k-codepoet/my-claude-plugins

# Install plugin
/plugin install homeserver-gitops@k-codepoet-plugins
```

### Local Installation

```bash
# Clone and add as local marketplace
git clone https://github.com/k-codepoet/my-claude-plugins.git
/plugin marketplace add ./my-claude-plugins

# Install plugin
/plugin install homeserver-gitops@k-codepoet-plugins
```

## Plugin Details

### homeserver-gitops (v1.0.0)

Linux Ubuntu homeserver K3s & GitOps initialization plugin:

- **Commands**:
  - `/homeserver-gitops:init` - Install K3s and initialize IaC environment
  - `/homeserver-gitops:init-iac` - Initialize IaC repository only (no K3s)
  - `/homeserver-gitops:join-node` - Join as worker node to existing cluster
  - `/homeserver-gitops:snapshot` - Export cluster state to YAML manifests
  - `/homeserver-gitops:restore` - Restore cluster from saved snapshot
  - `/homeserver-gitops:help` - Show help and usage

- **Features**:
  - Extensible IaC structure at `~/my-iac`
  - Hostname-based Docker Compose for Portainer GitOps
  - Terraform and ArgoCD placeholders
  - Custom directory support (`-d` option)

- **Natural Language Triggers**:
  - "Set up homeserver", "Install K3s"
  - "Add worker node", "Join K3s cluster"
  - "Initialize IaC", "GitOps setup"

- **Prerequisites**: Linux Ubuntu 18.04+, sudo access, curl, git

## Contributing

Feel free to submit issues or pull requests.

## License

MIT
