# {DEVICE_NAME}

> {DEVICE_DESCRIPTION}

## Hardware / OS

| Item | Value |
|------|-------|
| Model | {MODEL} |
| Arch | {ARCH} (arm64/amd64) |
| LAN IP | {LAN_IP} |
| VPN | {VPN_HOSTNAME} / {VPN_IP} |

## Roles

- {ROLE_1} (e.g., Traefik Chain Entry Point, Chain Node, Build Runner)
- {ROLE_2}

## Docker Environment

| Item | Value |
|------|-------|
| Engine | {DOCKER_ENGINE_VERSION} |
| Compose | {COMPOSE_VERSION} |
| Platform | {PLATFORM} (e.g., Docker Desktop, Docker Engine) |
| Network Name | {DOCKER_NETWORK} |

### Platform Notes

{PLATFORM_SPECIFIC_NOTES}

## Persistent Storage

| Service | Path |
|---------|------|
| {SERVICE_1} | `{STORAGE_BASE}/{SERVICE_1_DIR}/` |
| {SERVICE_2} | `{STORAGE_BASE}/{SERVICE_2_DIR}/` |

## Port Allocation

| Port | Service | Purpose |
|------|---------|---------|
| {HOST_PORT_1} | {SERVICE_1} | {PURPOSE_1} |
| {HOST_PORT_2} | {SERVICE_2} | {PURPOSE_2} |

> Full port registry: docs/reference/ports.md

## Workspace Path

```
{WORKSPACE_PATH}
```

## Related Docs

- docs/reference/ports.md
- docs/architecture/traefik-chain.md
