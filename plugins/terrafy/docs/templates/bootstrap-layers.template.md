# Bootstrap Layers

> Service dependency layers defining deployment order.

## Layer Overview

| Layer | Description | Deploy Method | Dependencies |
|-------|-------------|---------------|-------------|
| **1** | Orchestrator (e.g., Portainer + Agents) | Manual compose | None |
| **2** | Secrets store (e.g., Vault) | Orchestrator stack | Layer 1 |
| **3** | Secrets-independent services | Orchestrator GitOps | Layer 1 |
| **4** | Secrets-dependent services | Orchestrator GitOps + Vault Agent sidecar | Layer 1 + 2 |

## Layer Details

### Layer 1: Orchestrator

Must be deployed manually (no orchestrator to manage itself):

```bash
cd {ORCHESTRATOR_COMPOSE_PATH}
docker compose up -d
```

Components:
- Orchestrator server (e.g., Portainer)
- Orchestrator agents on each node

### Layer 2: Secrets Store

Deployed via orchestrator but does NOT depend on secrets:

- Secrets server (e.g., Vault)
- Initialization container (auto-unseal)

**Critical**: If secrets store is sealed/down, ALL Layer 4 services will fail to start.

### Layer 3: Secrets-Independent Services

Services that don't need runtime secrets:
- Reverse proxy (unless ACME credentials are in vault)
- DNS server
- Monitoring (basic)

### Layer 4: Secrets-Dependent Services

Services using Vault Agent sidecar for secret injection:
- CI/CD tools
- Databases with managed credentials
- External API integrations

## Recovery Order

If full restart is needed:
1. Start Layer 1 (orchestrator)
2. Start Layer 2 (unseal secrets store)
3. Layer 3 services auto-recover via GitOps polling
4. Layer 4 services auto-recover (Vault Agent fetches secrets)

## Stack Assignment

| Stack | Layer | Device | Notes |
|-------|-------|--------|-------|
| {STACK_1} | {LAYER} | {DEVICE} | {NOTES} |
| {STACK_2} | {LAYER} | {DEVICE} | {NOTES} |
