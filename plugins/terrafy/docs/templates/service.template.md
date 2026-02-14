# {SERVICE_NAME}

> {SERVICE_DESCRIPTION}

## Location

- **Machine**: {DEVICE_NAME} ({DEVICE_IP})
- **Access**: https://{SERVICE_SUBDOMAIN}.{DOMAIN}
- **Port**: {HOST_PORT}:{CONTAINER_PORT}

## Traffic Path

```
Client (HTTPS) → {ENTRY_POINT} (TLS termination)
  → {CHAIN_PATH} (HTTP)
  → {SERVICE_NAME} (:{CONTAINER_PORT})
```

## Data Storage

```
{STORAGE_BASE}/{SERVICE_DATA_DIR}/
├── data/
├── config/
└── logs/
```

## Portainer Stack Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| {VAR_1} | {PURPOSE_1} | {DEFAULT_1} |

## Operational Notes

- {NOTE_1}
- {NOTE_2}

## Related Docs

- docs/machines/{DEVICE_NAME}.md
- docs/reference/ports.md
