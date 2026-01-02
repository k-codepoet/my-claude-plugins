---
description: 플러그인 개선 작업 - 해당 플러그인 경로를 add-dir로 추가하고 개선
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: [플러그인 경로]
---

# /gemify:improve-plugin - 플러그인 개선 작업

플러그인 경로를 워크스페이스에 추가하고 개선 작업을 수행합니다.

## 사용법

```
/gemify:improve-plugin ~/plugins/my-plugin     # 특정 플러그인 개선
/gemify:improve-plugin                          # inbox에서 플러그인 관련 아이디어 확인
```

## 동작

1. $ARGUMENTS가 있으면 → 해당 경로를 `/add-dir`로 추가 제안
2. 없으면 → inbox/materials에서 플러그인 관련 아이디어 검색
3. 플러그인 구조 파악 (plugin.json, skills/, commands/)
4. 개선 작업 수행
5. 세션 종료 시 자동으로 스코프 해제됨

## 워크플로우

```
inbox/materials에 플러그인 개선 아이디어
    ↓
/add-dir {플러그인 경로}
    ↓
개선 작업 수행
    ↓
세션 종료 → 자동 스코프 해제
```

## 규칙

- add-dir은 **사용자 승인 필요** - 자동 실행하지 않음
- 세션 한정으로 스코프 추가 (remove-dir 불필요)
- 플러그인 구조 파악 후 작업 시작
