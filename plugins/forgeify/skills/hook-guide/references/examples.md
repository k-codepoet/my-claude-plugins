# Hooks 예시 모음

## 기본 예시: 세션 시작 시 스크립트 실행

```json
{
  "description": "세션 시작 훅",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

## 파일 수정 시 보안 체크

```json
{
  "description": "보안 검사 훅",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/security_check.py"
          }
        ]
      }
    ]
  }
}
```

## 여러 이벤트 처리

```json
{
  "description": "다중 이벤트 훅",
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/pretooluse.py",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/posttooluse.py",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/stop.py",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

## 특정 도구에만 적용 (matcher 사용)

```json
{
  "description": "Bash 명령어 로깅",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/log-bash.sh"
          }
        ]
      }
    ]
  }
}
```

## prompt 타입 훅 (Stop/SubagentStop 전용)

```json
{
  "description": "작업 완료 시 검토 프롬프트",
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "작업이 완료되었습니다. 추가로 검토할 사항이 있나요?"
          }
        ]
      }
    ]
  }
}
```

> **참고**: `prompt` 타입은 `Stop`과 `SubagentStop` 훅에서만 지원됩니다.
