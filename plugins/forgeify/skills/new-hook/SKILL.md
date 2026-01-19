---
name: new-hook
description: 새 훅 생성. "훅 만들기", "new hook", "hooks.json 추가" 등 요청 시 활성화.
---

# new-hook Skill

## 개요

Claude Code 플러그인에 새 훅(Hook)을 생성합니다.

## 인자

```
/forgeify:new-hook <event-type> [plugin-path]

- event-type: 이벤트 타입 (PreToolUse, PostToolUse, Stop, SessionStart, UserPromptSubmit)
- plugin-path: 플러그인 경로 (기본: 현재 디렉토리)
```

## 워크플로우

### 1단계: 대상 플러그인 확인

1. `plugin-path` 인자 확인
2. 없으면 현재 디렉토리에서 `.claude-plugin/plugin.json` 탐색
3. 없으면 사용자에게 플러그인 경로 요청

### 2단계: 이벤트 타입 확인

유효한 이벤트 타입:

| 이벤트 | 설명 |
|--------|------|
| `PreToolUse` | 도구 실행 전 (차단 가능) |
| `PostToolUse` | 도구 실행 후 |
| `Stop` | Claude 응답 완료 시 |
| `SessionStart` | 세션 시작 시 |
| `UserPromptSubmit` | 사용자 프롬프트 제출 시 |

### 3단계: 훅 정보 수집 (대화)

사용자에게 질문:

```
새 훅을 생성합니다.

이벤트 타입: {event-type}

1. 매처 (matcher, 선택):
   > 특정 도구에만 적용 (정규식 가능)
   > 예: "Bash", "Write|Edit|MultiEdit"
   > 생략하면 모든 경우에 적용

2. 훅 동작:
   > 이 훅이 수행할 작업을 설명해주세요
   > 예: "Bash 실행 전 위험한 명령어 확인"

3. 타임아웃 (timeout, 선택):
   > 초 단위 (기본: 없음)
```

### 4단계: hooks 디렉토리 확인/생성

```
{plugin-path}/hooks/
├── hooks.json         # 훅 설정 파일
└── scripts/           # 훅 스크립트 (선택)
    └── {event-type}-hook.sh
```

### 5단계: 스크립트 파일 생성

**경로**: `{plugin-path}/hooks/scripts/{event-type}-hook.sh`

**템플릿**:

```bash
#!/usr/bin/env bash
set -euo pipefail

# {event-type} Hook
# {훅 동작 설명}

# 환경 변수:
# - CLAUDE_PLUGIN_ROOT: 플러그인 루트 경로
# - (PreToolUse/PostToolUse) 도구 관련 정보는 stdin으로 전달

# 입력 읽기 (필요시)
# input=$(cat)

# 로직 구현
# ...

# 결과 출력 (Stop 훅의 경우)
# cat << 'EOF'
# {
#   "continue": true,
#   "systemMessage": "메시지"
# }
# EOF

exit 0
```

### 6단계: hooks.json 업데이트

기존 `hooks.json`이 있으면 병합, 없으면 새로 생성:

```json
{
  "description": "플러그인 훅 설명",
  "hooks": {
    "{event-type}": [
      {
        "matcher": "{matcher}",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/{event-type}-hook.sh"
          }
        ]
      }
    ]
  }
}
```

**주의**:
- `type: "command"` 만 사용 (`type: "prompt"`는 플러그인에서 무시됨)
- `${CLAUDE_PLUGIN_ROOT}` 환경 변수 사용 필수

### 7단계: 스크립트 실행 권한

```bash
chmod +x {plugin-path}/hooks/scripts/{event-type}-hook.sh
```

### 8단계: 완료 메시지

```
✅ 훅 생성 완료

설정: {plugin-path}/hooks/hooks.json
스크립트: {plugin-path}/hooks/scripts/{event-type}-hook.sh

디버깅:
  claude --debug hooks

다음 단계:
- 스크립트 로직 구현
- 테스트 실행
- /forgeify:validate로 검증
```

## Stop 훅 JSON 출력

Stop 훅에서 Claude 동작을 제어하려면:

```bash
cat << 'EOF'
{
  "continue": true,
  "systemMessage": "📝 안내 메시지"
}
EOF
```

| 필드 | 설명 |
|------|------|
| `continue` | `true`: 종료 허용, `false`: 종료 차단 |
| `decision` | `"block"`: 종료 막고 계속, `"approve"`: 종료 허용 |
| `reason` | `decision: "block"` 시 Claude에게 전달 |
| `systemMessage` | 사용자에게 표시할 메시지 |

## 규칙

1. **type: command 만 사용**: 플러그인에서 `type: "prompt"`는 무시됨
2. **CLAUDE_PLUGIN_ROOT 사용**: 스크립트 경로에 필수
3. **exit 코드**: 0=성공, 2=차단, 그 외=비차단 오류
4. **매처 대소문자**: `Bash`, `Write`, `Edit` 등 정확히 일치

## 참조

- hook-guide 스킬의 상세 규격 참조
