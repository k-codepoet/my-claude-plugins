#!/bin/zsh
# GitLab API Helper
# Self-hosted GitLab CE API 관리 스크립트
# Vault 연동으로 PAT 중앙 관리

set -e

# === Configuration ===
GITLAB_URL="${GITLAB_URL:-https://gitlab.home.codepoet.site}"
GITLAB_TOKEN="${GITLAB_TOKEN:-}"
VAULT_ADDR="${VAULT_ADDR:-http://192.168.0.48:28200}"
VAULT_TOKEN="${VAULT_TOKEN:-}"
USE_VAULT="${USE_VAULT:-true}"

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# === Helper Functions ===
log_info() { print -P "%F{green}[INFO]%f $1"; }
log_warn() { print -P "%F{yellow}[WARN]%f $1"; }
log_error() { print -P "%F{red}[ERROR]%f $1"; }

# === Vault Functions ===
vault_get_secret() {
    local secret_path="$1"
    curl -s -H "X-Vault-Token: $VAULT_TOKEN" \
        "${VAULT_ADDR}/v1/${secret_path}" | jq -r '.data.data // empty'
}

vault_load_gitlab_config() {
    if [[ "$USE_VAULT" != "true" ]] || [[ -z "$VAULT_TOKEN" ]]; then
        return 0
    fi

    log_info "Loading GitLab config from Vault..."
    local secrets
    secrets=$(vault_get_secret "secret/data/common/gitlab" 2>/dev/null || echo "")

    if [[ -z "$secrets" ]]; then
        log_warn "Could not load from Vault, using environment variables"
        return 0
    fi

    [[ -z "$GITLAB_TOKEN" ]] && GITLAB_TOKEN=$(echo "$secrets" | jq -r '.GITLAB_TOKEN // empty')
    [[ -z "$GITLAB_URL" ]] && GITLAB_URL=$(echo "$secrets" | jq -r '.GITLAB_URL // empty')

    log_info "Configuration loaded from Vault"
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

    vault_load_gitlab_config

    if [[ -z "$GITLAB_TOKEN" ]]; then
        log_error "GITLAB_TOKEN is required"
        echo ""
        echo "Option 1: Set VAULT_TOKEN to load from Vault"
        echo "  export VAULT_TOKEN='hvs.xxxxx'"
        echo ""
        echo "Option 2: Set directly"
        echo "  export GITLAB_TOKEN='glpat-xxxxx'"
        exit 1
    fi
}

# === GitLab API ===
gitlab_api() {
    local method="$1"
    local endpoint="$2"
    local data="$3"

    local curl_opts=(-s -X "$method")
    curl_opts+=(-H "PRIVATE-TOKEN: $GITLAB_TOKEN")
    curl_opts+=(-H "Content-Type: application/json")

    if [[ -n "$data" ]]; then
        curl_opts+=(-d "$data")
    fi

    curl "${curl_opts[@]}" "${GITLAB_URL}/api/v4${endpoint}"
}

# === Project Commands ===
cmd_projects_list() {
    check_requirements
    log_info "Listing projects..."
    gitlab_api GET "/projects?membership=true&per_page=50" | \
        jq -r '.[] | "\(.id)\t\(.path_with_namespace)\t\(.visibility)\t\(.default_branch // "—")"' | \
        column -t -s $'\t'
}

cmd_projects_get() {
    local project="$1"
    check_requirements

    if [[ -z "$project" ]]; then
        log_error "Project ID or path required"
        echo "Usage: $0 projects get <id-or-path>"
        exit 1
    fi

    local encoded=$(echo "$project" | sed 's/\//%2F/g')
    gitlab_api GET "/projects/$encoded" | jq '.'
}

