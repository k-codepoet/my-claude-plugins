#!/bin/bash
# common.sh - Shared utilities for shellify scripts
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

# --- Package Manager ---
pkg_install() {
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            sudo apt install -y "$@"
            ;;
        macos)
            if ! command -v brew &>/dev/null; then
                error "Homebrew not found. Install from https://brew.sh"
                exit 1
            fi
            brew install "$@"
            ;;
    esac
}

pkg_update() {
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            sudo apt update -y
            ;;
        macos)
            brew update
            ;;
    esac
}

# --- Idempotent Helpers ---
ensure_command() {
    local cmd="$1"
    local install_name="${2:-$1}"
    if command -v "$cmd" &>/dev/null; then
        success "$cmd already installed"
        return 0
    fi
    info "Installing $install_name..."
    pkg_install "$install_name"
}

ensure_dir_clone() {
    local target_dir="$1"
    local repo_url="$2"
    local label="$3"
    local extra_args="${4:---depth=1}"
    if [[ -d "$target_dir" ]]; then
        success "$label already installed"
        return 0
    fi
    info "Installing $label..."
    git clone $extra_args "$repo_url" "$target_dir"
}
