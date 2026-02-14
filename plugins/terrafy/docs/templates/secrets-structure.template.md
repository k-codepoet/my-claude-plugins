# Secrets Structure

> Vault KV secret path layout and conventions.

## Path Structure

```
secret/
├── common/                          # Shared across all machines
│   ├── {COMMON_SECRET_1}           # {DESCRIPTION}
│   ├── {COMMON_SECRET_1}-approle   # AppRole for {COMMON_SECRET_1}
│   ├── {COMMON_SECRET_2}
│   └── ...
│
└── services/                        # Per-service secrets
    ├── {SERVICE_1}                  # {SERVICE_1} runtime secrets
    ├── {SERVICE_1}-approle          # AppRole for {SERVICE_1}
    ├── {SERVICE_2}
    ├── {SERVICE_2}-approle
    └── ...
```

## Classification

| Category | Path | Criteria |
|----------|------|----------|
| **common** | `secret/common/` | Same value across all machines |
| **services** | `secret/services/{name}/` | Per-service, same regardless of machine |
| **{name}-approle** | `secret/{path}/{name}-approle` | AppRole auth credentials for the service |

## Secret Contents Template

### secret/common/{name}

```
{KEY_1}    # {DESCRIPTION}
{KEY_2}    # {DESCRIPTION}
```

### secret/services/{name}

```
{KEY_1}    # {DESCRIPTION}
{KEY_2}    # {DESCRIPTION}
```

### secret/{path}/{name}-approle

```
VAULT_ROLE_ID      # AppRole Role ID
VAULT_SECRET_ID    # AppRole Secret ID
```

## CLI Operations

```bash
# Query secret
ssh {VAULT_DEVICE} "docker exec -e VAULT_TOKEN={TOKEN} {VAULT_CONTAINER} \
  vault kv get secret/services/{SERVICE}"

# List paths
ssh {VAULT_DEVICE} "docker exec -e VAULT_TOKEN={TOKEN} {VAULT_CONTAINER} \
  vault kv list secret/services/"
```

## AppRole Registry

| Service | Vault Path | Policy |
|---------|-----------|--------|
| {SERVICE_1} | `secret/services/{SERVICE_1}-approle` | {SERVICE_1}-policy |
| {SERVICE_2} | `secret/services/{SERVICE_2}-approle` | {SERVICE_2}-policy |
