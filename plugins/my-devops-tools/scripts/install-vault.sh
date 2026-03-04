#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

echo "======================================================="
echo "  HashiCorp Vault CLI Setup"
echo "======================================================="
echo ""

require_supported_platform

install_vault() {
    if command -v vault &>/dev/null; then
        success "vault already installed ($(vault version 2>/dev/null | head -1))"
        return
    fi
    info "Installing HashiCorp Vault CLI..."
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            # HashiCorp GPG key + apt repo
            sudo apt-get update -y && sudo apt-get install -y gpg
            curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>/dev/null
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
            sudo apt-get update -y
            sudo apt-get install -y vault
            ;;
        macos)
            brew tap hashicorp/tap
            brew install hashicorp/tap/vault
            ;;
    esac
    success "vault installed ($(vault version 2>/dev/null | head -1))"
}

install_vault

echo ""
echo "======================================================="
echo "  Vault CLI setup complete!"
echo "======================================================="
echo ""
echo "Installed:"
echo "  - vault : HashiCorp Vault CLI"
echo ""
echo "Quick verify:"
echo "  vault version"
echo "  vault status -address=<VAULT_ADDR>"
