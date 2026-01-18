#!/bin/bash
set -e

echo "======================================================="
echo "  NVM (Node Version Manager) 설치를 시작합니다..."
echo "======================================================="

# Platform check
if [[ "$(uname -s)" != "Linux" ]]; then
    echo "❌ Error: This script is for Linux only"
    exit 1
fi

# Check if NVM is already installed
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]] && [[ -s "$NVM_DIR/nvm.sh" ]]; then
    echo "✅ NVM already installed at $NVM_DIR"
    source "$NVM_DIR/nvm.sh"
    echo "   Current version: $(nvm --version)"
else
    # Install NVM
    echo "📦 Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    # Load NVM
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
            echo "⚙️  Configuring $shell_name..."
            cat >> "$rc_file" << 'EOF'

# NVM Configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
            echo "  ✅ $shell_name configured"
        else
            echo "  ✅ $shell_name already configured"
        fi
    fi
}

# Configure both bashrc and zshrc
configure_shell_rc "$HOME/.bashrc" "bash"
configure_shell_rc "$HOME/.zshrc" "zsh"

# Verify installation
echo ""
echo "🔍 Verifying NVM installation..."
if command -v nvm &> /dev/null || [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh" 2>/dev/null || true
    echo "  ✅ NVM version: $(nvm --version 2>/dev/null || echo 'installed')"
else
    echo "  ⚠️  NVM installed but requires shell restart to use"
fi

echo ""
echo "======================================================="
echo "  ✅ NVM 설치 완료!"
echo "======================================================="
echo ""
echo "사용법:"
echo "  nvm install node      # 최신 Node.js 설치"
echo "  nvm install --lts     # LTS 버전 설치"
echo "  nvm install 20        # 특정 버전 설치"
echo "  nvm use <version>     # 버전 전환"
echo "  nvm ls                # 설치된 버전 목록"
echo "  nvm ls-remote         # 설치 가능한 버전 목록"
echo ""
echo "⚠️  참고사항:"
echo "  터미널을 재시작하거나 'source ~/.zshrc' 또는 'source ~/.bashrc' 실행"
