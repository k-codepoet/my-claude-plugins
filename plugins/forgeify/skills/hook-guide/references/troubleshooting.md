# Hooks 트러블슈팅 가이드

## 체크리스트

훅이 동작하지 않을 때 순서대로 확인:

1. **구조 확인**: `hooks`가 객체이고 이벤트 타입이 키인지
2. **이벤트명 확인**: 키 값이 정확한 대소문자인지 (예: `PreToolUse`, 아님 `pretooluse`)
3. **매처 확인**: `matcher`가 Tool 이름과 대소문자까지 일치하는지 (예: `Bash`, 아님 `bash`)
4. **hooks 배열**: 각 이벤트 아래 `hooks` 배열이 있는지
5. **type 필드**: 각 훅에 `type: "command"` 또는 `type: "prompt"` 있는지
6. **스크립트 권한**: 실행 권한이 있는지 (`chmod +x scripts/*.sh`)
7. **세션 재시작**: 훅 변경 후 Claude 세션을 재시작했는지

## 흔한 실수

### 플랫 배열 구조 사용 (잘못됨)

```json
// ❌ 잘못된 예시
{
  "hooks": [
    { "event": "PreToolUse", "matcher": "Bash", "command": "..." }
  ]
}

// ✅ 올바른 예시
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "..." }]
      }
    ]
  }
}
```

### hooks 배열 누락

```json
// ❌ 잘못된 예시
{
  "hooks": {
    "PreToolUse": [
      { "type": "command", "command": "..." }
    ]
  }
}

// ✅ 올바른 예시
{
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [{ "type": "command", "command": "..." }]
      }
    ]
  }
}
```

### 소문자 매처

```json
// ❌ 잘못된 예시
{ "matcher": "bash" }

// ✅ 올바른 예시
{ "matcher": "Bash" }
```

### type 필드 누락

```json
// ❌ 잘못된 예시
{ "command": "./script.sh" }

// ✅ 올바른 예시
{ "type": "command", "command": "./script.sh" }
```

## 디버그 모드 사용

```bash
# 훅 로딩/실행 로그 확인
claude --debug

# 현재 로드된 훅 목록 확인
/hooks
```

디버그 로그에서 확인할 사항:
- 훅이 로드되었는지
- 이벤트가 트리거되었는지
- 매처가 일치하는지
- 커맨드가 실행되었는지
