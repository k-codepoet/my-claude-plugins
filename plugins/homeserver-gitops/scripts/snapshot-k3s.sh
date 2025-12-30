#!/bin/bash
#
# K3s Cluster Snapshot Script
# Exports current cluster resources to manifest/helm folders
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
DEFAULT_IAC_ROOT="$HOME/my-iac"
IAC_ROOT=""

# Timestamp for backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Namespaces to exclude (system namespaces that shouldn't be exported)
EXCLUDE_NAMESPACES="kube-system kube-public kube-node-lease"

# Resource types to export
RESOURCE_TYPES="deployments services configmaps secrets ingresses persistentvolumeclaims serviceaccounts roles rolebindings"
CLUSTER_RESOURCE_TYPES="namespaces clusterroles clusterrolebindings persistentvolumes storageclasses ingressclasses"

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

Create a snapshot of the current K3s cluster state.

Options:
    -d, --directory DIR    IaC repository directory
                           (default: ~/my-iac)
    -h, --help             Show this help message

Examples:
    $(basename "$0")                           # Use default ~/my-iac
    $(basename "$0") -d ~/projects/my-iac      # Custom directory
EOF
    exit 0
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory)
                IAC_ROOT="$2"
                shift 2
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
    SNAPSHOT_DIR="${K3S_DIR}/snapshots"
}

# Check if IaC directory exists
check_iac_dir() {
    if [ ! -d "${IAC_ROOT}" ]; then
        log_error "IaC directory not found: ${IAC_ROOT}"
        log_error "Please run 'init-iac' first to initialize the IaC repository."
        log_error "Or specify a different directory with: -d <directory>"
        exit 1
    fi
    log_success "IaC directory found: ${IAC_ROOT}"
}

# Check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl not found. Please install kubectl or configure k3s kubectl."
        exit 1
    fi

    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster. Check your kubeconfig."
        exit 1
    fi

    log_success "kubectl connected to cluster"
}

# Initialize directories
init_dirs() {
    log_info "Initializing directories..."

    mkdir -p "${MANIFEST_DIR}/namespaces"
    mkdir -p "${MANIFEST_DIR}/cluster"
    mkdir -p "${HELM_DIR}/charts"
    mkdir -p "${HELM_DIR}/values"
    mkdir -p "${SNAPSHOT_DIR}"

    log_success "Directories initialized"
}

# Clean manifests (remove runtime fields)
clean_manifest() {
    local file=$1

    # Remove runtime fields that shouldn't be in version control
    if command -v yq &> /dev/null; then
        yq eval 'del(.metadata.creationTimestamp) |
                 del(.metadata.resourceVersion) |
                 del(.metadata.uid) |
                 del(.metadata.generation) |
                 del(.metadata.managedFields) |
                 del(.metadata.annotations["kubectl.kubernetes.io/last-applied-configuration"]) |
                 del(.status)' -i "$file" 2>/dev/null || true
    fi
}

# Export namespaced resources
export_namespaced_resources() {
    local namespace=$1
    local ns_dir="${MANIFEST_DIR}/namespaces/${namespace}"

    mkdir -p "$ns_dir"

    for resource in $RESOURCE_TYPES; do
        log_info "  Exporting ${resource}..."

        # Get resource names
        resources=$(kubectl get "$resource" -n "$namespace" -o name 2>/dev/null || true)

        if [ -n "$resources" ]; then
            for res in $resources; do
                res_name=$(echo "$res" | cut -d'/' -f2)
                res_file="${ns_dir}/${resource}_${res_name}.yaml"

                kubectl get "$res" -n "$namespace" -o yaml > "$res_file" 2>/dev/null || continue
                clean_manifest "$res_file"

                # Remove empty files
                if [ ! -s "$res_file" ]; then
                    rm -f "$res_file"
                fi
            done
        fi
    done
}

# Export cluster-scoped resources
export_cluster_resources() {
    log_info "Exporting cluster-scoped resources..."

    local cluster_dir="${MANIFEST_DIR}/cluster"

    for resource in $CLUSTER_RESOURCE_TYPES; do
        log_info "  Exporting ${resource}..."

        resources=$(kubectl get "$resource" -o name 2>/dev/null || true)

        if [ -n "$resources" ]; then
            for res in $resources; do
                res_name=$(echo "$res" | cut -d'/' -f2)

                # Skip system namespaces for namespace export
                if [ "$resource" = "namespaces" ]; then
                    if echo "$EXCLUDE_NAMESPACES default" | grep -qw "$res_name"; then
                        continue
                    fi
                fi

                res_file="${cluster_dir}/${resource}_${res_name}.yaml"

                kubectl get "$res" -o yaml > "$res_file" 2>/dev/null || continue
                clean_manifest "$res_file"

                if [ ! -s "$res_file" ]; then
                    rm -f "$res_file"
                fi
            done
        fi
    done
}

