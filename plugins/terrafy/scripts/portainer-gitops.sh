#!/bin/zsh
# Portainer GitOps Stack Manager
# 하이브리드 GitOps (GitHub + GitLab) 스택 관리 스크립트
# Vault 연동으로 secrets 중앙 관리

set -e

# === Vault Configuration ===
VAULT_ADDR="${VAULT_ADDR:-http://192.168.0.48:28200}"
VAULT_TOKEN="${VAULT_TOKEN:-}"
VAULT_SECRET_PATH="${VAULT_SECRET_PATH:-secret/data/portainer}"
USE_VAULT="${USE_VAULT:-true}"

# === Configuration (loaded from Vault or env) ===
PORTAINER_URL="${PORTAINER_URL:-https://192.168.0.48:29443}"
PORTAINER_API_KEY="${PORTAINER_API_KEY:-}"

# Endpoint IDs (run 'api_call GET /endpoints' to find IDs)
ENDPOINT_MAC_MINI="${ENDPOINT_MAC_MINI:-3}"    # mac-mini-1
ENDPOINT_MAC_MINI_2="${ENDPOINT_MAC_MINI_2:-17}"   # mac-mini-2
ENDPOINT_NAS="${ENDPOINT_NAS:-16}"             # nas
ENDPOINT_LINUX="${ENDPOINT_LINUX:-15}"         # linux-1

# Working Directories
MAC_MINI_BASE="/Volumes/mac-ext-storage/k-codepoet/my-devops"
MAC_MINI_2_BASE="/Users/choigawoon/workspace/my-devops"
NAS_BASE="/volume1/workspaces/k-codepoet/my-devops"
LINUX_BASE="/home/choigawoon/k-codepoet/my-devops"

# Git Repository
GIT_REPO_URL="${GIT_REPO_URL:-https://gitlab.home.codepoet.site/k-codepoet/my-devops.git}"
GIT_BRANCH="${GIT_BRANCH:-main}"
GIT_USERNAME="${GIT_USERNAME:-}"
GIT_TOKEN="${GIT_TOKEN:-}"

# Auto Update
AUTO_UPDATE_INTERVAL="${AUTO_UPDATE_INTERVAL:-5m}"

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# === Repo Definitions ===
# Format: repo_id -> "vault_secret_path"
# "default" repo uses global GIT_REPO_URL / GIT_USERNAME / GIT_TOKEN
# External repos load credentials from their Vault path
typeset -A REPOS
REPOS=(
    # default: 기존 global 변수 사용 (secret/data/portainer/scripts) → GitLab CE
    # github: 인프라 스택용 GitHub repo (순환 의존성 해소)
    github "secret/data/common/git"
)

# === Stack Definitions ===
# Format: stack_name -> "endpoint:compose_path" or "endpoint:compose_path:repo_id"
# endpoint: mac-mini | mac-mini-2 | nas | linux
# repo_id: optional, defaults to "default" (= this my-devops repo)
typeset -A STACKS
STACKS=(
    # === 인프라 (GitHub 소스) — 순환 의존성 해소 ===
    traefik-mac "mac-mini:infra/codepoet-mac-mini-1/traefik/docker-compose.yml:github"
    vault "mac-mini:infra/codepoet-mac-mini-1/vault/docker-compose.yml:github"
    traefik-nas "nas:infra/codepoet-nas/traefik/docker-compose.yml:github"
    gitlab-ce "nas:infra/codepoet-nas/gitlab-ce/docker-compose.yml:github"
    cloudflared "nas:infra/codepoet-nas/cloudflared/docker-compose.yml:github"
    adguard-home "nas:infra/codepoet-nas/adguard-home/docker-compose.yml:github"
    traefik-mac2 "mac-mini-2:infra/codepoet-mac-mini-2/traefik/docker-compose.yml:github"
    traefik-linux "linux:infra/codepoet-linux-1/traefik/docker-compose.yml:github"

    # === 서비스 (GitLab CE 소스, default) ===
    grafana "mac-mini:services/codepoet-mac-mini-1/grafana/docker-compose.yml"
    n8n "mac-mini:services/codepoet-mac-mini-1/n8n/docker-compose.yml"
    prefect "mac-mini:services/codepoet-mac-mini-1/prefect/docker-compose.yml"
    vaultwarden "mac-mini:services/codepoet-mac-mini-1/vaultwarden/docker-compose.yml"
    authelia "mac-mini:services/codepoet-mac-mini-1/authelia/docker-compose.yml"
    gitlab-runner-mac "mac-mini:services/codepoet-mac-mini-1/gitlab-runner/docker-compose.yml"
    gitlab-runner-mac-dood "mac-mini:services/codepoet-mac-mini-1/gitlab-runner-dood/docker-compose.yml"
    gitlab-runner-linux "linux:services/codepoet-linux-1/gitlab-runner/docker-compose.yml"
    gitlab-runner-linux-dood "linux:services/codepoet-linux-1/gitlab-runner-dood/docker-compose.yml"
)

