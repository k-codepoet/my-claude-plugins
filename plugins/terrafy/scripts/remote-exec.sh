#!/bin/bash
# remote-exec.sh - 원격 머신에서 명령 또는 스크립트 실행
# Usage: ./remote-exec.sh <ip> <command|script_path> [--json]
#
# 예:
#   ./remote-exec.sh 192.168.0.14 "docker ps"
#   ./remote-exec.sh 192.168.0.14 ./scripts/check-docker.sh

set -e

IP="$1"
CMD="$2"
JSON_OUTPUT=false
[[ "$3" == "--json" ]] && JSON_OUTPUT=true

if [[ -z "$IP" || -z "$CMD" ]]; then
    echo "Usage: $0 <ip> <command|script_path> [--json]" >&2
    exit 1
fi

TERRAFY_KEY="$HOME/.ssh/terrafy_ed25519"

# 키 존재 확인
if [[ ! -f "$TERRAFY_KEY" ]]; then
    if $JSON_OUTPUT; then
        echo '{"success": false, "error": "Master not initialized"}'
    else
        echo "[!] 마스터가 초기화되지 않았습니다." >&2
    fi
    exit 1
fi

# SSH config에서 user 찾기
TERRAFY_CONFIG="$HOME/.ssh/config.d/terrafy"
HOST_ALIAS="terrafy-$(echo "$IP" | tr '.' '-')"

if grep -q "Host $HOST_ALIAS" "$TERRAFY_CONFIG" 2>/dev/null; then
    # config에서 User 추출
    USER=$(awk "/Host $HOST_ALIAS/,/Host /{if(/User/) print \$2}" "$TERRAFY_CONFIG" | head -1)
fi

# 기본값
USER="${USER:-root}"

# 스크립트 파일인지 확인
if [[ -f "$CMD" ]]; then
    # 스크립트 파일이면 원격으로 전송 후 실행
    SCRIPT_CONTENT=$(cat "$CMD")
    OUTPUT=$(ssh -i "$TERRAFY_KEY" -o BatchMode=yes -o ConnectTimeout=10 "$USER@$IP" "bash -s" <<< "$SCRIPT_CONTENT" 2>&1)
    EXIT_CODE=$?
else
    # 명령어면 바로 실행
    OUTPUT=$(ssh -i "$TERRAFY_KEY" -o BatchMode=yes -o ConnectTimeout=10 "$USER@$IP" "$CMD" 2>&1)
    EXIT_CODE=$?
fi

if $JSON_OUTPUT; then
    # JSON escape
    ESCAPED_OUTPUT=$(echo "$OUTPUT" | jq -Rs .)
    cat <<EOF
{
  "success": $( [[ $EXIT_CODE -eq 0 ]] && echo true || echo false ),
  "ip": "$IP",
  "exit_code": $EXIT_CODE,
  "output": $ESCAPED_OUTPUT
}
EOF
else
    if [[ $EXIT_CODE -eq 0 ]]; then
        echo "=== $IP ==="
        echo "$OUTPUT"
    else
        echo "[!] $IP 실행 실패 (exit: $EXIT_CODE)" >&2
        echo "$OUTPUT" >&2
        exit $EXIT_CODE
    fi
fi