cmd_projects_create() {
    local name="$1"
    shift || true
    check_requirements

    if [[ -z "$name" ]]; then
        log_error "Project name required"
        echo "Usage: $0 projects create <name> [--group <group>] [--visibility <public|private|internal>]"
        exit 1
    fi

    local visibility="private"
    local namespace_id=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --visibility) visibility="$2"; shift 2 ;;
            --group) namespace_id="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    local payload
    payload=$(jq -n \
        --arg name "$name" \
        --arg vis "$visibility" \
        --arg ns "$namespace_id" \
        '{name: $name, visibility: $vis} + (if $ns != "" then {namespace_id: ($ns | tonumber)} else {} end)'
    )

    log_info "Creating project: $name (visibility=$visibility)"
    local response
    response=$(gitlab_api POST "/projects" "$payload")

    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        local project_id
        project_id=$(echo "$response" | jq -r '.id')
        local web_url
        web_url=$(echo "$response" | jq -r '.web_url')
        log_info "Project created: ID=$project_id"
        echo "  URL: $web_url"
        echo "  SSH: git clone gitlab-ssh:$(echo "$response" | jq -r '.path_with_namespace').git"
    else
        log_error "Failed to create project: $(echo "$response" | jq -r '.message // .error // .')"
        return 1
    fi
}

cmd_projects_delete() {
    local project="$1"
    check_requirements

    if [[ -z "$project" ]]; then
        log_error "Project ID or path required"
        exit 1
    fi

    local encoded=$(echo "$project" | sed 's/\//%2F/g')
    log_info "Deleting project: $project"
    gitlab_api DELETE "/projects/$encoded" | jq '.'
}

# === Merge Request Commands ===
cmd_mrs_list() {
    local project="$1"
    check_requirements

    if [[ -z "$project" ]]; then
        log_error "Project ID or path required"
        echo "Usage: $0 mrs list <project>"
        exit 1
    fi

    local encoded=$(echo "$project" | sed 's/\//%2F/g')
    log_info "Listing merge requests for: $project"
    gitlab_api GET "/projects/$encoded/merge_requests?state=opened&per_page=50" | \
        jq -r '.[] | "\(.iid)\t\(.title)\t\(.source_branch) → \(.target_branch)\t\(.author.username)"' | \
        column -t -s $'\t'
}

cmd_mrs_create() {
    local project="$1"
    shift || true
    check_requirements

    if [[ -z "$project" ]]; then
        log_error "Project required"
        echo "Usage: $0 mrs create <project> --source <branch> --target <branch> --title <title>"
        exit 1
    fi

    local source="" target="main" title=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --source) source="$2"; shift 2 ;;
            --target) target="$2"; shift 2 ;;
            --title)  title="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [[ -z "$source" ]] || [[ -z "$title" ]]; then
        log_error "--source and --title are required"
        exit 1
    fi

    local encoded=$(echo "$project" | sed 's/\//%2F/g')
    local payload
    payload=$(jq -n \
        --arg source "$source" \
        --arg target "$target" \
        --arg title "$title" \
        '{source_branch: $source, target_branch: $target, title: $title}'
    )

    log_info "Creating MR: $title ($source → $target)"
    local response
    response=$(gitlab_api POST "/projects/$encoded/merge_requests" "$payload")

    if echo "$response" | jq -e '.iid' > /dev/null 2>&1; then
        local mr_iid
        mr_iid=$(echo "$response" | jq -r '.iid')
        local web_url
        web_url=$(echo "$response" | jq -r '.web_url')
        log_info "MR created: !$mr_iid"
        echo "  URL: $web_url"
    else
        log_error "Failed: $(echo "$response" | jq -r '.message // .error // .')"
        return 1
    fi
}

