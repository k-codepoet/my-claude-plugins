# views/by-improvement/ 템플릿

## Frontmatter

```yaml
---
title: "{Plugin Name} Improvement"
plugin: {plugin-name}
improvement_type: feature|bugfix|refactor
priority: high|medium|low
problem: "{해결할 문제}"
solution: "{해결 방법}"
artifact: {플러그인 경로 | null}
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
revision: 1
sources: []
history:
  - rev: 1
    date: YYYY-MM-DD
    summary: "초기 생성"
---
```

## 본문 구조

```markdown
## Why - 왜 개선하는가

[배경, 해결할 문제]

## What - 무엇을 바꾸는가

[변경할 내용 상세]

## Scope - 범위

**포함:**
- 포함 항목

**제외:**
- 제외 항목

## Acceptance Criteria - 완료 기준

[검증 완료 조건]

## Context - 참조

[관련 자료 링크]
```

## 상태 파악 (artifact 기반)

- `artifact: null` → 아이디어 단계 (문서만 존재)
- `artifact: {path}` → 플러그인 확인됨 (forgeify 진행 가능)
