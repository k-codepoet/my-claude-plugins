#!/bin/bash
#
# K3s Cluster Restore Script
# Applies saved manifests to the cluster
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
DEFAULT_IAC_ROOT="$HOME/my-iac"
IAC_ROOT=""

DRY_RUN=false
NAMESPACE=""

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Restore K3s cluster from saved manifests.

Options:
    --dir DIR              IaC repository directory
                           (default: ~/my-iac)
    -n, --namespace NS     Restore only specific namespace
    -d, --dry-run          Show what would be applied without making changes
    -h, --help             Show this help message

Examples:
    $(basename "$0")                           # Restore all from ~/my-iac
    $(basename "$0") --dir ~/projects/my-iac   # Custom directory
    $(basename "$0") -n default                # Restore only default namespace
    $(basename "$0") --dry-run                 # Preview changes
EOF
    exit 0
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dir)
                IAC_ROOT="$2"
                shift 2
                ;;
            -n|--namespace)
                NAMESPACE="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done

    # Use default if not specified
    if [ -z "$IAC_ROOT" ]; then
        IAC_ROOT="$DEFAULT_IAC_ROOT"
    fi

    # Expand ~ to home directory
    IAC_ROOT="${IAC_ROOT/#\~/$HOME}"

    # Set dependent paths
    K3S_DIR="${IAC_ROOT}/k3s"
    MANIFEST_DIR="${K3S_DIR}/manifest"
    HELM_DIR="${K3S_DIR}/helm"
}

# Check if IaC directory exists
check_iac_dir() {
    if [ ! -d "${IAC_ROOT}" ]; then
        log_error "IaC directory not found: ${IAC_ROOT}"
        log_error "Please run 'init-iac' first to initialize the IaC repository."
        log_error "Or specify a different directory with: --dir <directory>"
        exit 1
    fi
    log_success "IaC directory found: ${IAC_ROOT}"
}

# Check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl not found."
        exit 1
    fi

    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster."
        exit 1
    fi

    log_success "kubectl connected to cluster"
}

# Check if manifest directory exists
check_manifests() {
    if [ ! -d "$MANIFEST_DIR" ]; then
        log_error "Manifest directory not found: $MANIFEST_DIR"
        log_error "Run '/init-homeserver-with-k3s:snapshot' first to export cluster resources."
        exit 1
    fi

    log_success "Manifest directory found: $MANIFEST_DIR"
}

# Apply kubectl command (respects dry-run)
apply_manifest() {
    local file=$1
    local extra_args=""

    if [ "$DRY_RUN" = true ]; then
        extra_args="--dry-run=client"
    fi

    kubectl apply -f "$file" $extra_args 2>&1 || log_warn "Failed to apply: $file"
}

# Restore cluster-scoped resources first
restore_cluster_resources() {
    log_info "Restoring cluster-scoped resources..."

    local cluster_dir="${MANIFEST_DIR}/cluster"

    if [ ! -d "$cluster_dir" ]; then
        log_warn "No cluster resources found"
        return
    fi

    # Apply namespaces first
    for file in "${cluster_dir}"/namespaces_*.yaml; do
        [ -f "$file" ] || continue
        log_info "  Applying: $(basename "$file")"
        apply_manifest "$file"
    done

    # Apply other cluster resources
    for file in "${cluster_dir}"/*.yaml; do
        [ -f "$file" ] || continue
        [[ "$(basename "$file")" == namespaces_* ]] && continue

        log_info "  Applying: $(basename "$file")"
        apply_manifest "$file"
    done
}

# Restore namespaced resources
restore_namespaced_resources() {
    log_info "Restoring namespaced resources..."

    local ns_base="${MANIFEST_DIR}/namespaces"

    if [ ! -d "$ns_base" ]; then
        log_warn "No namespaced resources found"
        return
    fi

    for ns_dir in "${ns_base}"/*; do
        [ -d "$ns_dir" ] || continue

        ns_name=$(basename "$ns_dir")

        # Skip if namespace filter is set
        if [ -n "$NAMESPACE" ] && [ "$ns_name" != "$NAMESPACE" ]; then
            continue
        fi

        log_info "Processing namespace: ${ns_name}"

        # Apply resources in order: configmaps, secrets, services, deployments, etc.
        local order="configmaps secrets serviceaccounts services deployments ingresses"

        for resource in $order; do
            for file in "${ns_dir}"/${resource}_*.yaml; do
                [ -f "$file" ] || continue
                log_info "  Applying: $(basename "$file")"
                apply_manifest "$file"
            done
        done

        # Apply remaining files
        for file in "${ns_dir}"/*.yaml; do
            [ -f "$file" ] || continue

            # Skip already applied
            local base=$(basename "$file")
            local skip=false
            for resource in $order; do
                if [[ "$base" == ${resource}_* ]]; then
                    skip=true
                    break
                fi
            done
            [ "$skip" = true ] && continue

            log_info "  Applying: $(basename "$file")"
            apply_manifest "$file"
        done
    done
}

# Restore K3s Helm resources
restore_helm_resources() {
    log_info "Restoring K3s Helm resources..."

    # HelmChartConfigs (custom configurations)
    if [ -d "${HELM_DIR}/values" ]; then
        for file in "${HELM_DIR}/values"/*.yaml; do
            [ -f "$file" ] || continue
            log_info "  Applying HelmChartConfig: $(basename "$file")"
            apply_manifest "$file"
        done
    fi

    # Note: HelmCharts are usually managed by K3s, not restored manually
    log_info "  Note: HelmCharts are managed by K3s automatically"
}

# Main execution
main() {
    echo ""
    echo "============================================="
    echo "       K3s Cluster Restore Tool"
    echo "============================================="
    echo ""

    parse_args "$@"

    log_info "Using IaC directory: ${IAC_ROOT}"

    if [ "$DRY_RUN" = true ]; then
        log_warn "DRY RUN MODE - No changes will be made"
    fi

    check_iac_dir
    check_kubectl
    check_manifests

    restore_cluster_resources
    restore_namespaced_resources
    restore_helm_resources

    echo ""
    if [ "$DRY_RUN" = true ]; then
        log_success "============================================="
        log_success "  Dry run completed!"
        log_success "  Run without --dry-run to apply changes"
        log_success "============================================="
    else
        log_success "============================================="
        log_success "  Restore completed!"
        log_success "============================================="
    fi
    echo ""
}

# Run
main "$@"