cmd_mrs_merge() {
    local project="$1"
    local mr_iid="$2"
    check_requirements

    if [[ -z "$project" ]] || [[ -z "$mr_iid" ]]; then
        log_error "Project and MR IID required"
        echo "Usage: $0 mrs merge <project> <mr_iid>"
        exit 1
    fi

    local encoded=$(echo "$project" | sed 's/\//%2F/g')
    log_info "Merging MR !$mr_iid in $project"
    local response
    response=$(gitlab_api PUT "/projects/$encoded/merge_requests/$mr_iid/merge")

    if echo "$response" | jq -e '.state == "merged"' > /dev/null 2>&1; then
        log_info "MR !$mr_iid merged successfully"
    else
        log_error "Failed: $(echo "$response" | jq -r '.message // .error // .')"
        return 1
    fi
}

cmd_mrs_comment() {
    local project="$1"
    local mr_iid="$2"
    local body="$3"
    check_requirements

    if [[ -z "$project" ]] || [[ -z "$mr_iid" ]] || [[ -z "$body" ]]; then
        log_error "Project, MR IID, and comment body required"
        echo "Usage: $0 mrs comment <project> <mr_iid> <body>"
        exit 1
    fi

    local encoded=$(echo "$project" | sed 's/\//%2F/g')
    local payload
    payload=$(jq -n --arg body "$body" '{body: $body}')

    log_info "Adding comment to MR !$mr_iid"
    local response
    response=$(gitlab_api POST "/projects/$encoded/merge_requests/$mr_iid/notes" "$payload")

    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        log_info "Comment added"
    else
        log_error "Failed: $(echo "$response" | jq -r '.message // .error // .')"
        return 1
    fi
}

# === Issue Commands ===
cmd_issues_list() {
    local project="$1"
    check_requirements

    if [[ -z "$project" ]]; then
        log_error "Project ID or path required"
        echo "Usage: $0 issues list <project>"
        exit 1
    fi

    local encoded=$(echo "$project" | sed 's/\//%2F/g')
    log_info "Listing issues for: $project"
    gitlab_api GET "/projects/$encoded/issues?state=opened&per_page=50" | \
        jq -r '.[] | "\(.iid)\t\(.title)\t\(.state)\t\(.author.username)"' | \
        column -t -s $'\t'
}

cmd_issues_create() {
    local project="$1"
    shift || true
    check_requirements

    if [[ -z "$project" ]]; then
        log_error "Project required"
        echo "Usage: $0 issues create <project> --title <title> [--description <desc>] [--labels <l1,l2>]"
        exit 1
    fi

    local title="" description="" labels=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --title)       title="$2"; shift 2 ;;
            --description) description="$2"; shift 2 ;;
            --labels)      labels="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [[ -z "$title" ]]; then
        log_error "--title is required"
        exit 1
    fi

    local encoded=$(echo "$project" | sed 's/\//%2F/g')
    local payload
    payload=$(jq -n \
        --arg title "$title" \
        --arg desc "$description" \
        --arg labels "$labels" \
        '{title: $title} + (if $desc != "" then {description: $desc} else {} end) + (if $labels != "" then {labels: $labels} else {} end)'
    )

    log_info "Creating issue: $title"
    local response
    response=$(gitlab_api POST "/projects/$encoded/issues" "$payload")

    if echo "$response" | jq -e '.iid' > /dev/null 2>&1; then
        local issue_iid
        issue_iid=$(echo "$response" | jq -r '.iid')
        local web_url
        web_url=$(echo "$response" | jq -r '.web_url')
        log_info "Issue created: #$issue_iid"
        echo "  URL: $web_url"
    else
        log_error "Failed: $(echo "$response" | jq -r '.message // .error // .')"
        return 1
    fi
}

cmd_issues_comment() {
    local project="$1"
    local issue_iid="$2"
    local body="$3"
    check_requirements

    if [[ -z "$project" ]] || [[ -z "$issue_iid" ]] || [[ -z "$body" ]]; then
        log_error "Project, issue IID, and comment body required"
        echo "Usage: $0 issues comment <project> <issue_iid> <body>"
        exit 1
    fi

    local encoded=$(echo "$project" | sed 's/\//%2F/g')
    local payload
    payload=$(jq -n --arg body "$body" '{body: $body}')

    log_info "Adding comment to issue #$issue_iid"
    local response
    response=$(gitlab_api POST "/projects/$encoded/issues/$issue_iid/notes" "$payload")

    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        log_info "Comment added"
    else
        log_error "Failed: $(echo "$response" | jq -r '.message // .error // .')"
        return 1
    fi
}

