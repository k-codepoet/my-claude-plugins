---
name: sidebar
description: 본 작업 중 떠오른 것을 옆에 빼두기. material(외부 기록)과 thought(내 생각)를 쌍으로 한번에 생성.
allowed-tools: Read, Write, Edit
---

# Sidebar Skill

본론 아닌 걸 옆으로 빼두기 - **material + thought를 쌍으로 한번에 생성**합니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 언제 사용하나

- 본 작업 중 "이건 나중에" 싶은 게 떠올랐을 때
- 의사결정 과정(대화)과 핵심 인사이트(생각)를 함께 저장하고 싶을 때
- `/gemify:import` + `/gemify:inbox`를 따로 쓰기 번거로울 때
- 대화에서 외부 정보와 내 해석을 분리해서 저장하고 싶을 때

## 동작

1. 직전 대화 맥락 분석
2. **Material 추출**: 의사결정 과정, 외부 정보, 논의 내용 → `inbox/materials/`
3. **Thought 추출**: 핵심 인사이트, 내 생각, 결론 → `inbox/thoughts/`
4. thought의 `references`에 material 경로 연결
5. 두 파일 저장 후 요약 안내

## 생성되는 파일

### Material (inbox/materials/)

```markdown
---
title: "{대화 주제}"
date: YYYY-MM-DD
source: "대화에서 추출"
type: conversation
status: raw
used_in:
---

{의사결정 과정, 논의 내용}
```

### Thought (inbox/thoughts/)

```markdown
---
title: "{핵심 인사이트}"
date: YYYY-MM-DD
status: raw
used_in:
references:
  - inbox/materials/YYYY-MM-DD-{material-slug}.md
---

{내 핵심 생각}
```

## 규칙

- **Material**: 대화의 맥락, 과정, 외부 정보 위주
- **Thought**: 거기서 뽑은 핵심 인사이트, 내 결론 위주
- **파일명은 반드시 `YYYY-MM-DD-{slug}.md` 형식**
- thought의 `references`에 material 경로 연결
- 저장 후 `/gemify:draft` 안내

## 예시

```
/gemify:sidebar
```

결과:
- `inbox/materials/2026-01-02-plugin-improvement-discussion.md` - 논의 과정
- `inbox/thoughts/2026-01-02-sidebar-need.md` - 핵심 인사이트

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

- `y` 입력 시: 현재 맥락(material/thought 내용)을 해당 스킬에 전달
- `n` 입력 시: sidebar 정상 완료 후 draft 안내

## 다음 단계

저장된 쌍은 `/gemify:draft`에서 함께 다듬을 수 있습니다.
