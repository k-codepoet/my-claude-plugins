#!/bin/bash
set -e

echo "======================================================="
echo "  Zsh + Oh My Zsh + Powerlevel10k 설치를 시작합니다..."
echo "======================================================="

# Platform check
if [[ "$(uname -s)" != "Linux" ]]; then
    echo "❌ Error: This script is for Linux only"
    exit 1
fi

# Check if zsh is installed
if ! command -v zsh &> /dev/null; then
    echo "📦 Installing Zsh..."
    sudo apt update -y
    sudo apt install -y zsh fontconfig
else
    echo "✅ Zsh already installed"
fi

# Change default shell to zsh
current_shell=$(basename "$SHELL")
if [[ "$current_shell" != "zsh" ]]; then
    echo "🔄 Changing default shell to Zsh..."
    chsh -s $(which zsh)
else
    echo "✅ Default shell is already Zsh"
fi

# Install fonts for Powerlevel10k
echo "🔤 Installing MesloLGS NF fonts..."
username=$(whoami)
sudo mkdir -p /usr/share/fonts/$username
sudo wget --no-check-certificate -q -P /usr/share/fonts/$username \
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" \
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" \
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" \
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" \
    2>/dev/null || true
sudo fc-cache -fv > /dev/null 2>&1

# Install Oh My Zsh
ZSHRC_FILE="$HOME/.zshrc"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "📦 Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "✅ Oh My Zsh already installed"
fi

# Install Powerlevel10k theme
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    echo "🎨 Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "✅ Powerlevel10k already installed"
fi

# Install zsh-autosuggestions plugin
AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [[ ! -d "$AUTOSUGGESTIONS_DIR" ]]; then
    echo "📦 Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$AUTOSUGGESTIONS_DIR"
else
    echo "✅ zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting plugin
SYNTAX_HIGHLIGHTING_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [[ ! -d "$SYNTAX_HIGHLIGHTING_DIR" ]]; then
    echo "📦 Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$SYNTAX_HIGHLIGHTING_DIR"
else
    echo "✅ zsh-syntax-highlighting already installed"
fi

# Configure .zshrc
echo "⚙️  Configuring .zshrc..."
if [[ -f "$ZSHRC_FILE" ]]; then
    # Update theme to Powerlevel10k
    if grep -q 'ZSH_THEME="robbyrussell"' "$ZSHRC_FILE"; then
        sed -i 's#ZSH_THEME="robbyrussell"#ZSH_THEME="powerlevel10k/powerlevel10k"#' "$ZSHRC_FILE"
        echo "  ✅ Theme changed to Powerlevel10k"
    elif grep -q 'ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC_FILE"; then
        echo "  ✅ Theme already set to Powerlevel10k"
    fi

    # Update plugins
    if grep -q 'plugins=(git)' "$ZSHRC_FILE"; then
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC_FILE"
        echo "  ✅ Plugins updated"
    elif grep -q 'zsh-autosuggestions' "$ZSHRC_FILE"; then
        echo "  ✅ Plugins already configured"
    fi
fi

echo ""
echo "======================================================="
echo "  ✅ Zsh 환경 설정 완료!"
echo "======================================================="
echo ""
echo "설치 항목:"
echo "  - Zsh: Z Shell"
echo "  - Oh My Zsh: Zsh 프레임워크"
echo "  - Powerlevel10k: 테마"
echo "  - zsh-autosuggestions: 자동 완성 플러그인"
echo "  - zsh-syntax-highlighting: 문법 강조 플러그인"
echo "  - MesloLGS NF: Powerlevel10k 폰트"
echo ""
echo "⚠️  참고사항:"
echo "  1. 터미널을 재시작하거나 'exec zsh' 실행"
echo "  2. 터미널 폰트를 'MesloLGS NF'로 설정"
echo "  3. 처음 실행 시 'p10k configure'로 테마 설정"
