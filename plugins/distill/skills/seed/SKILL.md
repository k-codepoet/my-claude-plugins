---
name: seed
description: 사용자의 생각을 seed/에 빠르게 저장. "저장해", "메모해", "seed", "씨앗" 등 요청 시 활성화. raw 상태로 저장하여 /distill:grow로 확장 가능.
---

# Seed Skill

사용자의 생각을 **씨앗 상태로 빠르게 저장**합니다.

## 동작

1. 사용자가 말한 내용 파악
2. 최소한의 정돈 (마크다운)
3. `seed/{date}-{slug}.md`로 저장
4. "/distill:grow로 키울 수 있어요" 안내

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
| status | Y | raw → used (grow에서 사용 후) |
| used_in | N | growing 파일 경로 (사용 후 기록) |

## seed vs materials

| 폴더 | 용도 | 명령어 |
|------|------|--------|
| seed/ | 내 생각의 씨앗 | /distill:seed |
| materials/ | 외부 재료 | /import (예정) |

## 규칙

- **과하게 다듬지 않음** - raw 상태 유지
- 제목은 핵심 키워드 추출
- slug는 영문 kebab-case
- 저장 후 `/distill:grow` 안내
