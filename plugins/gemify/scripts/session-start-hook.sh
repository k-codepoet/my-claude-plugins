#!/usr/bin/env bash
set -euo pipefail

# gemify SessionStart hook - 세션 시작 시 ~/.gemify/ 자동 동기화

GEMIFY_DIR="${HOME}/.gemify"

# ~/.gemify 존재 확인
if [[ ! -d "$GEMIFY_DIR" ]]; then
  # 없으면 조용히 종료 (setup 필요)
  exit 0
fi

cd "$GEMIFY_DIR"

# remote 확인
if ! git remote get-url origin &>/dev/null; then
  # remote 없으면 안내 메시지
  cat << 'EOF'
{
  "systemMessage": "📍 [gemify] remote가 설정되지 않았습니다. 동기화하려면:\n  cd ~/.gemify && git remote add origin <url>"
}
EOF
  exit 0
fi

# git pull --rebase --autostash 실행
# --autostash: 로컬 uncommitted 변경사항이 있어도 자동으로 stash → pull → pop
if git pull --rebase --autostash &>/dev/null; then
  # 성공 시 short sha + commit date 포함 메시지
  SHORT_SHA=$(git log -1 --format='%h')
  COMMIT_DATE=$(git log -1 --format='%ci')
  cat << EOF
{
  "systemMessage": "✅ [gemify] ~/.gemify/ 동기화 완료 (${SHORT_SHA} @ ${COMMIT_DATE})"
}
EOF
else
  # 실패 시 (conflict 등) 경고 메시지
  cat << 'EOF'
{
  "systemMessage": "⚠️ [gemify] 동기화 중 문제 발생. 수동 확인 필요:\n  cd ~/.gemify && git status\n\nAI에게 해결 요청하거나 직접 수정하세요."
}
EOF
fi

exit 0