# Helper to parse stack definition
# Format: "endpoint:compose_path" or "endpoint:compose_path:repo_id"
get_stack_endpoint() {
    local stack_def="$1"
    echo "${stack_def%%:*}"
}

get_stack_compose_path() {
    local stack_def="$1"
    local remainder="${stack_def#*:}"  # strip "endpoint:"
    # If there's a repo_id (third field), strip it
    local without_repo="${remainder%:*}"
    if [[ "$without_repo" == "$remainder" ]]; then
        # No third field
        echo "$remainder"
    else
        echo "$without_repo"
    fi
}

get_stack_repo_id() {
    local stack_def="$1"
    local remainder="${stack_def#*:}"  # strip "endpoint:"
    local after_second="${remainder#*:}"
    if [[ "$after_second" == "$remainder" ]]; then
        # No third field -> default repo
        echo "default"
    else
        echo "$after_second"
    fi
}

get_endpoint_id() {
    local endpoint_name="$1"
    case "$endpoint_name" in
        mac-mini)   echo "$ENDPOINT_MAC_MINI" ;;
        mac-mini-2) echo "$ENDPOINT_MAC_MINI_2" ;;
        nas)        echo "$ENDPOINT_NAS" ;;
        linux)      echo "$ENDPOINT_LINUX" ;;
        *)          echo "$ENDPOINT_MAC_MINI" ;;  # default
    esac
}

get_base_path() {
    local endpoint_name="$1"
    case "$endpoint_name" in
        mac-mini)   echo "$MAC_MINI_BASE" ;;
        mac-mini-2) echo "$MAC_MINI_2_BASE" ;;
        nas)        echo "$NAS_BASE" ;;
        linux)      echo "$LINUX_BASE" ;;
        *)          echo "$MAC_MINI_BASE" ;;
    esac
}

# === Helper Functions ===
log_info() { print -P "%F{green}[INFO]%f $1" >&2; }
log_warn() { print -P "%F{yellow}[WARN]%f $1" >&2; }
log_error() { print -P "%F{red}[ERROR]%f $1" >&2; }

# === Vault Functions ===
vault_get_secret() {
    local secret_path="$1"
    curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
        "${VAULT_ADDR}/v1/${secret_path}" | jq -r '.data.data // empty'
}

vault_load_scripts_config() {
    if [[ "$USE_VAULT" != "true" ]] || [[ -z "$VAULT_TOKEN" ]]; then
        return 0
    fi

    log_info "Loading configuration from Vault..."
    local secrets
    secrets=$(vault_get_secret "secret/data/portainer/scripts" 2>/dev/null || echo "")

    if [[ -z "$secrets" ]]; then
        log_warn "Could not load secrets from Vault, using environment variables"
        return 0
    fi

    # Export secrets as environment variables (only if not already set)
    [[ -z "$PORTAINER_API_KEY" ]] && PORTAINER_API_KEY=$(echo "$secrets" | jq -r '.PORTAINER_API_KEY // empty')
    [[ -z "$GIT_USERNAME" ]] && GIT_USERNAME=$(echo "$secrets" | jq -r '.GIT_USERNAME // empty')
    [[ -z "$GIT_TOKEN" ]] && GIT_TOKEN=$(echo "$secrets" | jq -r '.GIT_TOKEN // empty')
    [[ -z "$GIT_REPO_URL" ]] && GIT_REPO_URL=$(echo "$secrets" | jq -r '.GIT_REPO_URL // empty')

    log_info "Configuration loaded from Vault"
}

vault_get_service_env() {
    local service_name="$1"

    if [[ "$USE_VAULT" != "true" ]] || [[ -z "$VAULT_TOKEN" ]]; then
        echo "[]"
        return 0
    fi

    local secrets
    secrets=$(vault_get_secret "secret/data/portainer/${service_name}" 2>/dev/null || echo "")

    if [[ -z "$secrets" ]]; then
        echo "[]"
        return 0
    fi

    # Convert to Portainer env format: [{"name": "KEY", "value": "VALUE"}, ...]
    echo "$secrets" | jq '[to_entries[] | {name: .key, value: (.value | tostring)}]'
}

