---
name: inbox
description: 사용자의 생각을 inbox/thoughts/에 빠르게 저장. "저장해", "메모해", "inbox", "포착" 등 요청 시 활성화. raw 상태로 저장하여 /gemify:draft로 확장 가능.
---

# Inbox Skill

사용자의 생각을 **원석 상태로 빠르게 포착**합니다.

## 동작

1. 사용자가 말한 내용 파악
2. 최소한의 정돈 (마크다운)
3. `inbox/thoughts/{date}-{slug}.md`로 저장
4. "/gemify:draft로 다듬을 수 있어요" 안내

## 파일 형식 (YAML frontmatter)

```markdown
---
title: "{제목}"
date: YYYY-MM-DD
references: []
status: raw
used_in:
---

{내용}
```

## 필드 설명

| 필드 | 필수 | 설명 |
|------|------|------|
| title | Y | 핵심 키워드 추출한 제목 |
| date | Y | 생성일 (YYYY-MM-DD) |
| references | N | 참조한 materials 경로 배열 |
| status | Y | raw → used (draft에서 사용 후) |
| used_in | N | drafts 파일 경로 (사용 후 기록) |

## inbox 구조

| 폴더 | 용도 | 명령어 |
|------|------|--------|
| inbox/thoughts/ | 내 생각 (원석) | /gemify:inbox |
| inbox/materials/ | 외부 재료 | /gemify:import |

## 규칙

- **과하게 다듬지 않음** - raw 상태 유지
- 제목은 핵심 키워드 추출
- **파일명은 반드시 `YYYY-MM-DD-{slug}.md` 형식** (예: `2026-01-02-my-idea.md`)
- slug는 영문 kebab-case
- 저장 후 `/gemify:draft` 안내

## References

상세 형식과 예시는 `references/` 폴더 참조:
- `references/inbox-format.md` - 파일 형식 상세, 필드 설명
- `references/example-inbox.md` - 실제 inbox 파일 예시
