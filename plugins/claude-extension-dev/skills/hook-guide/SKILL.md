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
- 커밋 전 규칙 검증

## 이벤트 타입

| 이벤트 | 설명 |
|--------|------|
| `PreToolUse` | 도구 실행 전 (차단 가능) |
| `PostToolUse` | 도구 실행 후 |
| `PostToolUseFailure` | 도구 실행 실패 후 |
| `PermissionRequest` | 권한 요청 다이얼로그 표시 시 |
| `UserPromptSubmit` | 사용자 프롬프트 제출 시 |
| `Notification` | 알림 발생 시 |
| `SessionStart` | 세션 시작 시 |
| `SessionEnd` | 세션 종료 시 |
| `Stop` | Claude가 응답 완료 시 (차단하면 계속 진행) |
| `SubagentStart` | 서브에이전트 시작 시 |
| `SubagentStop` | 서브에이전트 종료 시 (차단하면 계속 진행) |
| `PreCompact` | 컴팩트 전 (auto/manual 구분 가능) |

## 작성 예시

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/format-code.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"import json, sys; data=json.load(sys.stdin); path=data.get('tool_input',{}).get('file_path',''); sys.exit(2 if any(p in path for p in ['.env', 'package-lock.json']) else 0)\""
          }
        ]
      }
    ]
  }
}
```

## Hook 타입

| 타입 | 설명 |
|------|------|
| `command` | 셸 명령어/스크립트 실행 |
| `prompt` | LLM으로 프롬프트 평가 (Stop, SubagentStop 전용) |

> **참고**: `prompt` 타입은 현재 `Stop`과 `SubagentStop` 훅에서만 지원되며, 컨텍스트를 고려한 지능적인 판단이 가능합니다.

## 중요 환경 변수

**`${CLAUDE_PLUGIN_ROOT}`**: 플러그인 디렉토리의 절대 경로. Hook 스크립트 경로에 필수 사용.
