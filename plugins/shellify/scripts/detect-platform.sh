#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

echo "======================================================="
echo "  Shell Environment Status"
echo "======================================================="
echo ""

# --- Platform ---
echo "=== Platform ==="
echo "  OS: $(uname -s) ($(uname -m))"
echo "  Platform type: $PLATFORM"
if [[ "$PLATFORM" == "linux-apt" ]] && grep -q "WSL" /proc/version 2>/dev/null; then
    echo "  Environment: WSL"
fi
echo ""

# --- Shell ---
echo "=== Shell ==="
echo "  Current shell: $SHELL"
if command -v zsh &>/dev/null; then
    echo "  Zsh: $(zsh --version 2>/dev/null | head -1)"
else
    echo "  Zsh: not installed"
fi

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo "  Oh My Zsh: installed"
else
    echo "  Oh My Zsh: not installed"
fi

p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ -d "$p10k_dir" ]]; then
    echo "  Powerlevel10k: installed"
else
    echo "  Powerlevel10k: not installed"
fi

auto_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
syntax_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
[[ -d "$auto_dir" ]] && echo "  zsh-autosuggestions: installed" || echo "  zsh-autosuggestions: not installed"
[[ -d "$syntax_dir" ]] && echo "  zsh-syntax-highlighting: installed" || echo "  zsh-syntax-highlighting: not installed"
echo ""

# --- Fonts ---
echo "=== Fonts ==="
if fc-list 2>/dev/null | grep -qi "MesloLGS"; then
    echo "  MesloLGS NF: installed"
elif [[ -d "$HOME/Library/Fonts" ]] && ls "$HOME/Library/Fonts"/MesloLGS* &>/dev/null 2>&1; then
    echo "  MesloLGS NF: installed (user fonts)"
elif ls "$HOME/.local/share/fonts"/MesloLGS* &>/dev/null 2>&1; then
    echo "  MesloLGS NF: installed (local fonts)"
else
    echo "  MesloLGS NF: not installed"
fi
echo ""

# --- NVM ---
echo "=== NVM ==="
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]] && [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh" 2>/dev/null || true
    echo "  NVM: installed ($(nvm --version 2>/dev/null || echo 'version unknown'))"
    if command -v node &>/dev/null; then
        echo "  Node.js: $(node --version 2>/dev/null)"
    else
        echo "  Node.js: not installed via NVM"
    fi
else
    echo "  NVM: not installed"
fi
echo ""

# --- DevOps CLI Tools ---
echo "=== DevOps CLI Tools ==="
check_tool() {
    local cmd="$1"
    local label="$2"
    if command -v "$cmd" &>/dev/null; then
        local ver
        ver=$("$cmd" version --short 2>/dev/null || "$cmd" --version 2>/dev/null | head -1 || echo "installed")
        echo "  $label: $ver"
    else
        echo "  $label: not installed"
    fi
}
check_tool kubectl "kubectl"
check_tool k9s "k9s"
check_tool helm "helm"
check_tool argocd "argocd"
check_tool gh "gh"
check_tool glab "glab"
check_tool git "git"
command -v git-lfs &>/dev/null && echo "  git-lfs: installed" || echo "  git-lfs: not installed"
echo ""

# --- Package Manager ---
echo "=== Package Manager ==="
case "$PLATFORM" in
    linux-apt|linux-unknown)
        echo "  apt: $(apt --version 2>/dev/null | head -1 || echo 'not found')"
        ;;
    macos)
        if command -v brew &>/dev/null; then
            echo "  Homebrew: $(brew --version 2>/dev/null | head -1)"
        else
            echo "  Homebrew: not installed"
        fi
        ;;
esac
