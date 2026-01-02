---
description: 플러그인 개선 작업 - 해당 플러그인 경로를 add-dir로 추가하고 개선
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
argument-hint: [플러그인 경로]
---

# /gemify:improve-plugin - 플러그인 개선 작업

플러그인 경로를 워크스페이스에 추가하고 개선 작업을 수행합니다.

## 사용법

```
/gemify:improve-plugin ~/plugins/my-plugin     # 특정 플러그인 개선
/gemify:improve-plugin                          # 경로 입력 요청
```

## 동작

### 1. 경로 확보

```
$ARGUMENTS 있음? → 해당 경로 사용
$ARGUMENTS 없음? → AskUserQuestion으로 경로 입력 요청
                   "어떤 플러그인을 개선할까요? 경로를 입력해주세요"
```

### 2. 접근 권한 확인

```
경로 확보됨
    ↓
이미 접근 가능? (워킹 디렉토리 또는 additionalDirectories)
    ↓
Yes → 바로 작업 시작
No  → 사용자에게 안내: "/add-dir {경로} 실행해주세요"
      → (사용자가 /add-dir 실행)
      → 접근 가능 확인 후 작업 시작
```

### 3. 개선 작업

- 플러그인 구조 파악 (plugin.json, skills/, commands/)
- inbox/에서 관련 아이디어 검색
- 개선 작업 수행

### 4. 영구 등록 제안 (선택)

작업 완료 후:
```
"이 플러그인을 자주 작업하시나요?"
    ↓
Yes → .claude/settings.json의 additionalDirectories에 추가
      ⚠️ "등록 완료. 다음 세션부터 적용됩니다 (재시작 필요)"
No  → 세션 종료 시 자동 스코프 해제
```

**주의**: settings.json 수정은 **다음 세션부터** 적용됨. 현재 세션에서는 이미 `/add-dir`로 추가된 상태이므로 문제없음.

## 규칙

- `/add-dir`은 **사용자가 직접 실행** - Claude가 대신 실행 불가
- 경로 없으면 반드시 사용자에게 요청 (추측하지 않음)
- 영구 등록은 사용자 선택에 따름
