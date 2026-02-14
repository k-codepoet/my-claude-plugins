# Stacks Registry

> Registered Portainer GitOps stacks.

## Stack List

| Stack Name | Device | Compose Path | Git Source | Layer |
|------------|--------|-------------|------------|-------|
| {STACK_1} | {DEVICE} | {COMPOSE_PATH} | {GIT_SOURCE} | {BOOTSTRAP_LAYER} |
| {STACK_2} | {DEVICE} | {COMPOSE_PATH} | {GIT_SOURCE} | {BOOTSTRAP_LAYER} |

## Git Source Legend

| Source | Repository | Used For |
|--------|-----------|----------|
| github | {GITHUB_REPO_URL} | Infrastructure stacks (avoids circular dependency) |
| gitlab | {GITLAB_REPO_URL} | Service stacks (CI/CD integration) |

## Endpoint Mapping

| Device | Endpoint ID | Notes |
|--------|-------------|-------|
| {DEVICE_1} | {ENDPOINT_ID_1} | {NOTES} |
| {DEVICE_2} | {ENDPOINT_ID_2} | {NOTES} |
