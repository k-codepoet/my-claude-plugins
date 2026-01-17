#!/bin/bash
# init-master.sh - 마스터 머신 초기화 (SSH 키 생성)
# Usage: ./init-master.sh [--json]

set -e

JSON_OUTPUT=false
[[ "$1" == "--json" ]] && JSON_OUTPUT=true

TERRAFY_KEY="$HOME/.ssh/terrafy_ed25519"
TERRAFY_CONFIG="$HOME/.ssh/config.d/terrafy"

# SSH 디렉토리 확인
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# 키가 이미 있는지 확인
KEY_EXISTS=false
KEY_CREATED=false

if [[ -f "$TERRAFY_KEY" ]]; then
    KEY_EXISTS=true
else
    # 새 키 생성
    ssh-keygen -t ed25519 -f "$TERRAFY_KEY" -N "" -C "terrafy-master" >/dev/null 2>&1
    KEY_CREATED=true
fi

# 공개키 읽기
PUBLIC_KEY=$(cat "${TERRAFY_KEY}.pub")

# config.d 디렉토리 설정
mkdir -p "$HOME/.ssh/config.d"

# 메인 config에 Include 추가 (없으면)
if ! grep -q "Include config.d/\*" "$HOME/.ssh/config" 2>/dev/null; then
    echo -e "Include config.d/*\n$(cat "$HOME/.ssh/config" 2>/dev/null || true)" > "$HOME/.ssh/config"
fi

# terrafy 설정 파일 초기화 (없으면)
if [[ ! -f "$TERRAFY_CONFIG" ]]; then
    cat > "$TERRAFY_CONFIG" << 'EOF'
# Terrafy managed hosts
# 자동 생성됨 - 수동 편집 가능

EOF
fi

chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
chmod 600 "$TERRAFY_CONFIG" 2>/dev/null || true

if $JSON_OUTPUT; then
    cat <<EOF
{
  "key_path": "$TERRAFY_KEY",
  "key_existed": $KEY_EXISTS,
  "key_created": $KEY_CREATED,
  "public_key": "$PUBLIC_KEY",
  "config_path": "$TERRAFY_CONFIG"
}
EOF
else
    echo "=== Master Initialized ==="
    if $KEY_CREATED; then
        echo "SSH 키 생성됨: $TERRAFY_KEY"
    else
        echo "SSH 키 존재함: $TERRAFY_KEY"
    fi
    echo ""
    echo "공개키:"
    echo "$PUBLIC_KEY"
    echo ""
    echo "설정 파일: $TERRAFY_CONFIG"
fi
