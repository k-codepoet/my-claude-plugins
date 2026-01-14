---
title: "{Project} {Bug Summary}"
project: {project-name}
bug_type: runtime|build|config|logic|integration
severity: critical|high|medium|low
status: analyzing|in_progress|resolved|wont_fix
symptom: "{증상 요약}"
root_cause: "{근본 원인 - 파악 후 업데이트}"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
revision: 1
sources: []
history:
  - rev: 1
    date: YYYY-MM-DD
    summary: "초기 생성"
---

# {Project} - {Bug Summary}

## Symptom - 증상

**에러 메시지:**
```
{에러 메시지}
```

**재현 단계:**
1. {단계 1}
2. {단계 2}
3. {단계 3}

**발생 조건:**
- {조건}

## Analysis - 분석

**관련 코드:**
- `{파일경로}:{라인}`

**조사 내용:**
{분석 내용}

---

## Track A: Workaround (빠른 해결)

**예상 소요**: 즉시 ~ 30분
**적용 범위**: 임시 해결
**부작용**: {있다면}

### 해결책

{빠른 해결 방법}

### 적용 방법

1. {단계 1}
2. {단계 2}

---

## Track B: Root Cause Fix (근본 해결)

**예상 소요**: 조사 필요
**적용 범위**: 영구 해결

### 가설 (우선순위순)

1. **[HIGH] 가설 1**
   - **근거**: {왜 이 가설을 세웠는지}
   - **검증 방법**: {어떻게 확인할지}
   - **해결책**: {맞다면 어떻게 고칠지}

2. **[MEDIUM] 가설 2**
   - **근거**:
   - **검증 방법**:
   - **해결책**:

3. **[LOW] 가설 3**
   - **근거**:
   - **검증 방법**:
   - **해결책**:

---

## Resolution - 해결 결과

**상태**: analyzing
**적용된 해결책**: {Track A/B 중 무엇을, 어떤 가설로}
**검증**: {어떻게 확인했는지}
**후속 조치**: {있다면}
