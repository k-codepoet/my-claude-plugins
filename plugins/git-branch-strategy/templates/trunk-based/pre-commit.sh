#!/bin/sh
# 브랜치 보호 정책 강제: 보호 브랜치에 직접 커밋 금지
# 머지 커밋은 허용 (git merge가 MERGE_HEAD 생성)
#
# 정책: feat/* → main (trunk)
# 참고: .claude/skills/branching/SKILL.md
#
# 참고: 소규모 팀에서 main 직접 커밋을 허용하려면
# PROTECTED를 비워두거나 이 hook을 비활성화

BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
PROTECTED="{{PROTECTED_BRANCHES}}"

for b in $PROTECTED; do
  if [ "$BRANCH" = "$b" ]; then
    # 머지 커밋 허용
    if [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ]; then
      exit 0
    fi
    echo ""
    echo "  ERROR: '$BRANCH' 브랜치에 직접 커밋할 수 없습니다."
    echo ""
    echo "  브랜치 정책: feat/* → main (trunk)"
    echo ""
    echo "  짧은 수명의 작업 브랜치를 생성하세요 (1~2일 이내):"
    echo "    git checkout -b feat/your-feature"
    echo ""
    echo "  소규모 팀에서 main 직접 커밋을 허용하려면:"
    echo "    .git/hooks/pre-commit 에서 PROTECTED 값을 비워두세요"
    echo ""
    echo "  긴급 시 (비권장): git commit --no-verify"
    echo ""
    exit 1
  fi
done
