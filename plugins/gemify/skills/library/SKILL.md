---
name: library
description: drafts의 다듬어진 보석을 library로 저장. "정리해", "분류해", "library" 요청 또는 draft 세션에서 완성도 충분 시 활성화.
---

# Library Skill

drafts의 다듬어진 보석을 **소크라테스식 질문**으로 정리하여 library에 저장합니다.

## 핵심 행동

### 1. 소크라테스식 질문 (순차, 하나씩)

| Phase | 질문 |
|-------|------|
| 목적 | "이거 왜 남기려고 해?", "이게 없으면 나중에 뭐가 안 돼?" |
| 압축 | "한 문장으로 요약하면?", "진짜 핵심만 남기면?" |
| 분류 | "6개 domain 중 어디야?" |
| 연결 | "기존 library에 연결되는 거 있어?" |

### 2. 재조립 제안

답변을 바탕으로 구조화된 문서 초안 제시. (상세: `references/library-format.md`)

### 3. 저장

사용자 컨펌 후:
1. `library/{domain}/{slug}.md`로 저장
2. 원본 drafts 파일의 status → `set`
3. 완료 보고

## library 파일 형식 (YAML frontmatter)

```markdown
---
title: {제목}
domain: {product|engineering|operations|growth|business|ai-automation}
---

## Context

{왜 이 지식이 필요한지}

## Content

{핵심 내용}
```

## 6대 Domain

| Domain | 핵심 질문 |
|--------|----------|
| product | 무엇을 만들 것인가? |
| engineering | 어떻게 만들 것인가? |
| operations | 어떻게 돌릴 것인가? |
| growth | 어떻게 알릴 것인가? |
| business | 어떻게 유지할 것인가? |
| ai-automation | 어떻게 위임할 것인가? |

## 규칙

- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- 템플릿 파일 (`_template.md`) 제외
- slug는 영문 kebab-case

## References

상세 형식과 예시는 `references/` 폴더 참조:
- `references/library-format.md` - library 파일 형식, domain 설명
- `references/example-library.md` - 실제 library 파일 예시, domain 선택 기준
