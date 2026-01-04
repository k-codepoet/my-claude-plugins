#!/usr/bin/env bash
set -euo pipefail

# forgeify Stop hook - 세션 종료 시 help/howto 문서 최신화 안내

cat << 'EOF'
{
  "continue": true,
  "systemMessage": "📝 [forgeify] 플러그인 작업(create, compose, improve, update, validate)을 했다면 help/howto 문서 최신화가 필요한지 확인하세요."
}
EOF

exit 0
