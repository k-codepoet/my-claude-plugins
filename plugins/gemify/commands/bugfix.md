---
description: 버그 수정 문서 생성. 2-track(workaround + root cause) 병렬 전략.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
argument-hint: [프로젝트명 또는 버그 설명]
---

# /gemify:bugfix - 버그 수정 문서 생성

버그 수정 **문서를 생성**합니다. 실제 코드 수정은 forgeify/craftify가 담당합니다.

## 사용법

```
/gemify:bugfix                        # 대화형으로 버그 정보 수집
/gemify:bugfix "프로젝트명 버그설명"   # 직접 입력
```

## 핵심 전략: 2-Track 병렬 진행

```
Track A: Workaround (빠른 해결)
  - 즉시 적용 가능한 임시 해결책
  - 서비스 복구 우선

Track B: Root Cause Fix (근본 해결)
  - 가설 우선순위 나열
  - 순차적으로 검증
  - 재발 방지
```

## 워크플로우

```
버그 발생
    │
    ▼
/gemify:troubleshoot (선택적)
    │
    ▼
/gemify:bugfix
    │
    ├─▶ Track A: Workaround 문서화
    └─▶ Track B: Root Cause 가설 나열
    │
    ▼
views/by-bugfix/{project}-{slug}.md 저장
    │
    ▼
실행 옵션:
1. Workaround만 (빠르게)
2. Root Cause만 (근본)
3. 둘 다 병렬 (권장)
    │
    ▼
Forgeify/Craftify로 핸드오프
```

## 동작

1. 버그 정보 수집 (troubleshoot 연계 또는 직접 입력)
2. Track A (Workaround) 문서화
3. Track B (Root Cause) 가설 우선순위 나열
4. `views/by-bugfix/{project}-{slug}.md` 저장
5. 실행 옵션 선택 후 forgeify/craftify 핸드오프

## 파일명 규칙

```
{project}-{bug-slug}.md
```

예시:
- `session-report-viewer-github-rate-limit.md`
- `gemify-scope-not-found.md`

## 규칙

- **코드 수정 금지**: gemify는 문서 생성만 담당
- **views/by-bugfix/에 원본 저장**
- 가설은 검증 가능해야 함 (구체적인 검증 방법 필수)
