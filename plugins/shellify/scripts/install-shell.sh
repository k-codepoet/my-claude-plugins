#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

echo "======================================================="
echo "  Zsh + Oh My Zsh + Powerlevel10k Setup"
echo "======================================================="
echo ""

require_supported_platform

# --- Step 1: Install Zsh ---
install_zsh() {
    if command -v zsh &>/dev/null; then
        success "Zsh already installed"
        return
    fi
    case "$PLATFORM" in
        linux-apt|linux-unknown)
            info "Installing Zsh via apt..."
            sudo apt update -y
            sudo apt install -y zsh fontconfig
            ;;
        macos)
            info "Installing Zsh via Homebrew..."
            brew install zsh
            ;;
    esac
}

# --- Step 2: Change default shell ---
set_default_shell() {
    local current_shell
    current_shell=$(basename "$SHELL")
    if [[ "$current_shell" == "zsh" ]]; then
        success "Default shell is already Zsh"
        return
    fi
    info "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
}

# --- Step 3: Install fonts ---
install_fonts() {
    info "Installing MesloLGS NF fonts..."
    local base_url="https://github.com/romkatv/powerlevel10k-media/raw/master"

    case "$PLATFORM" in
        linux-apt|linux-unknown)
            local font_dir="$HOME/.local/share/fonts"
            mkdir -p "$font_dir"
            for variant in "Regular" "Bold" "Italic" "Bold%20Italic"; do
                local display_name="${variant//%20/ }"
                local fname="MesloLGS NF ${display_name}.ttf"
                if [[ ! -f "$font_dir/$fname" ]]; then
                    curl -fsSL -o "$font_dir/$fname" \
                        "${base_url}/MesloLGS%20NF%20${variant}.ttf" 2>/dev/null || true
                fi
            done
            fc-cache -fv > /dev/null 2>&1
            ;;
        macos)
            if command -v brew &>/dev/null; then
                brew install --cask font-meslo-lg-nerd-font 2>/dev/null && { success "Fonts installed via Homebrew"; return; } || true
            fi
            # Fallback: manual download
            local font_dir="$HOME/Library/Fonts"
            mkdir -p "$font_dir"
            for variant in "Regular" "Bold" "Italic" "Bold%20Italic"; do
                local display_name="${variant//%20/ }"
                local fname="MesloLGS NF ${display_name}.ttf"
                if [[ ! -f "$font_dir/$fname" ]]; then
                    curl -fsSL -o "$font_dir/$fname" \
                        "${base_url}/MesloLGS%20NF%20${variant}.ttf" 2>/dev/null || true
                fi
            done
            ;;
    esac
    success "MesloLGS NF fonts installed"
}

# --- Step 4: Oh My Zsh ---
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        success "Oh My Zsh already installed"
        return
    fi
    info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

# --- Step 5: Powerlevel10k ---
install_powerlevel10k() {
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    ensure_dir_clone "$p10k_dir" "https://github.com/romkatv/powerlevel10k.git" "Powerlevel10k"
}

# --- Step 6: Zsh plugins ---
install_zsh_plugins() {
    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    ensure_dir_clone "$custom/plugins/zsh-autosuggestions" \
        "https://github.com/zsh-users/zsh-autosuggestions.git" "zsh-autosuggestions" ""
    ensure_dir_clone "$custom/plugins/zsh-syntax-highlighting" \
        "https://github.com/zsh-users/zsh-syntax-highlighting.git" "zsh-syntax-highlighting" ""
}

# --- Step 7: Configure .zshrc ---
configure_zshrc() {
    local zshrc="$HOME/.zshrc"
    if [[ ! -f "$zshrc" ]]; then
        warn ".zshrc not found"
        return
    fi
    info "Configuring .zshrc..."

    # Theme
    if grep -q 'ZSH_THEME="robbyrussell"' "$zshrc"; then
        sed -i.bak 's#ZSH_THEME="robbyrussell"#ZSH_THEME="powerlevel10k/powerlevel10k"#' "$zshrc"
        rm -f "$zshrc.bak"
        success "Theme changed to Powerlevel10k"
    elif grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$zshrc"; then
        success "Theme already set to Powerlevel10k"
    fi

    # Plugins
    if grep -q 'plugins=(git)' "$zshrc"; then
        sed -i.bak 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$zshrc"
        rm -f "$zshrc.bak"
        success "Plugins updated"
    elif grep -q 'zsh-autosuggestions' "$zshrc"; then
        success "Plugins already configured"
    fi
}

# --- Execute ---
install_zsh
set_default_shell
install_fonts
install_oh_my_zsh
install_powerlevel10k
install_zsh_plugins
configure_zshrc

echo ""
echo "======================================================="
echo "  Shell environment setup complete!"
echo "======================================================="
echo ""
echo "Installed:"
echo "  - Zsh"
echo "  - Oh My Zsh"
echo "  - Powerlevel10k theme"
echo "  - zsh-autosuggestions plugin"
echo "  - zsh-syntax-highlighting plugin"
echo "  - MesloLGS NF fonts"
echo ""
echo "Next steps:"
echo "  1. Restart terminal or run 'exec zsh'"
echo "  2. Set terminal font to 'MesloLGS NF'"
echo "  3. Run 'p10k configure' for theme setup"
