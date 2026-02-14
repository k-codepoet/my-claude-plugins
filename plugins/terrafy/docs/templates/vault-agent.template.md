# Vault Agent Sidecar Architecture

> Pattern for injecting secrets into Docker Compose services.

## Overview

Vault Agent runs as a sidecar container that:
1. Authenticates via AppRole
2. Renders secret templates to `.env` files
3. Writes to shared volume
4. Exits (restart: no, one-shot)

Main service waits for Vault Agent, then loads `.env` from shared volume.

## Sidecar Composition

```yaml
services:
  vault-agent:
    image: hashicorp/vault:{VAULT_VERSION}
    restart: "no"
    entrypoint: vault agent -config=/vault/config/agent.hcl
    environment:
      VAULT_ADDR: "{VAULT_URL}"
    volumes:
      - ./vault-agent-config.hcl:/vault/config/agent.hcl:ro
      - secrets:/secrets
    networks:
      - {DOCKER_NETWORK}

  {SERVICE}:
    image: {IMAGE}:{TAG}
    entrypoint: [sh, -c, "export $$(cat /secrets/{SERVICE}.env | xargs) && exec {ORIGINAL_CMD}"]
    depends_on:
      vault-agent: { condition: service_completed_successfully }
    volumes:
      - secrets:/secrets
    networks:
      - {DOCKER_NETWORK}

volumes:
  secrets:
```

## Agent Configuration (HCL)

```hcl
auto_auth {
  method "approle" {
    config = {
      role_id_env   = "VAULT_ROLE_ID"
      secret_id_env = "VAULT_SECRET_ID"
    }
  }
  sink "file" {
    config = { path = "/tmp/vault-token" }
  }
}

template {
  contents = <<-EOT
  {{- with secret "secret/data/services/{SERVICE}" -}}
  {{ range $k, $v := .Data.data }}{{ $k }}={{ $v }}
  {{ end }}
  {{- end -}}
  EOT
  destination = "/secrets/{SERVICE}.env"
}
```

## Entrypoint Injection Pattern

```bash
entrypoint: [sh, -c, "export $$(cat /secrets/{SERVICE}.env | xargs) && exec {CMD}"]
```

- `$$` — escape `$` in docker-compose
- `xargs` — convert newline-separated KEY=VALUE to space-separated
- `exec` — replace shell process (PID 1) for signal forwarding

## Vault Agent Services Registry

| Service | Vault Path | Rendered File |
|---------|-----------|---------------|
| {SERVICE_1} | `secret/data/services/{SERVICE_1}` | `/secrets/{SERVICE_1}.env` |
| {SERVICE_2} | `secret/data/common/{SECRET_NAME}` | `/secrets/{SERVICE_2}.env` |
