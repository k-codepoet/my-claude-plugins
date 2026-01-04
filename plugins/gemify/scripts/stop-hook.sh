#!/usr/bin/env bash
set -euo pipefail

# gemify Stop hook - 세션 종료 시 히스토리 저장 안내
# stdin으로 JSON 입력이 들어오지만, 여기서는 사용하지 않음

# continue: true = 세션 종료 허용
# systemMessage = 사용자에게 표시되는 메시지
cat << 'EOF'
{
  "continue": true,
  "systemMessage": "📝 [gemify] gemify:draft 작업을 했다면 히스토리 저장 필요 여부를 확인하세요. (turns >= 3, 내용 변경 시)"
}
EOF

exit 0