# Resolve repo config for a given repo_id
# Sets: RESOLVED_REPO_URL, RESOLVED_BRANCH, RESOLVED_USERNAME, RESOLVED_TOKEN
resolve_repo_config() {
    local repo_id="$1"

    if [[ "$repo_id" == "default" ]]; then
        # Use existing global variables (backward compatible)
        RESOLVED_REPO_URL="$GIT_REPO_URL"
        RESOLVED_BRANCH="$GIT_BRANCH"
        RESOLVED_USERNAME="$GIT_USERNAME"
        RESOLVED_TOKEN="$GIT_TOKEN"
        return 0
    fi

    # Look up Vault path from REPOS array
    local vault_path="${REPOS[$repo_id]}"

    # Load from Vault
    if [[ -n "$vault_path" ]] && [[ "$USE_VAULT" == "true" ]] && [[ -n "$VAULT_TOKEN" ]]; then
        local secrets
        secrets=$(vault_get_secret "$vault_path" 2>/dev/null || echo "")
        if [[ -n "$secrets" ]]; then
            RESOLVED_REPO_URL=$(echo "$secrets" | jq -r '.REPO_URL // empty')
            RESOLVED_BRANCH=$(echo "$secrets" | jq -r '.BRANCH // "main"')
            RESOLVED_USERNAME=$(echo "$secrets" | jq -r '.USERNAME // empty')
            RESOLVED_TOKEN=$(echo "$secrets" | jq -r '.TOKEN // empty')
            log_info "Repo config loaded from Vault: $repo_id"
            return 0
        fi
    fi

    # Fallback: check environment variables REPO_{ID}_URL etc.
    local env_prefix="REPO_${repo_id//-/_}"
    env_prefix="${(U)env_prefix}"  # uppercase (zsh)
    local url_var="${env_prefix}_URL"
    local branch_var="${env_prefix}_BRANCH"
    local user_var="${env_prefix}_USERNAME"
    local token_var="${env_prefix}_TOKEN"
    RESOLVED_REPO_URL="${(P)url_var:-}"
    RESOLVED_BRANCH="${(P)branch_var:-main}"
    RESOLVED_USERNAME="${(P)user_var:-}"
    RESOLVED_TOKEN="${(P)token_var:-}"

    if [[ -n "$RESOLVED_REPO_URL" ]]; then
        log_info "Repo config loaded from env: $repo_id"
        return 0
    fi

    log_error "No config found for repo: $repo_id"
    if [[ -n "$vault_path" ]]; then
        log_error "Set Vault secret at '$vault_path' (keys: REPO_URL, BRANCH, USERNAME, TOKEN)"
    else
        log_error "Add repo to REPOS array or set env vars: ${env_prefix}_URL, ${env_prefix}_USERNAME, ${env_prefix}_TOKEN"
    fi
    return 1
}

check_requirements() {
    if ! command -v curl &> /dev/null; then
        log_error "curl is required"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        log_error "jq is required. Install with: brew install jq"
        exit 1
    fi

    # Load configuration from Vault if available
    vault_load_scripts_config

    if [[ -z "$PORTAINER_API_KEY" ]]; then
        log_error "PORTAINER_API_KEY is required"
        echo ""
        echo "Option 1: Set VAULT_TOKEN to load from Vault"
        echo "  export VAULT_TOKEN='hvs.xxxxx'"
        echo ""
        echo "Option 2: Set directly or via .env file"
        echo "  export PORTAINER_API_KEY='ptr_xxxxx'"
        exit 1
    fi
}

api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"

    local curl_opts=(-s -k -X "$method")
    curl_opts+=(-H "X-API-Key: $PORTAINER_API_KEY")
    curl_opts+=(-H "Content-Type: application/json")

    if [[ -n "$data" ]]; then
        curl_opts+=(-d "$data")
    fi

    curl "${curl_opts[@]}" "${PORTAINER_URL}/api${endpoint}"
}

# === Stack Operations ===
list_stacks() {
    log_info "Fetching existing stacks..."
    api_call GET "/stacks" | jq -r '.[] | "\(.Id)\t\(.Name)\t\(.Status)"'
}

get_stack_id() {
    local stack_name="$1"
    api_call GET "/stacks" | jq -r ".[] | select(.Name == \"$stack_name\") | .Id"
}

