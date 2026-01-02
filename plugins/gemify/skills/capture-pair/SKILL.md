---
name: capture-pair
description: 대화에서 material(외부 기록)과 thought(내 생각)를 쌍으로 한번에 생성. 의사결정 과정과 핵심 인사이트를 동시에 포착.
---

# Capture-Pair Skill

대화 맥락에서 **material + thought를 쌍으로 한번에 생성**합니다.

## 언제 사용하나

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
/gemify:capture-pair
```

결과:
- `inbox/materials/2026-01-02-plugin-improvement-discussion.md` - 논의 과정
- `inbox/thoughts/2026-01-02-capture-pair-need.md` - 핵심 인사이트

## 다음 단계

저장된 쌍은 `/gemify:draft`에서 함께 다듬을 수 있습니다.
