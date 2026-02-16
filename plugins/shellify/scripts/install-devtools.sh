#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

echo "======================================================="
echo "  DevOps CLI Tools Setup"
echo "======================================================="
echo ""

require_supported_platform

# --- kubectl ---
install_kubectl() {
    if command -v kubectl &>/dev/null; then
        success "kubectl already installed ($(kubectl version --client --short 2>/dev/null || kubectl version --client 2>/dev/null | head -1))"
        return
    fi
    info "Installing kubectl..."
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 2>/dev/null
            echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
            sudo apt update -y
            sudo apt install -y kubectl
            ;;
        macos)
            brew install kubectl
            ;;
    esac
    success "kubectl installed"
}

# --- k9s ---
install_k9s() {
    if command -v k9s &>/dev/null; then
        success "k9s already installed ($(k9s version --short 2>/dev/null || echo 'installed'))"
        return
    fi
    info "Installing k9s..."
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            local tmp_dir
            tmp_dir=$(mktemp -d)
            curl -fsSL "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${arch}.tar.gz" -o "$tmp_dir/k9s.tar.gz"
            tar -xzf "$tmp_dir/k9s.tar.gz" -C "$tmp_dir"
            sudo mv "$tmp_dir/k9s" /usr/local/bin/k9s
            sudo chmod +x /usr/local/bin/k9s
            rm -rf "$tmp_dir"
            ;;
        macos)
            brew install k9s
            ;;
    esac
    success "k9s installed"
}

# --- helm ---
install_helm() {
    if command -v helm &>/dev/null; then
        success "helm already installed ($(helm version --short 2>/dev/null))"
        return
    fi
    info "Installing helm..."
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
            ;;
        macos)
            brew install helm
            ;;
    esac
    success "helm installed"
}

# --- argocd CLI ---
install_argocd() {
    if command -v argocd &>/dev/null; then
        success "argocd already installed ($(argocd version --client --short 2>/dev/null || echo 'installed'))"
        return
    fi
    info "Installing argocd CLI..."
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            curl -fsSL -o /tmp/argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${arch}"
            sudo install -m 555 /tmp/argocd /usr/local/bin/argocd
            rm -f /tmp/argocd
            ;;
        macos)
            brew install argocd
            ;;
    esac
    success "argocd installed"
}

# --- GitHub CLI (gh) ---
install_gh() {
    if command -v gh &>/dev/null; then
        success "gh already installed ($(gh --version 2>/dev/null | head -1))"
        return
    fi
    info "Installing GitHub CLI (gh)..."
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            sudo mkdir -p -m 755 /etc/apt/keyrings
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
            sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update -y
            sudo apt install -y gh
            ;;
        macos)
            brew install gh
            ;;
    esac
    success "gh installed"
}

# --- GitLab CLI (glab) ---
install_glab() {
    if command -v glab &>/dev/null; then
        success "glab already installed ($(glab --version 2>/dev/null | head -1))"
        return
    fi
    info "Installing GitLab CLI (glab)..."
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            local tmp_dir
            tmp_dir=$(mktemp -d)
            local latest_url
            latest_url=$(curl -fsSL -o /dev/null -w '%{redirect_url}' "https://github.com/profclems/glab/releases/latest" 2>/dev/null || true)
            # Fallback: direct apt repo
            curl -fsSL "https://raw.githubusercontent.com/upciti/wakemeops/main/assets/install_repository" | sudo bash 2>/dev/null || true
            if sudo apt install -y glab 2>/dev/null; then
                rm -rf "$tmp_dir"
            else
                # Binary fallback
                local version
                version=$(curl -fsSL "https://gitlab.com/gitlab-org/cli/-/raw/main/VERSION" 2>/dev/null || echo "1.46.1")
                curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${version}/downloads/glab_${version}_Linux_x86_64.tar.gz" -o "$tmp_dir/glab.tar.gz" 2>/dev/null || true
                if [[ -f "$tmp_dir/glab.tar.gz" ]]; then
                    tar -xzf "$tmp_dir/glab.tar.gz" -C "$tmp_dir"
                    sudo mv "$tmp_dir/bin/glab" /usr/local/bin/glab 2>/dev/null || sudo mv "$tmp_dir/glab" /usr/local/bin/glab 2>/dev/null || true
                    sudo chmod +x /usr/local/bin/glab
                fi
                rm -rf "$tmp_dir"
            fi
            ;;
        macos)
            brew install glab
            ;;
    esac
    if command -v glab &>/dev/null; then
        success "glab installed"
    else
        warn "glab installation may require manual setup"
    fi
}

# --- git + git-lfs (ensure) ---
install_git() {
    ensure_command git git
    if ! command -v git-lfs &>/dev/null; then
        info "Installing git-lfs..."
        case "$PLATFORM" in
            linux-apt|linux-unknown)
                curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
                sudo apt-get install -y git-lfs
                ;;
            macos)
                brew install git-lfs
                ;;
        esac
    else
        success "git-lfs already installed"
    fi
    git lfs install 2>/dev/null || true
}

# --- Execute ---
install_git
install_kubectl
install_k9s
install_helm
install_argocd
install_gh
install_glab

echo ""
echo "======================================================="
echo "  DevOps CLI tools setup complete!"
echo "======================================================="
echo ""
echo "Installed:"
echo "  - git + git-lfs    : Version control"
echo "  - kubectl          : Kubernetes CLI"
echo "  - k9s              : Kubernetes TUI"
echo "  - helm             : Kubernetes package manager"
echo "  - argocd           : ArgoCD CLI"
echo "  - gh               : GitHub CLI"
echo "  - glab             : GitLab CLI"
