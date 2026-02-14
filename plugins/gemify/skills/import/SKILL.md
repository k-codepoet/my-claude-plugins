---
name: import
description: 외부 재료를 inbox/materials/에 저장. "가져와", "import", "이 기사", "이 문서" 등 외부 콘텐츠 저장 요청 시 활성화. raw 상태로 저장하여 /gemify:draft에서 thoughts와 함께 사용 가능.
allowed-tools: Read, Write, Edit, WebFetch
argument-hint: "[URL/내용]"
---

# Import Skill

외부 재료(기사, 문서, 대화 등)를 **inbox/materials/에 저장**합니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 동작

1. scope 스킬 규칙에 따라 현재 도메인 경로 결정
2. 콘텐츠 소스 파악 (URL, 텍스트, 대화)
3. type 자동 감지
4. 최소한의 정돈 (마크다운)
5. `{domain_path}/inbox/materials/{date}-{slug}.md`로 저장
6. "/gemify:draft에서 내 생각과 함께 다듬을 수 있어요" 안내

## 파일 형식 (YAML frontmatter)

```markdown
---
title: "{제목}"
date: YYYY-MM-DD
source: "{출처 URL 또는 설명}"
type: article | document | conversation | snippet | other
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
| type | Y | article, document, conversation, snippet, other 중 하나 |
| status | Y | raw → used (draft에서 사용 후) |
| used_in | N | drafts 파일 경로 (사용 후 기록) |

## type 분류

| Type | 설명 | 예시 |
|------|------|------|
| article | 웹 기사, 블로그 포스트 | 뉴스 기사, 기술 블로그 |
| document | 공식 문서, 보고서, 서비스/제품 문서 | API 문서, 연구 논문, 제품 소개 |
| conversation | 대화, 토론 내용 | 슬랙 대화, 미팅 노트 |
| snippet | 짧은 코드나 텍스트 조각 | 코드 스니펫, 인용문 |
| other | 기타 분류 어려운 재료 | 이미지 설명, 혼합 콘텐츠 |

## inbox 구조

| 폴더 | 용도 | 명령어 |
|------|------|--------|
| inbox/thoughts/ | 내 생각 (원석) | /gemify:inbox |
| inbox/materials/ | 외부 재료 | /gemify:import |

## 규칙

- 원본 내용 **최대한 보존** - 요약하지 않음
- source 필드에 출처 명확히 기록
- **파일명은 반드시 `YYYY-MM-DD-{slug}.md` 형식** (예: `2026-01-02-claude-guide.md`)
- slug는 영문 kebab-case
- 저장 후 `/gemify:draft` 안내

## 스킬 전환 감지

저장 전 내용 분석하여 확정된 워크플로우 패턴 감지:

### improve-plugin 패턴

**조건:** 알려진 플러그인명 + 개선/수정 의도
- 플러그인명: gemify, forgeify, craftify, namify, terrafy 등
- 키워드: "개선", "수정", "추가", "변경", "기능"

**감지 시:**
```
이 내용은 플러그인 개선 요청으로 보입니다.
/gemify:improve-plugin으로 전환할까요? (y/n)
```

### poc 패턴

**조건:** 가설 검증 + 뭔가 만들어서 해결
- 키워드: "만들어보자", "PoC", "앱", "프로토타입", "검증", "시도"
- 맥락: 무언가를 만들어서 가설을 입증해야 하는 상황

**감지 시:**
```
이 내용은 가설 검증이 필요한 것 같습니다.
/gemify:poc으로 전환하여 PoC 문서를 만들까요? (y/n)
```

### 전환 동작

- `y` 입력 시: 현재 맥락(material 내용)을 해당 스킬에 전달
- `n` 입력 시: import 정상 완료 후 draft 안내

## References

상세 형식과 예시는 `references/` 폴더 참조:
- `references/materials-format.md` - 파일 형식 상세, 필드 설명
- `references/example-materials.md` - 실제 materials 파일 예시
