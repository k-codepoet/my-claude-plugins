# Drafts 예시

## 예시: 완성된 drafts 파일

**파일명**: `drafts/develop-mode-expansion.md`

```markdown
---
title: "develop 스킬 모드 확장"
created: "2024-12-31"
updated: "2024-12-31 09:45"
turns: 3
revision: 3
status: filed
sources:
  - inbox/thoughts/2024-12-31-develop-mode-expansion.md
  - inbox/materials/2024-12-31-claude-md-review.md
history:
  - rev: 1
    mode: facet
    date: 2024-12-31
    summary: "모드 구조 정리: BFS + DFS, progressive disclosure 히스토리"
    file: .history/develop-mode-expansion/01-facet-2024-12-31.md
  - rev: 2
    mode: facet
    date: 2024-12-31
    summary: "revision 기준 정의: pivot(방향 전환) 시 스냅샷"
    file: .history/develop-mode-expansion/02-facet-2024-12-31.md
  - rev: 3
    mode: polish
    date: 2024-12-31
    summary: "용어 확정: facet/polish (광물 메타포)"
    file: .history/develop-mode-expansion/03-polish-2024-12-31.md
---

## Current State

### 모드 (확정)

\`\`\`
/gemify:develop
├── facet  - 여러 면 탐색, 넓게 (BFS)
└── polish - 깊이 연마, 광택 (DFS) → file 준비

기본: facet
트리거: "연마해봐", "좀 더 다듬자" → polish
\`\`\`

### 히스토리 구조 (확정)

\`\`\`
drafts/
├── {slug}.md              # 현재 상태
└── .history/{slug}/
    └── {rev}-{mode}-{date}.md
\`\`\`

### revision = pivot (확정)

방향 전환 시 스냅샷 생성

### 자동화 (확정)

Stop 훅 + prompt → pivot 감지 → revision++

---

## Open Questions

- [ ] 스킬 구현 착수?
```

## 포인트

1. **frontmatter**: 메타데이터와 히스토리 요약
2. **Current State**: 현재까지의 결론 (압축된 형태)
3. **Open Questions**: 아직 해결 안 된 질문들
4. **status 변화**: developing → filed (file 완료 후)

## 히스토리 스냅샷 예시

**파일명**: `.history/develop-mode-expansion/01-facet-2024-12-31.md`

```markdown
---
session: 1
mode: facet
date: 2024-12-31
summary: "모드 구조 정리: BFS + DFS"
---

## 결정사항

- develop 모드를 facet/polish 두 가지로 구분
- facet: BFS 방식으로 여러 면 탐색
- polish: DFS 방식으로 깊이 연마

## 다음 작업

- [ ] revision 기준 정의하기
- [ ] 용어 확정하기
```

**포인트**:
- 그 시점에 확정된 결정사항
- 바로 작업 가능한 다음 작업 목록
