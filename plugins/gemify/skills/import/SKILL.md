---
name: import
description: 외부 재료를 inbox/materials/에 저장. "가져와", "import", "이 기사", "이 문서" 등 외부 콘텐츠 저장 요청 시 활성화. raw 상태로 저장하여 /gemify:draft에서 thoughts와 함께 사용 가능.
---

# Import Skill

외부 재료(기사, 문서, 대화 등)를 **inbox/materials/에 저장**합니다.

## 동작

1. 콘텐츠 소스 파악 (URL, 텍스트, 대화)
2. type 자동 감지
3. 최소한의 정돈 (마크다운)
4. `inbox/materials/{date}-{slug}.md`로 저장
5. "/gemify:draft에서 내 생각과 함께 다듬을 수 있어요" 안내

## 파일 형식 (YAML frontmatter)

```markdown
---
title: "{제목}"
date: YYYY-MM-DD
source: "{출처 URL 또는 설명}"
type: article | document | conversation | snippet
status: raw
used_in:
---

{내용}
```

## 필드 설명

| 필드 | 필수 | 설명 |
|------|------|------|
| title | Y | 콘텐츠 제목 또는 핵심 키워드 |
| date | Y | 가져온 날짜 (YYYY-MM-DD) |
| source | Y | 출처 URL 또는 "직접 입력", "대화에서 추출" 등 |
| type | Y | article, document, conversation, snippet 중 하나 |
| status | Y | raw → used (draft에서 사용 후) |
| used_in | N | drafts 파일 경로 (사용 후 기록) |

## type 분류

| Type | 설명 | 예시 |
|------|------|------|
| article | 웹 기사, 블로그 포스트 | 뉴스 기사, 기술 블로그 |
| document | 공식 문서, 보고서 | API 문서, 연구 논문 |
| conversation | 대화, 토론 내용 | 슬랙 대화, 미팅 노트 |
| snippet | 짧은 코드나 텍스트 조각 | 코드 스니펫, 인용문 |

## inbox 구조

| 폴더 | 용도 | 명령어 |
|------|------|--------|
| inbox/thoughts/ | 내 생각 (원석) | /gemify:inbox |
| inbox/materials/ | 외부 재료 | /gemify:import |

## 규칙

- 원본 내용 **최대한 보존** - 요약하지 않음
- source 필드에 출처 명확히 기록
- slug는 영문 kebab-case
- 저장 후 `/gemify:draft` 안내

## References

상세 형식과 예시는 `references/` 폴더 참조:
- `references/materials-format.md` - 파일 형식 상세, 필드 설명
- `references/example-materials.md` - 실제 materials 파일 예시
