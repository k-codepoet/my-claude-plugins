---
name: view
description: library 지식을 주제별로 조합하여 views/by-subject/에 저장. 도식+스토리 구조로 지식을 창문처럼 바라봄.
---

# View Skill

library의 지식을 **주제(subject)별로 조합**하여 views에 저장합니다.

## 핵심 개념

```
library/     ← 원천 데이터 (domain별 분류)
    ↓
views/       ← 조합 레이어 (주제별 창문)
└── by-subject/
    ├── gemify.md
    ├── ced.md
    └── gitops.md
```

**Views = 창문 (Window into Knowledge)**
- 지식을 분해하고 재조립해서 바라보는 창문
- 사람은 스토리로 기억한다 → 도식 + 스토리 구조

## 핵심 행동

### 1. 관련 문서 수집

**자동 수집:**
```bash
# library 문서 중 views 필드에 해당 subject가 있는 문서
views: [gemify, ced]  # 이 문서는 gemify, ced view에 포함
```

**대화로 수집 (신규 생성 시):**
1. "관련 문서가 뭐야?" 질문
2. 사용자가 알려주면 해당 문서에 `views: [subject]` 추가

### 2. View 파일 생성/업데이트

```markdown
# {Subject} View

## 구조
(단순 ASCII 도식, 필요시 Mermaid)
[inbox] → [drafts] → [library]
   ↓         ↓          ↓
 포착       다듬기      정리

## 스토리
(왜 시작 → 뭘 결정 → 어디까지)
(링크는 스토리 안에 자연스럽게)

## 관련 문서
(views: [subject] 태그 기반 자동 수집 목록)
```

### 3. 양방향 연결

- **library → views**: `views: [gemify, ced]` 필드
- **views → library**: 스토리 안에 자연스러운 링크

## 파일 형식 (views/by-subject/)

```markdown
---
title: "{Subject} View"
subject: {subject}
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
---

# {Subject} View

## 구조

{ASCII 도식 또는 Mermaid}

## 스토리

{왜 시작했는지}
{어떤 결정을 내렸는지}
{현재 어디까지 왔는지}

## 관련 문서

- [문서1](../library/domain/slug.md)
- [문서2](../library/domain/slug.md)
```

## 세션 동작

| 시점 | 동작 |
|------|------|
| 목록 | views/by-subject/ 파일 목록 표시 |
| 신규 | 대화로 관련 문서 수집 → view 생성 |
| 업데이트 | views 태그 기반 자동 수집 → 갱신 |

## 규칙

- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- subject는 영문 kebab-case (gemify, ced, gitops)
- library 문서에 views 태그 추가 시 사용자 확인
