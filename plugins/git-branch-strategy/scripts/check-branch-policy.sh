#!/usr/bin/env bash
# check-branch-policy.sh
# PreToolUse hook: 보호 브랜치에서 git commit 실행 시 경고
#
# 환경변수:
#   CLAUDE_TOOL_INPUT — Bash 도구에 전달된 명령어 문자열

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# git commit 패턴이 없으면 즉시 통과
if [[ ! "$TOOL_INPUT" =~ git[[:space:]]+commit ]]; then
  exit 0
fi

# 프로젝트 루트의 설정 파일 확인
CONFIG_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/.git-branch-strategy.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
  exit 0
fi

# 현재 브랜치 확인
CURRENT_BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || echo "")"
if [[ -z "$CURRENT_BRANCH" ]]; then
  exit 0
fi

# 보호 브랜치 목록 읽기 (jq 사용)
if ! command -v jq &>/dev/null; then
  # jq 없으면 grep fallback
  if grep -q "\"$CURRENT_BRANCH\"" "$CONFIG_FILE" 2>/dev/null; then
    echo "⚠️  [git-branch-strategy] 보호 브랜치 '$CURRENT_BRANCH'에서 직접 커밋이 감지되었습니다."
    echo "작업 브랜치(feat/*, fix/*, chore/*)에서 작업 후 머지하세요."
    exit 2
  fi
  exit 0
fi

# jq로 protected_branches 배열 확인
PROTECTED=$(jq -r '.protected_branches[]? // empty' "$CONFIG_FILE" 2>/dev/null)
if [[ -z "$PROTECTED" ]]; then
  exit 0
fi

for branch in $PROTECTED; do
  if [[ "$CURRENT_BRANCH" == "$branch" ]]; then
    INTEGRATION=$(jq -r '.integration_branch // "integration"' "$CONFIG_FILE" 2>/dev/null)
    echo "⚠️  [git-branch-strategy] 보호 브랜치 '$CURRENT_BRANCH'에서 직접 커밋이 감지되었습니다."
    echo "작업 브랜치(feat/*, fix/*, chore/*)에서 작업 후 '$INTEGRATION' 브랜치로 머지하세요."
    exit 2
  fi
done

exit 0
