---
name: bugfix
description: 버그 수정 문서 생성. "버그 수정", "bugfix", "고쳐줘", "fix" 등 요청 시 활성화. 2-track(workaround + root cause) 병렬 전략으로 빠른 해결과 근본 해결을 동시 진행.
---

# Bugfix Skill

버그 수정 **문서를 생성**합니다. 실제 코드 수정은 forgeify/craftify가 담당합니다.

플러그인, 앱, 서비스 등 모든 종류의 버그에 범용 적용 가능합니다.

## 사전 확인 (필수)

**스킬 실행 전 반드시 확인:**

```
~/.gemify/ 존재?
├── 예 → 스킬 실행 계속
└── 아니오 → setup 안내 후 중단
```

## 핵심 전략: 2-Track 병렬 진행

```
버그 발생
    │
    ▼
┌───────────────────────────────────────┐
│  Track A: Workaround (빠른 해결)      │
│  - 즉시 적용 가능한 임시 해결책       │
│  - 서비스 복구 우선                   │
└───────────────────────────────────────┘
        │                    │
        │    (병렬 진행)     │
        │                    │
        ▼                    ▼
┌───────────────────────────────────────┐
│  Track B: Root Cause Fix (근본 해결)  │
│  - 가설 우선순위 나열                 │
│  - 순차적으로 검증                    │
│  - 재발 방지                          │
└───────────────────────────────────────┘
```

## 워크플로우

```
버그 발생
    │
    ▼
/gemify:troubleshoot (선택적)
    │ inbox/materials/에 분석 기록
    ▼
/gemify:bugfix
    │
    ├─▶ Track A: Workaround 문서화
    │
    └─▶ Track B: Root Cause 가설 나열
    │
    ▼
views/by-bugfix/{project}-{slug}.md 저장
    │
    ▼
실행 옵션 선택
    │
    ├─▶ 1. Workaround만 (빠르게)
    ├─▶ 2. Root Cause만 (근본 해결)
    └─▶ 3. 둘 다 병렬 실행 (권장)
    │
    ▼
Forgeify/Craftify로 핸드오프
```

## 동작

### 1. 입력 분석

- troubleshoot 결과 경로 → 해당 분석 기반으로 문서 생성
- 직접 버그 설명 → 증상 수집 후 문서 생성
- 없음 → "어떤 버그를 수정할까요?" 요청

### 2. 증상 및 분석 정리

troubleshoot에서 가져오거나 새로 수집:
- 증상 (에러 메시지, 재현 단계)
- 분석 내용 (관련 코드, 원인 추정)

### 3. 2-Track 문서화

**Track A (Workaround):**
- 즉시 적용 가능한 해결책
- 예상 소요 시간
- 적용 방법

**Track B (Root Cause Fix):**
- 가설 목록 (우선순위순)
- 각 가설별: 근거, 검증 방법, 해결책
- 순차적으로 검증할 수 있도록 구조화

### 4. view 생성

`views/by-bugfix/{project}-{slug}.md` 저장

템플릿: `references/bugfix-template.md` 참조

### 5. 실행 핸드오프

문서 생성 완료 후:

```
버그 수정 문서가 생성되었습니다:
{views/by-bugfix/...}

실행 옵션:
1. Workaround만 빠르게 적용 (Track A)
2. Root Cause 분석 및 수정 (Track B)
3. 둘 다 병렬로 실행 (권장)

선택하세요 (1/2/3):
```

**옵션별 동작:**
- 1: forgeify/craftify에 Track A 섹션만 전달
- 2: forgeify/craftify에 Track B 섹션 전달, 가설 순차 검증
- 3: Task Agent 2개를 병렬로 실행

## 저장 위치

```
{ground-truth-path}/
└── views/
    ├── by-bugfix/
    │   └── {project}-{bug-slug}.md
    └── .history/
        └── bugfix/
            └── {project}-{bug-slug}/
                └── 01-YYYY-MM-DD.md
```

## 파일명 규칙

```
{project}-{bug-slug}.md
```

예시:
- `session-report-viewer-github-rate-limit.md`
- `gemify-scope-not-found.md`
- `craftify-build-error.md`

## 규칙

- **코드 수정 금지**: gemify는 문서 생성만 담당
- **views/by-bugfix/에 원본 저장**
- **업데이트 시 .history/ 스냅샷 생성**
- 가설은 검증 가능해야 함 (구체적인 검증 방법 필수)
- 우선순위가 높은 가설부터 순차 검증
- 해결 후 Resolution 섹션 업데이트
