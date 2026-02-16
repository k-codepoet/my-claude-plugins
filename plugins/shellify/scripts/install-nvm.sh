#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

echo "======================================================="
echo "  NVM (Node Version Manager) Setup"
echo "======================================================="
echo ""

require_supported_platform

# Check if NVM is already installed
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]] && [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
    success "NVM already installed ($(nvm --version 2>/dev/null || echo 'unknown'))"
else
    info "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Configure shell RC files
configure_shell_rc() {
    local rc_file="$1"
    local shell_name="$2"

    if [[ -f "$rc_file" ]]; then
        if ! grep -q 'NVM_DIR' "$rc_file"; then
            info "Configuring $shell_name..."
            cat >> "$rc_file" << 'EOF'

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
            success "$shell_name configured"
        else
            success "$shell_name already configured"
        fi
    fi
}

configure_shell_rc "$HOME/.bashrc" "bash"
configure_shell_rc "$HOME/.zshrc" "zsh"

# Verify
echo ""
info "Verifying NVM..."
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh" 2>/dev/null || true
    success "NVM version: $(nvm --version 2>/dev/null || echo 'installed')"
fi

echo ""
echo "======================================================="
echo "  NVM setup complete!"
echo "======================================================="
echo ""
echo "Usage:"
echo "  nvm install --lts     # Install LTS Node.js"
echo "  nvm install 20        # Install specific version"
echo "  nvm use <version>     # Switch version"
echo "  nvm ls                # List installed versions"
echo ""
echo "Restart terminal or run 'source ~/.zshrc' to activate."
