#!/bin/bash
#
# K3s Installation Script for Linux Ubuntu Homeserver
# Detects existing Kubernetes environments and installs K3s if safe
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running on Linux Ubuntu
check_platform() {
    log_info "Checking platform..."

    if [ "$(uname -s)" != "Linux" ]; then
        log_error "This script only supports Linux. Detected: $(uname -s)"
        exit 1
    fi

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            log_warn "This script is optimized for Ubuntu. Detected: $ID"
            log_warn "Proceeding anyway, but some features may not work as expected."
        else
            log_success "Platform: Ubuntu $VERSION_ID"
        fi
    else
        log_warn "Could not determine Linux distribution."
    fi
}

# Check for existing Kubernetes installations
check_existing_k8s() {
    log_info "Checking for existing Kubernetes installations..."

    local found=false
    local existing=""

    # Check for MicroK8s
    if command -v microk8s &> /dev/null; then
        existing="$existing MicroK8s"
        found=true
    fi

    # Check for Minikube
    if command -v minikube &> /dev/null; then
        existing="$existing Minikube"
        found=true
    fi

    # Check for K3s
    if command -v k3s &> /dev/null || [ -f /usr/local/bin/k3s ]; then
        existing="$existing K3s"
        found=true
    fi

    # Check for Docker Desktop Kubernetes
    if docker info 2>/dev/null | grep -qi "kubernetes"; then
        existing="$existing DockerDesktopK8s"
        found=true
    fi

    # Check if kubectl can connect to any cluster
    if command -v kubectl &> /dev/null; then
        if kubectl cluster-info &> /dev/null; then
            existing="$existing (Active cluster detected)"
            found=true
        fi
    fi

    if [ "$found" = true ]; then
        log_warn "Existing Kubernetes environment(s) detected:$existing"
        log_warn "Installing K3s may cause conflicts."

        echo ""
        read -p "Do you want to proceed with K3s installation anyway? (y/N): " response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled by user."
            exit 0
        fi
        log_warn "Proceeding with installation..."
    else
        log_success "No existing Kubernetes installations found."
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    local missing=""

    if ! command -v curl &> /dev/null; then
        missing="$missing curl"
    fi

    if ! command -v git &> /dev/null; then
        missing="$missing git"
    fi

    if [ -n "$missing" ]; then
        log_error "Missing required tools:$missing"
        log_info "Install them with: sudo apt update && sudo apt install -y$missing"
        exit 1
    fi

    # Check sudo access
    if ! sudo -v &> /dev/null; then
        log_error "This script requires sudo privileges."
        exit 1
    fi

    log_success "All prerequisites met."
}

# Install K3s
install_k3s() {
    log_info "Installing K3s..."

    # Download and run K3s installation script
    curl -sfL https://get.k3s.io | sh -

    if [ $? -ne 0 ]; then
        log_error "K3s installation failed."
        exit 1
    fi

    log_success "K3s installed successfully."
}

# Setup kubeconfig for current user
setup_kubeconfig() {
    log_info "Setting up kubeconfig for current user..."

    # Create .kube directory
    mkdir -p "$HOME/.kube"

    # Wait for K3s to generate kubeconfig
    local max_wait=30
    local waited=0
    while [ ! -f /etc/rancher/k3s/k3s.yaml ] && [ $waited -lt $max_wait ]; do
        sleep 1
        waited=$((waited + 1))
    done

    if [ ! -f /etc/rancher/k3s/k3s.yaml ]; then
        log_error "K3s kubeconfig not found after ${max_wait} seconds."
        exit 1
    fi

    # Copy kubeconfig
    sudo cp /etc/rancher/k3s/k3s.yaml "$HOME/.kube/config"
    sudo chown "$USER:$USER" "$HOME/.kube/config"
    chmod 600 "$HOME/.kube/config"

    log_success "kubeconfig configured at ~/.kube/config"
}

# Verify installation
verify_installation() {
    log_info "Verifying K3s installation..."

    # Wait for node to be ready
    log_info "Waiting for node to be ready..."
    local max_wait=60
    local waited=0

    while ! kubectl get nodes 2>/dev/null | grep -q " Ready"; do
        if [ $waited -ge $max_wait ]; then
            log_error "Node not ready after ${max_wait} seconds."
            exit 1
        fi
        sleep 2
        waited=$((waited + 2))
    done

    echo ""
    log_success "K3s installation verified!"
    echo ""
    kubectl get nodes
    echo ""
    kubectl cluster-info
}

# Main execution
main() {
    echo ""
    echo "============================================="
    echo "       K3s Homeserver Installation"
    echo "============================================="
    echo ""

    check_platform
    check_existing_k8s
    check_prerequisites
    install_k3s
    setup_kubeconfig
    verify_installation

    echo ""
    log_success "============================================="
    log_success "  K3s installation completed!"
    log_success "  "
    log_success "  Next steps:"
    log_success "    1. Run snapshot to save initial state"
    log_success "    2. Deploy your applications"
    log_success "============================================="
    echo ""
}

# Run
main "$@"
