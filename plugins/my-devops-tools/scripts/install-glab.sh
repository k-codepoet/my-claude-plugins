#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

echo "======================================================="
echo "  GitLab CLI (glab) Setup"
echo "======================================================="
echo ""

require_supported_platform

install_glab() {
    if command -v glab &>/dev/null; then
        success "glab already installed ($(glab --version 2>/dev/null | head -1))"
        return
    fi
    info "Installing GitLab CLI (glab)..."
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            # Official GitLab apt repo
            curl -fsSL "https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository" | sudo bash 2>/dev/null || true
            if sudo apt-get install -y glab 2>/dev/null; then
                success "glab installed via apt"
                return
            fi
            # Binary fallback
            info "apt install failed, trying binary download..."
            local version
            version=$(curl -fsSL "https://gitlab.com/gitlab-org/cli/-/raw/main/VERSION" 2>/dev/null || echo "1.46.1")
            local tmp_dir
            tmp_dir=$(mktemp -d)
            curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${version}/downloads/glab_${version}_Linux_${ARCH}.tar.gz" \
                -o "$tmp_dir/glab.tar.gz" 2>/dev/null
            if [[ -f "$tmp_dir/glab.tar.gz" ]]; then
                tar -xzf "$tmp_dir/glab.tar.gz" -C "$tmp_dir"
                sudo install -m 755 "$tmp_dir/bin/glab" /usr/local/bin/glab 2>/dev/null \
                    || sudo install -m 755 "$tmp_dir/glab" /usr/local/bin/glab 2>/dev/null
            fi
            rm -rf "$tmp_dir"
            ;;
        macos)
            brew install glab
            ;;
    esac
    if command -v glab &>/dev/null; then
        success "glab installed ($(glab --version 2>/dev/null | head -1))"
    else
        error "glab installation failed. Manual install: https://gitlab.com/gitlab-org/cli#installation"
        exit 1
    fi
}

install_glab

echo ""
echo "======================================================="
echo "  GitLab CLI setup complete!"
echo "======================================================="
echo ""
echo "Next steps:"
echo "  glab auth login                          # Authenticate"
echo "  glab auth login --hostname gitlab.co.kr  # Self-hosted"
echo "  glab auth status                         # Verify"
