---
description: Claude Code 훅(Hooks) 작성법 가이드. Hook 만들기, 이벤트 타입, hooks.json 작성, PreToolUse/PostToolUse에 대해 질문할 때 사용합니다.
---

# Hooks (훅) 가이드

## 개념

**특정 이벤트 발생 시 자동으로 실행되는 스크립트**입니다. LLM에 의존하지 않고 결정론적으로 동작합니다.

## 사용 사례

- 파일 저장 후 자동 포매팅 (`prettier`, `gofmt` 등)
- 민감한 파일 수정 차단
- 실행된 명령어 로깅

## hooks.json 포맷

플러그인의 `hooks/hooks.json` 파일은 **중첩 객체 구조**를 사용합니다:

```json
{
  "description": "플러그인 훅 설명",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/pre-bash.sh"
          }
        ]
      }
    ]
  }
}
```

### 필수/선택 필드

| 필드 | 필수 | 설명 |
|------|------|------|
| `hooks` | O | 이벤트 타입을 키로 하는 객체 |
| `hooks[Event][].hooks` | O | 실행할 훅 정의 배열 |
| `hooks[Event][].hooks[].type` | O | `"command"` 또는 `"prompt"` |
| `hooks[Event][].hooks[].command` | O | 실행할 명령어 (문자열) |
| `description` | X | 플러그인 훅 설명 |
| `hooks[Event][].matcher` | X | 특정 도구에만 적용 (정규식 가능) |
| `hooks[Event][].hooks[].timeout` | X | 타임아웃 (초 단위) |

## 이벤트 타입

| 이벤트 | 설명 |
|--------|------|
| `PreToolUse` | 도구 실행 전 (차단 가능) |
| `PostToolUse` | 도구 실행 후 |
| `Stop` | Claude가 응답 완료 시 |
| `SessionStart` | 세션 시작 시 |
| `UserPromptSubmit` | 사용자 프롬프트 제출 시 |

> 전체 이벤트 목록: `PostToolUseFailure`, `PermissionRequest`, `Notification`, `SessionEnd`, `SubagentStart`, `SubagentStop`, `PreCompact`

## 매처(matcher) 규칙

**대소문자 정확히 일치해야 합니다:** `Bash`, `Write`, `Edit`, `Read`, `Glob`, `Grep`, `Task`, `MultiEdit`

여러 도구 매칭: `"matcher": "Write|Edit|MultiEdit"`

## 중요 환경 변수

**`${CLAUDE_PLUGIN_ROOT}`**: 플러그인 디렉토리의 절대 경로. Hook 스크립트 경로에 필수 사용.

## 디버깅

```bash
claude --debug hooks  # 훅 로딩/실행 로그 확인
/hooks                # 현재 로드된 훅 목록 확인
grep -i hook ~/.claude/debug/latest  # 디버그 로그에서 훅 관련 검색
```

## Stop 훅 JSON 출력

Stop 훅에서 JSON을 stdout으로 출력하면 Claude 동작을 제어할 수 있습니다:

```bash
#!/usr/bin/env bash
set -euo pipefail

# 세션 종료 허용 + 메시지 표시
cat << 'EOF'
{
  "continue": true,
  "systemMessage": "📝 작업 완료 전 체크리스트를 확인하세요."
}
EOF

exit 0
```

### JSON 필드

| 필드 | 설명 |
|------|------|
| `continue` | `true`: 종료 허용, `false`: 종료 차단 |
| `decision` | `"block"`: 종료 막고 계속 진행, `"approve"` 또는 생략: 종료 허용 |
| `reason` | `decision: "block"` 시 Claude에게 전달할 이유 |
| `systemMessage` | 사용자에게 표시할 메시지 |
| `stopReason` | `continue: false` 시 표시할 종료 이유 |

### 종료 코드

| 코드 | 의미 |
|------|------|
| `exit 0` | 성공 (stdout의 JSON 처리) |
| `exit 2` | 차단 오류 (stderr가 Claude에 피드백) |
| 그 외 | 비차단 오류 (로그만 남고 계속 진행) |

## Known Issues

### `type: "prompt"` 훅이 플러그인에서 작동하지 않음

**증상**: 플러그인 `hooks/hooks.json`에 `"type": "prompt"` 훅을 정의해도 `Registered 0 hooks`로 표시되며 무시됨.

**원인**: Claude Code가 플러그인 훅에서 `type: "prompt"`를 **silently ignore**함. `type: "command"`만 지원됨.

**확인된 버전**: v2.0.75, v2.0.76

**GitHub Issue**: [#13155](https://github.com/anthropics/claude-code/issues/13155)

**Workaround**: `type: "command"`로 변경하고 셸 스크립트에서 JSON 출력

```json
// hooks/hooks.json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/stop-hook.sh"
      }]
    }]
  }
}
```

```bash
# scripts/stop-hook.sh
#!/usr/bin/env bash
set -euo pipefail

cat << 'EOF'
{
  "continue": true,
  "systemMessage": "📝 안내 메시지"
}
EOF

exit 0
```

> 상세 예시는 `references/examples.md`, 트러블슈팅은 `references/troubleshooting.md` 참조
