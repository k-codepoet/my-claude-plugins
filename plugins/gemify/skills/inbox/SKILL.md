---
name: inbox
description: 사용자의 생각을 inbox/thoughts/에 빠르게 저장. "저장해", "메모해", "inbox", "포착" 등 요청 시 활성화. raw 상태로 저장하여 /gemify:draft로 확장 가능.
---

# Inbox Skill

사용자의 생각을 **원석 상태로 빠르게 포착**합니다.

## 사전 확인 (필수)

**스킬 실행 전 반드시 확인:**

```
~/.gemify/ 존재?
├── 예 → 스킬 실행 계속
└── 아니오 → setup 안내 후 중단
```

Setup 안내:
```
~/.gemify/가 설정되지 않았습니다.

설정하기:
  /gemify:setup              # 새로 시작
  /gemify:setup --clone URL  # 기존 repo 가져오기
```

## 동작

1. ~/.gemify/ 존재 확인 (없으면 setup 안내)
2. 사용자가 말한 내용 파악
3. 최소한의 정돈 (마크다운)
4. `~/.gemify/inbox/thoughts/{date}-{slug}.md`로 저장
5. "/gemify:draft로 다듬을 수 있어요" 안내

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

- `y` 입력 시: 현재 맥락(thought 내용)을 해당 스킬에 전달
- `n` 입력 시: inbox 정상 완료 후 draft 안내

## References

상세 형식과 예시는 `references/` 폴더 참조:
- `references/inbox-format.md` - 파일 형식 상세, 필드 설명
- `references/example-inbox.md` - 실제 inbox 파일 예시

## Core Principles

상세: `principles/pipeline-density.md` 참조