create_stack() {
    local stack_name="$1"
    local compose_path="$2"
    local env_file="$3"
    local endpoint_id="$4"
    local repo_id="${5:-default}"

    # Resolve repo config
    resolve_repo_config "$repo_id" || return 1

    log_info "Creating stack: $stack_name (endpoint=$endpoint_id, repo=$repo_id)"

    # Build environment variables array
    local env_vars="[]"

    # Try Vault first
    if [[ "$USE_VAULT" == "true" ]] && [[ -n "$VAULT_TOKEN" ]]; then
        log_info "Loading env vars from Vault: secret/portainer/$stack_name"
        env_vars=$(vault_get_service_env "$stack_name")
    fi

    # Fallback to .env file if Vault returned empty
    if [[ "$env_vars" == "[]" ]] && [[ -n "$env_file" ]] && [[ -f "$env_file" ]]; then
        log_info "Loading env vars from file: $env_file"
        env_vars=$(grep -v '^#' "$env_file" | grep '=' | while IFS='=' read -r key value; do
            # Remove quotes from value
            value="${value%\"}"
            value="${value#\"}"
            echo "{\"name\": \"$key\", \"value\": \"$value\"}"
        done | jq -s '.')
    fi

    # Build request payload
    local payload
    payload=$(jq -n \
        --arg name "$stack_name" \
        --arg repoUrl "$RESOLVED_REPO_URL" \
        --arg branch "refs/heads/$RESOLVED_BRANCH" \
        --arg compose "$compose_path" \
        --arg interval "$AUTO_UPDATE_INTERVAL" \
        --arg gitUser "$RESOLVED_USERNAME" \
        --arg gitToken "$RESOLVED_TOKEN" \
        --argjson env "$env_vars" \
        '{
            name: $name,
            repositoryURL: $repoUrl,
            repositoryReferenceName: $branch,
            composeFile: $compose,
            env: $env,
            autoUpdate: {
                interval: $interval
            }
        } + (if $gitUser != "" then {
            repositoryAuthentication: true,
            repositoryUsername: $gitUser,
            repositoryPassword: $gitToken
        } else {} end)'
    )

    local response
    response=$(api_call POST "/stacks/create/standalone/repository?endpointId=$endpoint_id" "$payload")

    if echo "$response" | jq -e '.Id' > /dev/null 2>&1; then
        local stack_id
        stack_id=$(echo "$response" | jq -r '.Id')
        log_info "Stack created successfully: ID=$stack_id"
    else
        log_error "Failed to create stack: $response"
        return 1
    fi
}

# Load environment variables for a stack
# Priority: Vault > Current stack env > .env file
load_env_vars() {
    local stack_name="$1"
    local stack_info="$2"
    local repo_id="${3:-default}"

    local env_vars="[]"

    # 1. Try Vault
    if [[ "$USE_VAULT" == "true" ]] && [[ -n "$VAULT_TOKEN" ]]; then
        env_vars=$(vault_get_service_env "$stack_name")
        if [[ "$env_vars" != "[]" ]]; then
            log_info "Env loaded from Vault: secret/portainer/$stack_name"
        fi
    fi

    # 2. Fallback to current stack env vars
    if [[ "$env_vars" == "[]" ]] && [[ -n "$stack_info" ]]; then
        env_vars=$(echo "$stack_info" | jq -c '.Env // []')
    fi

    # 3. Fallback to .env file (only for default repo with local paths)
    if [[ "$env_vars" == "[]" || "$env_vars" == "null" ]] && [[ "$repo_id" == "default" ]]; then
        local compose_path=""
        if [[ -n "${STACKS[$stack_name]}" ]]; then
            local stack_def="${STACKS[$stack_name]}"
            compose_path=$(get_stack_compose_path "$stack_def")
            local endpoint_name=$(get_stack_endpoint "$stack_def")
            local base_path=$(get_base_path "$endpoint_name")
        else
            compose_path=$(echo "$stack_info" | jq -r '.GitConfig.ConfigFilePath // empty')
            local base_path="$MAC_MINI_BASE"
        fi
        if [[ -n "$compose_path" ]]; then
            local env_file="${base_path}/${compose_path%/*}/.env"
            if [[ -f "$env_file" ]]; then
                log_info "Env loaded from file: $env_file"
                env_vars=$(grep -v '^#' "$env_file" | grep '=' | while IFS='=' read -r key value; do
                    value="${value%\"}"
                    value="${value#\"}"
                    echo "{\"name\": \"$key\", \"value\": \"$value\"}"
                done | jq -s '.')
            fi
        fi
    fi

    echo "$env_vars"
}

