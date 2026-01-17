#!/bin/bash
# add-node.sh - 클러스터에 노드 추가 (ssh-copy-id)
# Usage: ./add-node.sh <ip> <user> [--json]
#
# 비밀번호는 stdin 또는 SSH_PASS 환경변수로 전달
# 예: SSH_PASS=mypass ./add-node.sh 192.168.0.14 admin

set -e

IP="$1"
USER="$2"
JSON_OUTPUT=false
[[ "$3" == "--json" ]] && JSON_OUTPUT=true

if [[ -z "$IP" || -z "$USER" ]]; then
    echo "Usage: $0 <ip> <user> [--json]" >&2
    exit 1
fi

TERRAFY_KEY="$HOME/.ssh/terrafy_ed25519"
TERRAFY_CONFIG="$HOME/.ssh/config.d/terrafy"

# 키 존재 확인
if [[ ! -f "$TERRAFY_KEY" ]]; then
    if $JSON_OUTPUT; then
        echo '{"success": false, "error": "Master not initialized. Run init-master.sh first."}'
    else
        echo "[!] 마스터가 초기화되지 않았습니다. init-master.sh를 먼저 실행하세요." >&2
    fi
    exit 1
fi

# ssh-copy-id 실행
# sshpass가 있으면 사용, 없으면 수동 입력
COPY_SUCCESS=false
ERROR_MSG=""

if command -v sshpass &>/dev/null && [[ -n "$SSH_PASS" ]]; then
    # sshpass로 자동 입력
    if sshpass -p "$SSH_PASS" ssh-copy-id -i "$TERRAFY_KEY" -o StrictHostKeyChecking=accept-new "$USER@$IP" 2>/dev/null; then
        COPY_SUCCESS=true
    else
        ERROR_MSG="Authentication failed"
    fi
else
    # 수동 입력 (interactive)
    if ssh-copy-id -i "$TERRAFY_KEY" -o StrictHostKeyChecking=accept-new "$USER@$IP" 2>/dev/null; then
        COPY_SUCCESS=true
    else
        ERROR_MSG="SSH connection failed"
    fi
fi

if $COPY_SUCCESS; then
    # SSH config에 호스트 추가
    HOST_ALIAS="terrafy-$(echo "$IP" | tr '.' '-')"

    # 이미 있으면 스킵
    if ! grep -q "Host $HOST_ALIAS" "$TERRAFY_CONFIG" 2>/dev/null; then
        cat >> "$TERRAFY_CONFIG" << EOF

Host $HOST_ALIAS
    HostName $IP
    User $USER
    IdentityFile $TERRAFY_KEY
EOF
    fi

    # 연결 테스트
    if ssh -i "$TERRAFY_KEY" -o BatchMode=yes -o ConnectTimeout=5 "$USER@$IP" "echo ok" &>/dev/null; then
        CONNECTION_OK=true
    else
        CONNECTION_OK=false
    fi

    if $JSON_OUTPUT; then
        cat <<EOF
{
  "success": true,
  "ip": "$IP",
  "user": "$USER",
  "host_alias": "$HOST_ALIAS",
  "connection_test": $CONNECTION_OK
}
EOF
    else
        echo "[OK] $IP 추가 완료"
        echo "  Host alias: $HOST_ALIAS"
        echo "  연결 테스트: $( $CONNECTION_OK && echo '성공' || echo '실패' )"
    fi
else
    if $JSON_OUTPUT; then
        cat <<EOF
{
  "success": false,
  "ip": "$IP",
  "user": "$USER",
  "error": "$ERROR_MSG"
}
EOF
    else
        echo "[!] $IP 연결 실패: $ERROR_MSG" >&2
    fi
    exit 1
fi
