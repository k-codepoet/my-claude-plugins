#!/bin/bash
# common.sh - Shared utilities for my-devops-tools scripts
# Usage: source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }

# --- Platform Detection ---
detect_platform() {
    local os
    os=$(uname -s)
    case "$os" in
        Linux)
            if grep -qi "ubuntu\|debian" /etc/os-release 2>/dev/null; then
                echo "linux-apt"
            else
                echo "linux-unknown"
            fi
            ;;
        Darwin)
            echo "macos"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

PLATFORM=$(detect_platform)

require_supported_platform() {
    case "$PLATFORM" in
        linux-apt|macos)
            info "Platform: $PLATFORM"
            ;;
        linux-unknown)
            warn "Unsupported Linux distribution (not Ubuntu/Debian)"
            warn "Some operations may not work. Proceeding anyway..."
            ;;
        *)
            error "Unsupported platform: $(uname -s)"
            exit 1
            ;;
    esac
}

# --- Architecture Detection ---
detect_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        arm64)   echo "arm64" ;;
        *)       echo "$arch" ;;
    esac
}

ARCH=$(detect_arch)
