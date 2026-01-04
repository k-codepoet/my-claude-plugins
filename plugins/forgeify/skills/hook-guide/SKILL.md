---
name: hook-guide
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
claude --debug  # 훅 로딩/실행 로그 확인
/hooks          # 현재 로드된 훅 목록 확인
```

> 상세 예시는 `references/examples.md`, 트러블슈팅은 `references/troubleshooting.md` 참조
