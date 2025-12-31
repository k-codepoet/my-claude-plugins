# Inbox 파일 형식

## Template

```markdown
---
title: "{제목}"
date: YYYY-MM-DD
references: []
status: raw
used_in:
---

{내 생각의 원석}
```

## 필드 설명

| 필드 | 필수 | 설명 |
|------|------|------|
| title | Y | 핵심 키워드 추출한 제목 |
| date | Y | 생성일 (YYYY-MM-DD) |
| references | N | 참조한 materials 경로 배열 |
| status | Y | raw → used (develop에서 사용 후) |
| used_in | N | drafts 파일 경로 (사용 후 기록) |

## 파일명 규칙

```
inbox/thoughts/{date}-{slug}.md
```

- `{date}`: YYYY-MM-DD 형식
- `{slug}`: 영문 kebab-case (예: my-idea, knowledge-pipeline)

## 상태 흐름

```
raw → used
```

- **raw**: 저장 직후 상태
- **used**: /gemify:draft에서 사용된 후
