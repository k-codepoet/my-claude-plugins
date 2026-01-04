#!/bin/bash
# gemify Stop hook - 세션 종료 시 히스토리 저장 안내

echo "📝 [gemify] 세션 종료 전 체크: gemify:draft 작업을 했다면 히스토리 저장이 필요한지 확인하세요."
echo ""
echo "히스토리 저장 기준:"
echo "- turns >= 3 (의미있는 대화량)"
echo "- Current State에 실질적 변경이 있음"
echo ""
echo "기준 충족 시 drafts/.history/{slug}/에 스냅샷을 저장하세요."

exit 0