delete_stack() {
    local stack_name="$1"
    local stack_id
    stack_id=$(get_stack_id "$stack_name")

    if [[ -z "$stack_id" ]]; then
        log_warn "Stack not found: $stack_name"
        return 1
    fi

    # Get endpoint ID from stack definition
    local endpoint_id
    if [[ -n "${STACKS[$stack_name]}" ]]; then
        local stack_def="${STACKS[$stack_name]}"
        local endpoint_name=$(get_stack_endpoint "$stack_def")
        endpoint_id=$(get_endpoint_id "$endpoint_name")
    else
        # Fallback: get from current stack info
        local stack_info
        stack_info=$(api_call GET "/stacks/$stack_id")
        endpoint_id=$(echo "$stack_info" | jq -r '.EndpointId')
    fi

    log_info "Deleting stack: $stack_name (ID=$stack_id, endpoint=$endpoint_id)"
    api_call DELETE "/stacks/$stack_id?endpointId=$endpoint_id"
    log_info "Stack deleted"
}

update_stack() {
    local stack_name="$1"
    local stack_id
    stack_id=$(get_stack_id "$stack_name")

    if [[ -z "$stack_id" ]]; then
        log_warn "Stack not found: $stack_name (use 'create' to register)"
        return 1
    fi

    # Resolve repo config
    local repo_id="default"
    if [[ -n "${STACKS[$stack_name]}" ]]; then
        local stack_def="${STACKS[$stack_name]}"
        repo_id=$(get_stack_repo_id "$stack_def")
    fi
    resolve_repo_config "$repo_id" || return 1

    # Get current stack info
    local stack_info
    stack_info=$(api_call GET "/stacks/$stack_id")

    # Get endpoint ID from stack definition or current stack
    local endpoint_id
    if [[ -n "${STACKS[$stack_name]}" ]]; then
        local stack_def="${STACKS[$stack_name]}"
        local endpoint_name=$(get_stack_endpoint "$stack_def")
        endpoint_id=$(get_endpoint_id "$endpoint_name")
    else
        endpoint_id=$(echo "$stack_info" | jq -r '.EndpointId')
    fi

    log_info "Updating stack: $stack_name (PUT redeploy, repo=$repo_id)"

    # Load env vars: Vault > current stack > .env file
    local env_vars
    env_vars=$(load_env_vars "$stack_name" "$stack_info" "$repo_id")

    # Build PUT redeploy payload
    local payload
    payload=$(jq -n \
        --arg branch "refs/heads/$RESOLVED_BRANCH" \
        --arg gitUser "$RESOLVED_USERNAME" \
        --arg gitToken "$RESOLVED_TOKEN" \
        --argjson env "$env_vars" \
        '{
            env: $env,
            prune: false,
            repositoryReferenceName: $branch
        } + (if $gitUser != "" then {
            repositoryAuthentication: true,
            repositoryUsername: $gitUser,
            repositoryPassword: $gitToken
        } else {} end)'
    )

    local response
    response=$(api_call PUT "/stacks/$stack_id/git/redeploy?endpointId=$endpoint_id" "$payload")

    if echo "$response" | jq -e '.Id' > /dev/null 2>&1; then
        log_info "Stack updated successfully: ID=$stack_id"
    else
        log_error "Failed to update stack: $response"
        return 1
    fi
}

