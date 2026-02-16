#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

echo "======================================================="
echo "  Essential Development Packages"
echo "======================================================="
echo ""

require_supported_platform

case "$PLATFORM" in
    linux-apt|linux-unknown)
        info "Updating package list..."
        sudo apt update -y

        info "Installing essential packages..."
        sudo apt install -y \
            curl \
            wget \
            git \
            net-tools \
            procps \
            openssl \
            ca-certificates \
            fontconfig \
            unzip \
            screen \
            zsh

        # Git LFS
        if ! command -v git-lfs &>/dev/null; then
            info "Installing Git LFS..."
            curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
            sudo apt-get install -y git-lfs
            git lfs install
        else
            success "Git LFS already installed"
        fi
        ;;

    macos)
        info "Installing essential packages via Homebrew..."
        local packages=(curl wget git git-lfs coreutils fontconfig unzip screen zsh)
        for pkg in "${packages[@]}"; do
            if brew list "$pkg" &>/dev/null 2>&1; then
                success "$pkg already installed"
            else
                info "Installing $pkg..."
                brew install "$pkg" 2>/dev/null || true
            fi
        done
        git lfs install 2>/dev/null || true
        ;;
esac

echo ""
echo "======================================================="
echo "  Essential packages installed!"
echo "======================================================="
echo ""
echo "Installed: curl, wget, git, git-lfs, fontconfig, unzip, screen, zsh"
