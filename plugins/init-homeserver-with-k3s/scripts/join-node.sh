#!/bin/bash
#
# K3s Agent Node Join Script
# Joins this machine to an existing K3s cluster as a worker node
#
# IMPORTANT: This script requires manual confirmation of master node details
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Parse command line arguments
MASTER_IP=""
NODE_TOKEN=""
NODE_NAME=""
SKIP_CONFIRM="false"

print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --master-ip IP      Master node IP address (required)"
    echo "  --token TOKEN       Node token from master (optional, will prompt if not provided)"
    echo "  --node-name NAME    Custom name for this node (optional)"
    echo "  --yes, -y           Skip confirmation prompts (NOT RECOMMENDED)"
    echo "  --help, -h          Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --master-ip 192.168.1.100"
    echo "  $0 --master-ip 192.168.1.100 --token K10xxx..."
    echo ""
    echo "To get the node token from master, run on master node:"
    echo "  sudo cat /var/lib/rancher/k3s/server/node-token"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --master-ip)
            MASTER_IP="$2"
            shift 2
            ;;
        --token)
            NODE_TOKEN="$2"
            shift 2
            ;;
        --node-name)
            NODE_NAME="$2"
            shift 2
            ;;
        --yes|-y)
            SKIP_CONFIRM="true"
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Check if running on Linux Ubuntu
check_platform() {
    log_step "Checking platform..."

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
    log_step "Checking for existing Kubernetes installations..."

    local found=false
    local existing=""

    # Check for K3s agent
    if [ -f /usr/local/bin/k3s-agent-uninstall.sh ]; then
        log_error "K3s agent is already installed on this machine."
        log_info "To rejoin, first uninstall with: sudo /usr/local/bin/k3s-agent-uninstall.sh"
        exit 1
    fi

    # Check for K3s server
    if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
        log_error "K3s server is already installed on this machine."
        log_error "This machine appears to be a master node, not a worker node."
        log_info "If you want to convert this to a worker node:"
        log_info "  1. Uninstall K3s server: sudo /usr/local/bin/k3s-uninstall.sh"
        log_info "  2. Re-run this script"
        exit 1
    fi

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

    if [ "$found" = true ]; then
        log_warn "Existing Kubernetes environment(s) detected:$existing"
        log_warn "Installing K3s agent may cause conflicts."

        if [ "$SKIP_CONFIRM" != "true" ]; then
            echo ""
            read -p "Do you want to proceed anyway? (y/N): " response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                log_info "Installation cancelled by user."
                exit 0
            fi
        fi
    else
        log_success "No conflicting Kubernetes installations found."
    fi
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."

    local missing=""

    if ! command -v curl &> /dev/null; then
        missing="$missing curl"
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

# Get and confirm master node details
get_master_details() {
    log_step "Master Node Configuration"
    echo ""
    echo "============================================="
    echo "  MASTER NODE CONFIRMATION REQUIRED"
    echo "============================================="
    echo ""

    # Get master IP if not provided
    if [ -z "$MASTER_IP" ]; then
        echo "Please enter the master node IP address."
        echo "This is the IP address of your K3s server (control plane)."
        echo ""
        read -p "Master Node IP: " MASTER_IP
        
        if [ -z "$MASTER_IP" ]; then
            log_error "Master IP is required."
            exit 1
        fi
    fi

    # Validate IP format (basic check)
    if ! [[ "$MASTER_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log_error "Invalid IP address format: $MASTER_IP"
        exit 1
    fi

    # Test connectivity to master
    log_info "Testing connectivity to master node ($MASTER_IP)..."
    
    if ! ping -c 1 -W 3 "$MASTER_IP" &> /dev/null; then
        log_warn "Cannot ping master node at $MASTER_IP"
        log_warn "This might be due to firewall rules. Continuing anyway..."
    else
        log_success "Master node is reachable."
    fi

    # Test K3s API connectivity
    log_info "Testing K3s API connectivity (port 6443)..."
    
    if timeout 5 bash -c "</dev/tcp/$MASTER_IP/6443" 2>/dev/null; then
        log_success "K3s API port (6443) is accessible."
    else
        log_error "Cannot connect to K3s API at ${MASTER_IP}:6443"
        log_error "Please ensure:"
        log_error "  1. K3s server is running on the master node"
        log_error "  2. Firewall allows port 6443"
        log_error "  3. The IP address is correct"
        exit 1
    fi

    # Get node token if not provided
    if [ -z "$NODE_TOKEN" ]; then
        echo ""
        echo "============================================="
        echo "  NODE TOKEN REQUIRED"
        echo "============================================="
        echo ""
        echo "To get the node token, run this command on the MASTER node:"
        echo ""
        echo -e "  ${CYAN}sudo cat /var/lib/rancher/k3s/server/node-token${NC}"
        echo ""
        echo "Then paste the token below."
        echo ""
        read -p "Node Token: " NODE_TOKEN
        
        if [ -z "$NODE_TOKEN" ]; then
            log_error "Node token is required."
            exit 1
        fi
    fi

    # Validate token format (should start with K10)
    if ! [[ "$NODE_TOKEN" =~ ^K10 ]]; then
        log_warn "Token doesn't match expected K3s format (should start with K10)."
        log_warn "Please verify the token is correct."
        
        if [ "$SKIP_CONFIRM" != "true" ]; then
            read -p "Continue anyway? (y/N): " response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    fi

    # Final confirmation
    echo ""
    echo "============================================="
    echo "  PLEASE CONFIRM THE FOLLOWING"
    echo "============================================="
    echo ""
    echo -e "  Master Node IP:   ${GREEN}$MASTER_IP${NC}"
    echo -e "  Node Token:       ${GREEN}${NODE_TOKEN:0:20}...${NC}"
    if [ -n "$NODE_NAME" ]; then
        echo -e "  This Node Name:   ${GREEN}$NODE_NAME${NC}"
    fi
    echo ""
    echo "  This machine will join the K3s cluster as a WORKER node."
    echo ""

    if [ "$SKIP_CONFIRM" != "true" ]; then
        read -p "Is this correct? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled by user."
            exit 0
        fi
    fi

    log_success "Master node details confirmed."
}

# Install K3s agent
install_k3s_agent() {
    log_step "Installing K3s agent..."

    local install_args=""
    
    if [ -n "$NODE_NAME" ]; then
        install_args="--node-name $NODE_NAME"
    fi

    # Download and run K3s agent installation
    curl -sfL https://get.k3s.io | K3S_URL="https://${MASTER_IP}:6443" K3S_TOKEN="$NODE_TOKEN" INSTALL_K3S_EXEC="agent $install_args" sh -

    if [ $? -ne 0 ]; then
        log_error "K3s agent installation failed."
        exit 1
    fi

    log_success "K3s agent installed successfully."
}

# Verify installation
verify_installation() {
    log_step "Verifying K3s agent installation..."

    # Check if k3s-agent service is running
    log_info "Checking k3s-agent service..."
    
    local max_wait=30
    local waited=0

    while ! sudo systemctl is-active --quiet k3s-agent; do
        if [ $waited -ge $max_wait ]; then
            log_error "K3s agent service not running after ${max_wait} seconds."
            log_info "Check logs with: sudo journalctl -u k3s-agent -f"
            exit 1
        fi
        sleep 2
        waited=$((waited + 2))
    done

    log_success "K3s agent service is running."

    echo ""
    echo "============================================="
    echo "  VERIFICATION ON MASTER NODE"
    echo "============================================="
    echo ""
    echo "To verify this node has joined the cluster,"
    echo "run the following command on the MASTER node:"
    echo ""
    echo -e "  ${CYAN}kubectl get nodes${NC}"
    echo ""
    echo "You should see this node in the list (may take a few seconds)."
    echo ""
}

# Main execution
main() {
    echo ""
    echo "============================================="
    echo "       K3s Worker Node Join Script"
    echo "============================================="
    echo ""

    check_platform
    check_existing_k8s
    check_prerequisites
    get_master_details
    install_k3s_agent
    verify_installation

    echo ""
    log_success "============================================="
    log_success "  K3s agent installation completed!"
    log_success "  "
    log_success "  This node is now joining the cluster."
    log_success "  "
    log_success "  Useful commands:"
    log_success "    - Check agent logs: sudo journalctl -u k3s-agent -f"
    log_success "    - Check agent status: sudo systemctl status k3s-agent"
    log_success "    - Uninstall agent: sudo /usr/local/bin/k3s-agent-uninstall.sh"
    log_success "============================================="
    echo ""
}

# Run
main "$@"