recreate_stack() {
    local stack_name="$1"
    local force="${2:-false}"
    local stack_id
    stack_id=$(get_stack_id "$stack_name")

    if [[ -z "$stack_id" ]]; then
        log_warn "Stack not found: $stack_name (use 'create' to register)"
        return 1
    fi

    # Resolve repo config
    local repo_id="default"
    if [[ -n "${STACKS[$stack_name]}" ]]; then
        local stack_def="${STACKS[$stack_name]}"
        repo_id=$(get_stack_repo_id "$stack_def")
    fi
    resolve_repo_config "$repo_id" || return 1

    # Get current stack info
    local stack_info
    stack_info=$(api_call GET "/stacks/$stack_id")

    # Get endpoint ID from stack definition or current stack
    local endpoint_id
    if [[ -n "${STACKS[$stack_name]}" ]]; then
        local stack_def="${STACKS[$stack_name]}"
        local endpoint_name=$(get_stack_endpoint "$stack_def")
        endpoint_id=$(get_endpoint_id "$endpoint_name")
    else
        endpoint_id=$(echo "$stack_info" | jq -r '.EndpointId')
    fi

    # Confirmation prompt (unless --force)
    if [[ "$force" != "true" ]]; then
        log_warn "This will DELETE and RECREATE stack: $stack_name"
        echo -n "Continue? (y/N) " >&2
        read -k 1 REPLY
        echo >&2
        if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
            log_info "Cancelled"
            return 0
        fi
    fi

    log_info "Recreating stack: $stack_name (delete + create, repo=$repo_id)"

    # Prefer compose path from STACKS definition (fixes path drift)
    local compose_path
    if [[ -n "${STACKS[$stack_name]}" ]]; then
        local stack_def="${STACKS[$stack_name]}"
        compose_path=$(get_stack_compose_path "$stack_def")
        log_info "Using STACKS definition path: $compose_path"
    else
        compose_path=$(echo "$stack_info" | jq -r '.GitConfig.ConfigFilePath')
        log_info "Using current stack path: $compose_path"
    fi

    # Load env vars: Vault > current stack > .env file
    local env_vars
    env_vars=$(load_env_vars "$stack_name" "$stack_info" "$repo_id")

    # Delete stack
    log_info "Deleting old stack..."
    api_call DELETE "/stacks/$stack_id?endpointId=$endpoint_id" > /dev/null

    sleep 2

    # Recreate stack
    log_info "Creating new stack..."
    local payload
    payload=$(jq -n \
        --arg name "$stack_name" \
        --arg repoUrl "$RESOLVED_REPO_URL" \
        --arg branch "refs/heads/$RESOLVED_BRANCH" \
        --arg compose "$compose_path" \
        --arg interval "$AUTO_UPDATE_INTERVAL" \
        --arg gitUser "$RESOLVED_USERNAME" \
        --arg gitToken "$RESOLVED_TOKEN" \
        --argjson env "$env_vars" \
        '{
            name: $name,
            repositoryURL: $repoUrl,
            repositoryReferenceName: $branch,
            composeFile: $compose,
            env: $env,
            autoUpdate: {
                interval: $interval
            }
        } + (if $gitUser != "" then {
            repositoryAuthentication: true,
            repositoryUsername: $gitUser,
            repositoryPassword: $gitToken
        } else {} end)'
    )

    local response
    response=$(api_call POST "/stacks/create/standalone/repository?endpointId=$endpoint_id" "$payload")

    if echo "$response" | jq -e '.Id' > /dev/null 2>&1; then
        local new_stack_id
        new_stack_id=$(echo "$response" | jq -r '.Id')
        log_info "Stack recreated successfully: ID=$new_stack_id"
    else
        log_error "Failed to recreate stack: $response"
        return 1
    fi
}

# === Main Commands ===
cmd_list() {
    check_requirements
    echo ""
    echo "=== Portainer Stacks ==="
    echo "ID	Name	Status"
    echo "---	----	------"
    list_stacks
    echo ""
}

cmd_create() {
    local stack_name="$1"
    check_requirements

    if [[ -z "$stack_name" ]]; then
        log_error "Stack name required"
        echo "Usage: $0 create <stack-name>"
        echo "Available stacks: ${(k)STACKS[*]}"
        exit 1
    fi

    if [[ -z "${STACKS[$stack_name]}" ]]; then
        log_error "Unknown stack: $stack_name"
        echo "Available stacks: ${(k)STACKS[*]}"
        exit 1
    fi

    local stack_def="${STACKS[$stack_name]}"
    local endpoint_name=$(get_stack_endpoint "$stack_def")
    local compose_path=$(get_stack_compose_path "$stack_def")
    local repo_id=$(get_stack_repo_id "$stack_def")
    local endpoint_id=$(get_endpoint_id "$endpoint_name")

    # .env file only for default repo (local paths)
    local env_file=""
    if [[ "$repo_id" == "default" ]]; then
        local base_path=$(get_base_path "$endpoint_name")
        local service_dir="${compose_path:h}"
        env_file="${base_path}/${service_dir}/.env"
    fi

    log_info "Stack: $stack_name -> $endpoint_name (endpoint_id=$endpoint_id, repo=$repo_id)"

    # Check if stack already exists
    if [[ -n "$(get_stack_id "$stack_name")" ]]; then
        log_error "Stack already exists: $stack_name"
        echo "  Use 'update' to redeploy or 'recreate' to delete+recreate."
        exit 1
    fi

    create_stack "$stack_name" "$compose_path" "$env_file" "$endpoint_id" "$repo_id"
}