# Export K3s specific resources (HelmChart, HelmChartConfig)
export_k3s_helm_resources() {
    log_info "Exporting K3s Helm resources..."

    # HelmCharts
    local helmcharts=$(kubectl get helmchart -A -o json 2>/dev/null || echo '{"items":[]}')
    echo "$helmcharts" | jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)"' 2>/dev/null | while read line; do
        if [ -n "$line" ]; then
            ns=$(echo "$line" | cut -d'/' -f1)
            name=$(echo "$line" | cut -d'/' -f2)

            mkdir -p "${HELM_DIR}/charts"
            kubectl get helmchart "$name" -n "$ns" -o yaml > "${HELM_DIR}/charts/${name}.yaml" 2>/dev/null || true
            clean_manifest "${HELM_DIR}/charts/${name}.yaml"
            log_info "  Exported HelmChart: ${name}"
        fi
    done

    # HelmChartConfigs
    local helmchartconfigs=$(kubectl get helmchartconfig -A -o json 2>/dev/null || echo '{"items":[]}')
    echo "$helmchartconfigs" | jq -r '.items[] | "\(.metadata.namespace)/\(.metadata.name)"' 2>/dev/null | while read line; do
        if [ -n "$line" ]; then
            ns=$(echo "$line" | cut -d'/' -f1)
            name=$(echo "$line" | cut -d'/' -f2)

            mkdir -p "${HELM_DIR}/values"
            kubectl get helmchartconfig "$name" -n "$ns" -o yaml > "${HELM_DIR}/values/${name}-config.yaml" 2>/dev/null || true
            clean_manifest "${HELM_DIR}/values/${name}-config.yaml"
            log_info "  Exported HelmChartConfig: ${name}"
        fi
    done
}

# Export CRDs
export_crds() {
    log_info "Exporting Custom Resource Definitions..."

    local crd_dir="${MANIFEST_DIR}/cluster/crds"
    mkdir -p "$crd_dir"

    crds=$(kubectl get crd -o name 2>/dev/null || true)

    for crd in $crds; do
        crd_name=$(echo "$crd" | cut -d'/' -f2)

        # Skip K3s internal CRDs
        if echo "$crd_name" | grep -qE "^(helmcharts|helmchartconfigs|addons)\."; then
            continue
        fi

        kubectl get "$crd" -o yaml > "${crd_dir}/${crd_name}.yaml" 2>/dev/null || continue
        clean_manifest "${crd_dir}/${crd_name}.yaml"
        log_info "  Exported CRD: ${crd_name}"
    done
}

# Generate summary
generate_summary() {
    local summary_file="${SNAPSHOT_DIR}/snapshot_${TIMESTAMP}.md"

    local namespaces_list=$(find "${MANIFEST_DIR}/namespaces" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | sed 's/^/- /' || echo "- None")
    local cluster_files=$(ls "${MANIFEST_DIR}/cluster" 2>/dev/null | grep -v crds | sed 's/^/- /' || echo "- None")
    local helm_charts=$(ls "${HELM_DIR}/charts" 2>/dev/null | sed 's/^/- /' || echo "- None")
    local helm_values=$(ls "${HELM_DIR}/values" 2>/dev/null | sed 's/^/- /' || echo "- None")
    local manifest_count=$(find "${MANIFEST_DIR}" -name "*.yaml" 2>/dev/null | wc -l)
    local helm_count=$(find "${HELM_DIR}" -name "*.yaml" 2>/dev/null | wc -l)

    cat > "$summary_file" << EOF
# K3s Cluster Snapshot

**Timestamp:** ${TIMESTAMP}
**Generated:** $(date)
**Cluster:** $(kubectl config current-context 2>/dev/null || echo "default")
**IaC Root:** ${IAC_ROOT}

## Exported Resources

### Namespaces
${namespaces_list}

### Cluster Resources
${cluster_files}

### Helm Charts (K3s)
${helm_charts}

### Helm Chart Configs
${helm_values}

## File Counts
- Manifest files: ${manifest_count}
- Helm files: ${helm_count}

## Storage Locations
- Manifests: \`${MANIFEST_DIR}/\`
- Helm: \`${HELM_DIR}/\`
- This file: \`${summary_file}\`

---
*Generated by homeserver-gitops plugin*
EOF

    log_success "Snapshot info saved: ${summary_file}"
}

# Main execution
main() {
    echo ""
    echo "============================================="
    echo "       K3s Cluster Snapshot Tool"
    echo "============================================="
    echo ""

    parse_args "$@"
    check_iac_dir
    check_kubectl
    init_dirs

    # Get all namespaces except excluded ones
    log_info "Discovering namespaces..."
    all_namespaces=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

    for ns in $all_namespaces; do
        # Skip excluded namespaces
        if echo "$EXCLUDE_NAMESPACES" | grep -qw "$ns"; then
            log_warn "Skipping system namespace: ${ns}"
            continue
        fi

        log_info "Processing namespace: ${ns}"
        export_namespaced_resources "$ns"
    done

    # Also export kube-system but only specific resources (not everything)
    log_info "Processing kube-system (selective)..."
    mkdir -p "${MANIFEST_DIR}/namespaces/kube-system"

    # Export only user-created resources in kube-system (HelmChartConfigs)
    kubectl get helmchartconfig -n kube-system -o yaml > "${MANIFEST_DIR}/namespaces/kube-system/helmchartconfigs.yaml" 2>/dev/null || true

    export_cluster_resources
    export_k3s_helm_resources
    export_crds
    generate_summary

    echo ""
    log_success "============================================="
    log_success "  Snapshot completed!"
    log_success "  "
    log_success "  Manifests: ${K3S_DIR}/"
    log_success "  Snapshot info: ${SNAPSHOT_DIR}/snapshot_${TIMESTAMP}.md"
    log_success "============================================="
    echo ""
}

# Run
main "$@"
