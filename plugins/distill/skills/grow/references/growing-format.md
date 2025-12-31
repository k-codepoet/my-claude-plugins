# Growing 파일 형식

## Frontmatter

```yaml
---
title: "{제목}"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD HH:MM"
turns: 5
revision: 2
status: growing | digested
sources:
  - seed/2024-12-31-my-idea.md
  - materials/some-article.md
history:
  - rev: 1
    mode: branch
    date: 2024-12-31
    summary: "요약"
    file: .history/{slug}/01-branch-2024-12-31.md
  - rev: 2
    mode: ripen
    date: 2024-12-31
    summary: "요약"
    file: .history/{slug}/02-ripen-2024-12-31.md
---
```

## 본문 구조

```markdown
## Current State
{현재까지 종합 - 압축된 상태}

---

## Open Questions
- [ ] 열린 질문들
```

## 히스토리 구조

```
growing/
├── {slug}.md              # 현재 상태 (압축)
└── .history/{slug}/
    ├── 01-branch-2024-12-31.md
    └── 02-ripen-2024-12-31.md
```

## 스냅샷 파일 형식

```markdown
---
session: 1
mode: branch | ripen
date: YYYY-MM-DD
summary: "요약"
---

## 결정사항
{확정된 것들}

## 다음 작업
- [ ] ...
```

## 소스 추적

seed/materials 파일 사용 시:
1. 해당 파일의 `status`를 `raw` → `used`로 변경
2. 해당 파일의 `used_in`에 growing 파일 경로 기록
3. growing 파일의 `sources` 배열에 추가

## revision 증가 조건 (pivot)

- branch 중 → 다른 방향 branch
- branch → ripen 전환
- ripen 중 → 다른 방향 ripen