cmd_create_all() {
    check_requirements
    log_info "Creating all stacks..."

    for stack_name in "${(k)STACKS[@]}"; do
        echo ""
        log_info "=== Processing: $stack_name ==="

        if [[ -n "$(get_stack_id "$stack_name")" ]]; then
            log_warn "Stack already exists, skipping: $stack_name"
            continue
        fi

        local stack_def="${STACKS[$stack_name]}"
        local endpoint_name=$(get_stack_endpoint "$stack_def")
        local compose_path=$(get_stack_compose_path "$stack_def")
        local repo_id=$(get_stack_repo_id "$stack_def")
        local endpoint_id=$(get_endpoint_id "$endpoint_name")

        # .env file only for default repo (local paths)
        local env_file=""
        if [[ "$repo_id" == "default" ]]; then
            local base_path=$(get_base_path "$endpoint_name")
            local service_dir="${compose_path:h}"
            env_file="${base_path}/${service_dir}/.env"
        fi

        log_info "Target: $endpoint_name (endpoint_id=$endpoint_id, repo=$repo_id)"
        create_stack "$stack_name" "$compose_path" "$env_file" "$endpoint_id" "$repo_id"
        sleep 2
    done

    echo ""
    log_info "Done! All stacks created."
}

cmd_delete() {
    local stack_name="$1"
    check_requirements

    if [[ -z "$stack_name" ]]; then
        log_error "Stack name required"
        exit 1
    fi

    delete_stack "$stack_name"
}

# Stacks to skip during bulk update (restart causes cascading failures)
UPDATE_ALL_SKIP=(vault)

cmd_update() {
    local stack_name="$1"
    check_requirements

    if [[ -z "$stack_name" ]]; then
        log_info "Updating all stacks (skipping: ${UPDATE_ALL_SKIP[*]})..."
        for stack_name in "${(k)STACKS[@]}"; do
            if (( ${UPDATE_ALL_SKIP[(Ie)$stack_name]} )); then
                log_warn "Skipping $stack_name (in UPDATE_ALL_SKIP)"
                continue
            fi
            update_stack "$stack_name" || true
        done
    else
        update_stack "$stack_name"
    fi
}

cmd_recreate() {
    local stack_name="$1"
    local force="false"
    check_requirements

    # Parse --force flag
    if [[ "$stack_name" == "--force" ]]; then
        force="true"
        stack_name="$2"
    elif [[ "${2:-}" == "--force" ]] || [[ "${3:-}" == "--force" ]]; then
        force="true"
    fi

    if [[ -z "$stack_name" ]] || [[ "$stack_name" == "--force" ]]; then
        log_error "Stack name required"
        echo "Usage: $0 recreate [--force] <stack-name>"
        exit 1
    fi

    recreate_stack "$stack_name" "$force"
}

cmd_migrate() {
    check_requirements
    log_info "=== GitOps Migration Helper ==="
    echo ""
    echo "This will help you migrate existing services to GitOps."
    echo ""
    echo "NOTE: This only checks local (Mac Mini) containers."
    echo "      For NAS services, check directly on the NAS."
    echo ""

    # Check running containers (local only)
    log_info "Checking local containers..."
    echo ""

    for stack_name in "${(k)STACKS[@]}"; do
        local stack_def="${STACKS[$stack_name]}"
        local endpoint_name=$(get_stack_endpoint "$stack_def")

        # Only check local containers
        if [[ "$endpoint_name" == "mac-mini" ]]; then
            local container_status
            container_status=$(docker ps --filter "name=$stack_name" --format "{{.Names}}: {{.Status}}" 2>/dev/null || echo "")

            if [[ -n "$container_status" ]]; then
                print -P "  %F{yellow}[RUNNING]%f $container_status"
            else
                print -P "  %F{green}[STOPPED]%f $stack_name"
            fi
        else
            print -P "  %F{blue}[REMOTE]%f $stack_name ($endpoint_name)"
        fi
    done

    echo ""
    log_warn "Before creating GitOps stacks, stop existing containers:"
    echo ""
    echo "  # Mac Mini services"
    for stack_name in "${(k)STACKS[@]}"; do
        local stack_def="${STACKS[$stack_name]}"
        local endpoint_name=$(get_stack_endpoint "$stack_def")
        local compose_path=$(get_stack_compose_path "$stack_def")
        local base_path=$(get_base_path "$endpoint_name")
        local service_dir="${compose_path:h}"

        if [[ "$endpoint_name" == "mac-mini" ]]; then
            echo "  cd ${base_path}/$service_dir && docker compose down"
        fi
    done
    echo ""
    echo "  # NAS services (run on NAS)"
    for stack_name in "${(k)STACKS[@]}"; do
        local stack_def="${STACKS[$stack_name]}"
        local endpoint_name=$(get_stack_endpoint "$stack_def")
        local compose_path=$(get_stack_compose_path "$stack_def")
        local service_dir="${compose_path:h}"

        if [[ "$endpoint_name" == "nas" ]]; then
            echo "  # ssh nas: cd $NAS_BASE/$service_dir && docker compose down"
        fi
    done
    echo ""
    echo "  # Then create GitOps stacks"
    echo "  ./scripts/portainer-gitops.sh create-all"
    echo "  # Or create individually:"
    echo "  ./scripts/portainer-gitops.sh create gitlab-ce"
}