# === Groups ===
cmd_groups_list() {
    check_requirements
    log_info "Listing groups..."
    gitlab_api GET "/groups?per_page=50" | \
        jq -r '.[] | "\(.id)\t\(.full_path)\t\(.visibility)"' | \
        column -t -s $'\t'
}

# === Test ===
cmd_test() {
    check_requirements
    log_info "Testing GitLab API connection..."
    echo "  URL: $GITLAB_URL"

    local response
    response=$(gitlab_api GET "/version")

    if echo "$response" | jq -e '.version' > /dev/null 2>&1; then
        local version
        version=$(echo "$response" | jq -r '.version')
        log_info "Connected! GitLab version: $version"
    else
        log_error "Connection failed: $(echo "$response" | jq -r '.message // .error // .')"
        return 1
    fi
}

# === Usage ===
usage() {
    echo "GitLab API Helper (with Vault integration)"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  test                                    Test API connection"
    echo ""
    echo "  projects list                           List projects"
    echo "  projects get <id-or-path>               Get project details"
    echo "  projects create <name> [options]         Create project"
    echo "    --visibility <public|private|internal>"
    echo "    --group <namespace_id>"
    echo "  projects delete <id-or-path>            Delete project"
    echo ""
    echo "  mrs list <project>                      List open MRs"
    echo "  mrs create <project> [options]           Create MR"
    echo "    --source <branch> --target <branch> --title <title>"
    echo "  mrs merge <project> <mr_iid>            Merge MR"
    echo "  mrs comment <project> <mr_iid> <body>   Comment on MR"
    echo ""
    echo "  issues list <project>                   List open issues"
    echo "  issues create <project> [options]        Create issue"
    echo "    --title <title> [--description <desc>] [--labels <l1,l2>]"
    echo "  issues comment <project> <iid> <body>   Comment on issue"
    echo ""
    echo "  groups list                             List groups"
    echo ""
    echo "Vault Integration (recommended):"
    echo "  export VAULT_TOKEN='hvs.xxxxx'"
    echo "  Loads GITLAB_TOKEN from secret/common/gitlab"
    echo ""
    echo "Direct:"
    echo "  export GITLAB_TOKEN='glpat-xxxxx'"
    echo "  USE_VAULT=false $0 test"
}

# === Main ===
case "${1:-}" in
    test)     cmd_test ;;
    projects)
        case "${2:-}" in
            list)   cmd_projects_list ;;
            get)    cmd_projects_get "$3" ;;
            create) shift 2; cmd_projects_create "$@" ;;
            delete) cmd_projects_delete "$3" ;;
            *)      usage; exit 1 ;;
        esac
        ;;
    mrs)
        case "${2:-}" in
            list)    cmd_mrs_list "$3" ;;
            create)  shift 2; cmd_mrs_create "$@" ;;
            merge)   cmd_mrs_merge "$3" "$4" ;;
            comment) cmd_mrs_comment "$3" "$4" "$5" ;;
            *)       usage; exit 1 ;;
        esac
        ;;
    issues)
        case "${2:-}" in
            list)    cmd_issues_list "$3" ;;
            create)  shift 2; cmd_issues_create "$@" ;;
            comment) cmd_issues_comment "$3" "$4" "$5" ;;
            *)       usage; exit 1 ;;
        esac
        ;;
    groups)
        case "${2:-}" in
            list) cmd_groups_list ;;
            *)    usage; exit 1 ;;
        esac
        ;;
    -h|--help) usage ;;
    *)         usage; exit 1 ;;
esac
