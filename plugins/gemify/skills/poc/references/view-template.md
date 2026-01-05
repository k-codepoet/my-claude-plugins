# views/by-poc/ 템플릿

## Frontmatter

```yaml
---
title: "{Product Name} PoC"
product: {product-name}
hypothesis: "{검증하려는 가설}"
artifact: {프로젝트 경로 | null}
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
## Why - 왜 만드는가

[배경, 해결할 문제]

## Hypothesis - 검증하려는 가설

[이것이 가능하다면 ~]

## What - 무엇을 만드는가

[핵심 기능, MVP 범위]

## Acceptance Criteria - 가설 검증 기준

[검증 완료 조건]

## Context - 참조

[관련 자료 링크]
```

## 상태 파악 (artifact 기반)

- `artifact: null` → 아이디어 단계 (문서만 존재)
- `artifact: {path}` → 프로젝트 생성됨 (craftify 진행 가능)
