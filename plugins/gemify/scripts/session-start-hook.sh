#!/usr/bin/env bash
set -euo pipefail

# gemify SessionStart hook - 세션 시작 시 현재 도메인 자동 동기화

GEMIFY_ROOT="${HOME}/.gemify"
CONFIG_FILE="${GEMIFY_ROOT}/config.json"

# ~/.gemify 존재 확인
if [[ ! -d "$GEMIFY_ROOT" ]]; then
  # 없으면 조용히 종료 (setup 필요)
  exit 0
fi

# config.json 확인
if [[ ! -f "$CONFIG_FILE" ]]; then
  # config 없으면 legacy 모드로 동작 (단일 도메인)
  DOMAIN_PATH="$GEMIFY_ROOT"
  DOMAIN_NAME="(legacy)"
else
  # jq로 현재 도메인 경로 가져오기
  if command -v jq &> /dev/null; then
    CURRENT_DOMAIN=$(jq -r '.current' "$CONFIG_FILE")
    RAW_PATH=$(jq -r --arg d "$CURRENT_DOMAIN" '.domains[$d].path' "$CONFIG_FILE")
    DOMAIN_PATH="${RAW_PATH/#\~/$HOME}"
    DOMAIN_NAME="$CURRENT_DOMAIN"
  else
    # jq 없으면 조용히 종료
    exit 0
  fi
fi

# 도메인 경로 존재 확인
if [[ ! -d "$DOMAIN_PATH" ]]; then
  exit 0
fi

cd "$DOMAIN_PATH"

# remote 확인
if ! git remote get-url origin &>/dev/null; then
  # remote 없으면 안내 메시지
  cat << EOF
{
  "systemMessage": "📍 [gemify:${DOMAIN_NAME}] remote가 설정되지 않았습니다. 동기화하려면:\n  cd ${DOMAIN_PATH} && git remote add origin <url>"
}
EOF
  exit 0
fi

# git pull --rebase --autostash 실행
if git pull --rebase --autostash &>/dev/null; then
  # 성공 시 short sha + commit date 포함 메시지
  SHORT_SHA=$(git log -1 --format='%h')
  COMMIT_DATE=$(git log -1 --format='%ci')
  cat << EOF
{
  "systemMessage": "✅ [gemify:${DOMAIN_NAME}] 동기화 완료 (${SHORT_SHA} @ ${COMMIT_DATE})"
}
EOF
else
  # 실패 시 (conflict 등) 경고 메시지
  cat << EOF
{
  "systemMessage": "⚠️ [gemify:${DOMAIN_NAME}] 동기화 중 문제 발생. 수동 확인 필요:\n  cd ${DOMAIN_PATH} && git status\n\nAI에게 해결 요청하거나 직접 수정하세요."
}
EOF
fi

exit 0
