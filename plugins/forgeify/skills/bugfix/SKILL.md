---
name: bugfix
description: gemify:bugfix가 생성한 views/by-bugfix/ 문서를 읽고 버그 수정 실행. 2-Track (Workaround/Root Cause) 지원.
---

# Bugfix Skill

gemify:bugfix가 생성한 버그 수정 문서를 읽고 실행합니다.

## 단방향 흐름 원칙

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── bugfix 문서 생성 ────▶ bugfix 실행
        (views/by-bugfix/)    (/forgeify:bugfix)
```

## 입력

- **경로 지정**: `/forgeify:bugfix views/by-bugfix/gemify-retro-legacy.md`
- **대화 맥락**: 직전 gemify:bugfix 실행 결과 자동 감지
- **없음**: "어떤 bugfix 문서를 실행할까요?" 요청

## bugfix 문서 스키마

```yaml
---
title: "{Project} {Bug} Bug"
project: {project-name}
bug_slug: {bug-slug}
status: open|in_progress|resolved
priority: high|medium|low
created: YYYY-MM-DD
---

## Symptoms
## Impact
## Affected Files
## Root Cause Analysis
## Track A: Workaround
## Track B: Root Cause Fix
## Execution Options
## Resolution
```

## 워크플로우

### 1단계: bugfix 문서 파싱

bugfix 문서를 읽고 다음 정보를 추출:
- **frontmatter**: project, bug_slug, status, priority
- **Track A**: Workaround 해결책
- **Track B**: Root Cause Fix 목록 (Fix 1, Fix 2, ...)

### 2단계: 실행 옵션 제시

```
## Bugfix 실행: {project}/{bug_slug}

### Track A: Workaround
{workaround 요약}

### Track B: Root Cause
- Fix 1: {제목}
- Fix 2: {제목}
...

실행 옵션:
1. Track A만 (Workaround 빠르게)
2. Track B만 (Root Cause 순차)
3. Track A + B 병렬 (권장)
4. 특정 Fix만 (예: Fix 2만)

선택하세요 (1/2/3/4):
```

### 3단계: 실행

선택에 따라 실행:

**Option 1 (Track A)**:
- Workaround 섹션의 해결책 적용
- 빠른 복구 우선

**Option 2 (Track B)**:
- Fix 목록을 순차적으로 실행
- 각 Fix 완료 후 다음 Fix 진행
- 실패 시 중단하고 사용자 확인

**Option 3 (병렬)**:
- Task Agent 2개 실행
- Agent A: Track A (Workaround)
- Agent B: Track B Fix 1부터 순차
- 두 Agent 동시 진행

**Option 4 (특정 Fix)**:
- 지정된 Fix만 실행

### 4단계: 검증

각 Fix 완료 후:
- 변경 사항 요약
- 테스트/빌드 실행 (해당 시)
- AC (Acceptance Criteria) 확인

### 5단계: 문서 업데이트

모든 Fix 완료 후:
- bugfix 문서의 status → resolved
- Resolution 섹션 업데이트

```yaml
resolved_at: YYYY-MM-DD
resolved_by: forgeify:bugfix
verification: "검증 결과 요약"
```

## 대상 플러그인/프로젝트 탐색

1. bugfix 문서의 `project` 필드 확인
2. 현재 디렉토리가 마켓플레이스인 경우: `plugins/{project}/` 탐색
3. 현재 디렉토리가 플러그인인 경우: 해당 플러그인이 대상인지 확인
4. 찾지 못한 경우: 사용자에게 경로 요청

## 주의사항

- 모든 변경은 사용자 확인 후 진행
- 대규모 변경 시 git status 확인 권장
- Track B 실행 중 실패 시 다음 Fix로 자동 진행하지 않음
- 병렬 실행 시 충돌 가능성 있는 파일은 순차 처리
