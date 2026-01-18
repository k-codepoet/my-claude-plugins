#!/bin/bash
set -e

echo "======================================================="
echo "  Ubuntu 기본 패키지 설치를 시작합니다..."
echo "======================================================="

# Platform check
if [[ "$(uname -s)" != "Linux" ]]; then
    echo "❌ Error: This script is for Linux only"
    exit 1
fi

if ! grep -qi "ubuntu\|debian" /etc/os-release 2>/dev/null; then
    echo "⚠️  Warning: This script is optimized for Ubuntu/Debian"
    echo "   Proceeding anyway..."
fi

# Update package list
echo "📦 Updating package list..."
sudo apt update -y

# Upgrade existing packages
echo "📦 Upgrading existing packages..."
sudo apt upgrade -y

# Install essential packages
echo "📦 Installing essential packages..."
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

# Install Git LFS
echo "📦 Installing Git LFS..."
if ! command -v git-lfs &> /dev/null; then
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
    sudo apt-get install -y git-lfs
    git lfs install
else
    echo "✅ Git LFS already installed"
fi

echo ""
echo "======================================================="
echo "  ✅ 기본 패키지 설치 완료!"
echo "======================================================="
echo ""
echo "설치된 패키지:"
echo "  - curl, wget: HTTP 클라이언트"
echo "  - git, git-lfs: 버전 관리"
echo "  - net-tools, procps: 시스템 도구"
echo "  - openssl, ca-certificates: 보안"
echo "  - fontconfig: 폰트 관리"
echo "  - unzip: 압축 해제"
echo "  - screen: 터미널 멀티플렉서"
echo "  - zsh: Z Shell"