# === Usage ===
usage() {
    echo "Portainer GitOps Stack Manager (with Vault integration)"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  list              List all stacks"
    echo "  create <name>     Create a new stack (fails if exists)"
    echo "  create-all        Create all undefined stacks"
    echo "  update [name]     Redeploy stack(s) from Git (safe, PUT redeploy; bulk skips vault)"
    echo "  recreate <name>   Delete + recreate stack (for source URL changes)"
    echo "  delete <name>     Delete a stack"
    echo "  migrate           Show migration helper"
    echo ""
    echo "Available stacks:"
    for stack_name in "${(ko)STACKS[@]}"; do
        local stack_def="${STACKS[$stack_name]}"
        local endpoint_name=$(get_stack_endpoint "$stack_def")
        local repo_id=$(get_stack_repo_id "$stack_def")
        if [[ "$repo_id" == "default" ]]; then
            printf "  %-25s %s\n" "$stack_name" "($endpoint_name)"
        else
            printf "  %-25s %s\n" "$stack_name" "($endpoint_name, repo=$repo_id)"
        fi
    done
    echo ""
    echo "Multi-Repo Support:"
    echo "  Stacks default to the my-devops repo (GitLab)."
    echo "  External repos (GitHub/GitLab): add to REPOS + STACKS arrays."
    echo "  STACKS format: \"endpoint:compose_path:repo_id\""
    echo "  Vault path:    secret/portainer/repos/{repo_id}"
    echo "  Vault keys:    REPO_URL, BRANCH, USERNAME, TOKEN"
    echo "  Env fallback:  REPO_{ID}_URL, REPO_{ID}_USERNAME, REPO_{ID}_TOKEN"
    echo ""
    echo "Vault Integration (recommended):"
    echo "  VAULT_TOKEN           Vault token for authentication"
    echo "  VAULT_ADDR            Vault address (default: http://192.168.0.48:28200)"
    echo "  USE_VAULT             Enable Vault (default: true)"
    echo ""
    echo "Legacy Environment Variables:"
    echo "  PORTAINER_API_KEY     API token (loaded from Vault if VAULT_TOKEN set)"
    echo "  GIT_USERNAME          Git username (loaded from Vault if VAULT_TOKEN set)"
    echo "  GIT_TOKEN             Git access token (loaded from Vault if VAULT_TOKEN set)"
    echo ""
    echo "Example (with Vault):"
    echo "  export VAULT_TOKEN='hvs.xxxxx'"
    echo "  $0 create grafana"
    echo ""
    echo "Example (external repo via env):"
    echo "  export PORTAINER_API_KEY='ptr_xxxxx'"
    echo "  export REPO_MY_APP_URL='https://github.com/org/my-app.git'"
    echo "  export REPO_MY_APP_USERNAME='github-user'"
    echo "  export REPO_MY_APP_TOKEN='ghp_xxxxx'"
    echo "  USE_VAULT=false $0 create my-app"
}

# === Main ===
case "${1:-}" in
    list)       cmd_list ;;
    create)     cmd_create "$2" ;;
    create-all) cmd_create_all ;;
    update)     cmd_update "$2" ;;
    recreate)   cmd_recreate "$2" "$3" ;;
    delete)     cmd_delete "$2" ;;
    migrate)    cmd_migrate ;;
    -h|--help)  usage ;;
    *)          usage; exit 1 ;;
esac
