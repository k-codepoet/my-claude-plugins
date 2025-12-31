# Growing 예시

## 예시: 완성된 growing 파일

**파일명**: `growing/grow-mode-expansion.md`

```markdown
---
title: "grow 스킬 모드 확장"
created: "2024-12-31"
updated: "2024-12-31 09:45"
turns: 3
revision: 3
status: digested
sources:
  - seed/2024-12-31-grow-mode-expansion.md
  - materials/2024-12-31-claude-md-review.md
history:
  - rev: 1
    mode: branch
    date: 2024-12-31
    summary: "모드 구조 정리: BFS + DFS, progressive disclosure 히스토리"
    file: .history/grow-mode-expansion/01-expand-2024-12-31.md
  - rev: 2
    mode: branch
    date: 2024-12-31
    summary: "revision 기준 정의: pivot(방향 전환) 시 스냅샷"
    file: .history/grow-mode-expansion/02-expand-2024-12-31.md
  - rev: 3
    mode: branch
    date: 2024-12-31
    summary: "용어 확정: branch/ripen (식물 메타포)"
    file: .history/grow-mode-expansion/03-expand-2024-12-31.md
---

## Current State

### 모드 (확정)

\`\`\`
/distill:grow
├── branch - 가지치기, 넓게 뻗기 (BFS)
└── ripen  - 익히기, 응축 (DFS) → digest 준비

기본: branch
트리거: "익혀봐", "좀 더 익히자" → ripen
\`\`\`

### 히스토리 구조 (확정)

\`\`\`
growing/
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
4. **status 변화**: growing → digested (digest 완료 후)

## 히스토리 스냅샷 예시

**파일명**: `.history/grow-mode-expansion/01-expand-2024-12-31.md`

```markdown
---
session: 1
mode: branch
date: 2024-12-31
summary: "모드 구조 정리: BFS + DFS"
---

## 결정사항

- grow 모드를 branch/ripen 두 가지로 구분
- branch: BFS 방식으로 넓게 탐색
- ripen: DFS 방식으로 깊이 응축

## 다음 작업

- [ ] revision 기준 정의하기
- [ ] 용어 확정하기
```

**포인트**:
- 그 시점에 확정된 결정사항
- 바로 작업 가능한 다음 작업 목록
