#!/bin/sh
# 브랜치 보호 정책 강제: 보호 브랜치에 직접 커밋 금지
# 머지 커밋은 허용 (git merge가 MERGE_HEAD 생성)
#
# 정책: feat/* → main, release/* 안정화 후 태그
# 참고: .claude/skills/branching/SKILL.md

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
    echo "  브랜치 정책: feat/* → main, release/* 안정화 후 태그"
    echo ""
    echo "  작업 브랜치를 먼저 생성하세요:"
    echo "    git checkout main"
    echo "    git checkout -b feat/your-feature"
    echo ""
    echo "  긴급 시 (비권장): git commit --no-verify"
    echo ""
    exit 1
  fi
done

# release/* 브랜치도 보호 (패턴 매칭)
case "$BRANCH" in
  release/*)
    if [ -f "$(git rev-parse --git-dir)/MERGE_HEAD" ]; then
      exit 0
    fi
    echo ""
    echo "  ERROR: '$BRANCH' 브랜치에 직접 커밋할 수 없습니다."
    echo ""
    echo "  릴리스 브랜치에서는 작업 브랜치를 통해 수정하세요:"
    echo "    git checkout -b fix/release-bugfix"
    echo ""
    echo "  긴급 시 (비권장): git commit --no-verify"
    echo ""
    exit 1
    ;;
esac
