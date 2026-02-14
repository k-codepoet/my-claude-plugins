# Stacks Registry

## 등록된 Stacks (Portainer GitOps)

| Stack | Endpoint | Compose Path | Git Source |
|-------|----------|--------------|------------|
| traefik-mac | mac-mini | `infra/codepoet-mac-mini-1/traefik/docker-compose.yml` | GitHub |
| vault | mac-mini | `infra/codepoet-mac-mini-1/vault/docker-compose.yml` | GitHub |
| traefik-nas | nas | `infra/codepoet-nas/traefik/docker-compose.yml` | GitHub |
| gitlab-ce | nas | `infra/codepoet-nas/gitlab-ce/docker-compose.yml` | GitHub |
| cloudflared | nas | `infra/codepoet-nas/cloudflared/docker-compose.yml` | GitHub |
| adguard-home | nas | `infra/codepoet-nas/adguard-home/docker-compose.yml` | GitHub |
| traefik-mac2 | mac-mini-2 | `infra/codepoet-mac-mini-2/traefik/docker-compose.yml` | GitHub |
| traefik-linux | linux | `infra/codepoet-linux-1/traefik/docker-compose.yml` | GitHub |
| grafana | mac-mini | `services/codepoet-mac-mini-1/grafana/docker-compose.yml` | GitLab |
| n8n | mac-mini | `services/codepoet-mac-mini-1/n8n/docker-compose.yml` | GitLab |
| prefect | mac-mini | `services/codepoet-mac-mini-1/prefect/docker-compose.yml` | GitLab |
| vaultwarden | mac-mini | `services/codepoet-mac-mini-1/vaultwarden/docker-compose.yml` | GitLab |
| gitlab-runner-mac | mac-mini | `services/codepoet-mac-mini-1/gitlab-runner/docker-compose.yml` | GitLab |
| gitlab-runner-linux | linux | `services/codepoet-linux-1/gitlab-runner/docker-compose.yml` | GitLab |

> **하이브리드 GitOps:** 인프라 스택은 GitHub에서, 서비스 스택은 GitLab CE에서 clone. 순환 의존성 해소로 gitlab-ce, traefik-nas도 GitOps 전환 완료.

## 수동 관리 서비스 (Portainer GitOps 제외)

| Service | Device | Compose Path | 제외 사유 |
|---------|--------|--------------|-----------|
| Portainer | Mac Mini | 수동 `docker run` | Layer 1 부트스트랩, 다른 모든 스택의 전제조건 |
| Portainer Agent | NAS, Linux, Mac Mini 2 | 수동 `docker run` | Layer 1 부트스트랩 |
