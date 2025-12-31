# Materials 파일 형식

## Template

```markdown
---
title: "{제목}"
date: YYYY-MM-DD
source: "{출처}"
type: article | document | conversation | snippet
status: raw
used_in:
---

{외부 재료 내용}
```

## 필드 설명

| 필드 | 필수 | 설명 |
|------|------|------|
| title | Y | 콘텐츠 제목 또는 핵심 키워드 |
| date | Y | 가져온 날짜 (YYYY-MM-DD) |
| source | Y | 출처 URL 또는 "직접 입력", "대화에서 추출" 등 |
| type | Y | article, document, conversation, snippet |
| status | Y | raw → used (draft에서 사용 후) |
| used_in | N | drafts 파일 경로 (사용 후 기록) |

## 파일명 규칙

```
inbox/materials/{date}-{slug}.md
```

- `{date}`: YYYY-MM-DD 형식
- `{slug}`: 영문 kebab-case (예: claude-code-guide, api-documentation)

## type 분류 기준

| Type | 특징 | source 예시 |
|------|------|-------------|
| article | 웹 기사, 블로그 | https://blog.example.com/post |
| document | 공식 문서, PDF | https://docs.example.com/api |
| conversation | 대화, 토론 | "Slack #channel", "Meeting notes" |
| snippet | 짧은 조각 | "직접 입력", "코드 복사" |

## 상태 흐름

```
raw → used
```

- **raw**: 가져온 직후 상태
- **used**: /gemify:draft에서 사용된 후
