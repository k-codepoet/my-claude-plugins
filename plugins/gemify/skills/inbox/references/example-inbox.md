# Inbox 예시

## 예시 1: 단순 아이디어

**파일명**: `inbox/thoughts/2024-12-31-develop-mode-expansion.md`

```markdown
---
title: "develop 스킬 모드 확장"
date: 2024-12-31
references:
  - inbox/materials/2024-12-31-claude-md-review.md
status: used
used_in: drafts/develop-mode-expansion.md
---

develop 대화모드를 2가지 형태로 확장해야 함:

1. **facet**: 여러 면에서 탐색 (넓게)
2. **polish**: 깊이 연마 (응축)

현재 스킬에는 이 모드 전환 로직이 없음. 스킬 업데이트 필요.
```

**포인트**:
- 제목은 핵심 키워드 추출
- 내용은 raw 상태 유지 (과하게 다듬지 않음)
- 참조한 materials가 있으면 references에 기록
- develop에서 사용 후 status=used, used_in에 경로 기록

## 예시 2: 새로운 아이디어 (raw 상태)

**파일명**: `inbox/thoughts/2025-12-31-knowledge-pipeline-vision.md`

```markdown
---
title: "지식 파이프라인 비전"
date: 2025-12-31
references: []
status: raw
used_in:
---

capture → develop → file 파이프라인을 완성하면:

- 매일 떠오르는 생각을 빠르게 포착
- 대화를 통해 원석 다듬기
- 빛나는 보석만 library에 축적

이게 working memory 역할을 하게 될 것
```

**포인트**:
- 저장 직후라 status=raw
- used_in은 아직 비어있음
- 나중에 `/gemify:draft`로 확장 가능
