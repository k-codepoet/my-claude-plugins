# Port Allocation

> Service port registry and allocation policy.

## Port Policy

### Default: Close ports, access via domain

- **Host ports are closed by default** (`expose` only, no `ports` binding)
- **All services accessed via reverse proxy domain** (Docker labels for routing)
- Open ports only for exceptions below

### Exceptions Requiring Port Binding

| Exception Type | Example | Reason |
|----------------|---------|--------|
| **Reverse proxy itself** | 80, 443 | Entry point |
| **Non-HTTP protocols** | DNS :53, SSH :{SSH_PORT} | Cannot route via HTTP proxy |
| **Inter-service communication** | Vault :{VAULT_PORT}, Orchestrator :{ORCH_PORT} | Bootstrap layer, must start before proxy |
| **Agent communication** | Orchestrator Agent :{AGENT_PORT} | Direct communication |

### DNS Access: External vs Internal

| Domain | Path | Scope | Purpose |
|--------|------|-------|---------|
| `*.{DOMAIN}` | CDN/Tunnel → Entry Point :80 | **External** | Public services |
| `*.{INTERNAL_SUBDOMAIN}.{DOMAIN}` | Split DNS → VPN IP → Entry Point :443 | **Internal** | Management services |

## Allocation Rules

- Host ports: **{PORT_RANGE_START}-{PORT_RANGE_END}** range
- Container internal ports: Keep original (e.g., `{HOST_PORT}:{CONTAINER_PORT}`)

## Range Assignment

| Range | Purpose |
|-------|---------|
| {PORT_RANGE_START}-{+999} | SSH/Git |
| {+1000}-{+1999} | Reserved |
| {+2000}-{+2999} | Reserved |
| {+3000}-{+3999} | Monitoring |
| {+4000}-{+4999} | Orchestration |
| {+5000}-{+5999} | Automation |
| {+6000}-{+6999} | Reserved |
| {+7000}-{+7999} | Reserved |
| {+8000}-{+8999} | Security |
| {+9000}-{+9999} | Management |

## Current Allocation

### {DEVICE_1} ({DEVICE_1_IP})

| Service | Host Port | Container Port | Notes |
|---------|-----------|----------------|-------|
| {SERVICE} | {HOST_PORT} | {CONTAINER_PORT} | {NOTES} |

### {DEVICE_2} ({DEVICE_2_IP})

| Service | Host Port | Container Port | Notes |
|---------|-----------|----------------|-------|
| {SERVICE} | {HOST_PORT} | {CONTAINER_PORT} | {NOTES} |
