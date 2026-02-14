# Adding New Services

> Step-by-step guide for adding a new service.

## Quick Start

1. Create compose file:
   - Infrastructure: `infra/{DEVICE}/{SERVICE}/docker-compose.yml`
   - Application: `services/{DEVICE}/{SERVICE}/docker-compose.yml`
2. Add Traefik labels
3. Register in orchestrator (e.g., add to stack registry script)
4. Deploy via GitOps

## docker-compose.yml Template

### Standard Device

```yaml
services:
  {SERVICE}:
    image: {IMAGE}:{TAG}
    container_name: {SERVICE}
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      # External access
      - "traefik.http.routers.{SERVICE}.rule=Host(`{SERVICE}.{DOMAIN}`)"
      - "traefik.http.routers.{SERVICE}.entrypoints=web,websecure"
      # Internal access
      - "traefik.http.routers.{SERVICE}-int.rule=Host(`{SERVICE}.{INTERNAL_SUBDOMAIN}.{DOMAIN}`)"
      - "traefik.http.routers.{SERVICE}-int.entrypoints=web"
      # Service port
      - "traefik.http.services.{SERVICE}.loadbalancer.server.port={CONTAINER_PORT}"
    networks:
      - {DOCKER_NETWORK}

networks:
  {DOCKER_NETWORK}:
    external: true
```

### NAS / Special Device

```yaml
services:
  {SERVICE}:
    image: {IMAGE}:{TAG}
    container_name: {SERVICE}
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.{SERVICE}.rule=Host(`{SERVICE}.{INTERNAL_SUBDOMAIN}.{DOMAIN}`)"
      - "traefik.http.routers.{SERVICE}.entrypoints=web"
      - "traefik.http.services.{SERVICE}.loadbalancer.server.port={CONTAINER_PORT}"
    networks:
      - {DOCKER_NETWORK}
    volumes:
      # Persistent data: absolute host mount (required for GitOps)
      - {ABSOLUTE_DATA_PATH}/config:/etc/{SERVICE}
      - {ABSOLUTE_DATA_PATH}/data:/var/lib/{SERVICE}

networks:
  {DOCKER_NETWORK}:
    external: true
```

## Vault Integration (If Secrets Needed)

### 1. Store secrets in Vault

```bash
ssh {VAULT_DEVICE} "docker exec -e VAULT_TOKEN={TOKEN} {VAULT_CONTAINER} \
  vault kv put secret/services/{SERVICE} \
  DB_PASSWORD=xxx \
  API_KEY=yyy"
```

### 2. Create AppRole

```bash
# Policy
ssh {VAULT_DEVICE} "echo 'path \"secret/data/services/{SERVICE}\" { capabilities = [\"read\"] }' | \
  docker exec -i -e VAULT_TOKEN={TOKEN} {VAULT_CONTAINER} vault policy write {SERVICE}-policy -"

# AppRole
ssh {VAULT_DEVICE} "docker exec -e VAULT_TOKEN={TOKEN} {VAULT_CONTAINER} \
  vault write auth/approle/role/{SERVICE} \
  token_policies={SERVICE}-policy token_ttl=1h token_max_ttl=4h"

# Get Role ID & Secret ID
ssh {VAULT_DEVICE} "docker exec -e VAULT_TOKEN={TOKEN} {VAULT_CONTAINER} \
  vault read auth/approle/role/{SERVICE}/role-id"
ssh {VAULT_DEVICE} "docker exec -e VAULT_TOKEN={TOKEN} {VAULT_CONTAINER} \
  vault write -f auth/approle/role/{SERVICE}/secret-id"
```

### 3. Add Vault Agent sidecar to compose

See: Vault Agent sidecar template (`$CLAUDE_PLUGIN_ROOT/skills/secrets/templates/vault-agent-sidecar.template.yml`)

### 4. Set Portainer Stack Variables

- `VAULT_ROLE_ID`: Role ID from step 2
- `VAULT_SECRET_ID`: Secret ID from step 2

## Port Allocation

New services use port range **{PORT_RANGE_START}-{PORT_RANGE_END}**.
Check current allocation: `docs/reference/ports.md`

## Storage

| Device Type | Path Pattern |
|-------------|-------------|
| Standard | `{STORAGE_BASE}/.{SERVICE}/` |
| NAS | `{NAS_STORAGE_BASE}/{infra|services}/{DEVICE}/{SERVICE}/data/` |

**Note**: GitOps orchestrators clone repos to internal paths → relative paths won't work. Use absolute paths for persistent data.

## Verification

```bash
# Service status
docker ps | grep {SERVICE}

# Logs
docker logs {SERVICE}

# Access test
curl -I https://{SERVICE}.{DOMAIN}
curl -I https://{SERVICE}.{INTERNAL_SUBDOMAIN}.{DOMAIN}
```
