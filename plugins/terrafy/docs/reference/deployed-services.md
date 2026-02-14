# Deployed Services

## Mac Mini (192.168.0.48)

| Service | Port | External URL | Database | Storage |
|---------|------|--------------|----------|---------|
| **Vault** | 28200 | - | - | `/Volumes/mac-ext-storage/.vault/` |
| **Portainer** | 29000, 29443 | - | - | `/Volumes/mac-ext-storage/.portainer/` |
| **Grafana** | 23000 | - | - | `/Volumes/mac-ext-storage/.grafana/` |
| **n8n** | 25678 | n8n.codepoet.site | PostgreSQL 16 | `/Volumes/mac-ext-storage/.n8n/` |
| **Prefect** | 24200 | prefect.codepoet.site | PostgreSQL 16 | `/Volumes/mac-ext-storage/.prefect/` |
| **Vaultwarden** | 28888 | - | - | `/Volumes/mac-ext-storage/.vaultwarden/` |
| **GitLab Runner** | - | - | - | `/Volumes/mac-ext-storage/.gitlab-runner/` |

## NAS (192.168.0.14)

| Service | Port | External URL | Notes |
|---------|------|--------------|-------|
| **Gateway** (cloudflared + Traefik) | 8880 (HTTP), 8443 (HTTPS) | test.codepoet.site | Central ingress + TLS termination |
| **GitLab CE** | - | gitlab.home.codepoet.site | Traefik-only (포트 미노출) |
| **GitLab Registry** | - | gitlab-registry.home.codepoet.site | Container Registry (Traefik, 포트 미노출) |
| **Portainer Agent** | 9002 | - | Managed by Mac Mini Portainer |

## Mac Mini 2 (192.168.0.37)

| Service | Port | Notes |
|---------|------|-------|
| **Traefik** | 80, 8080 | Standalone (체인 미참여) |
| **Portainer Agent** | 9001 | Managed by Mac Mini 1 Portainer |

## Linux (192.168.0.34)

| Service | Port | Notes |
|---------|------|-------|
| **Portainer Agent** | 9001 | Managed by Mac Mini Portainer |
| **GitLab Runner** | - | Docker-in-Docker (amd64) |
