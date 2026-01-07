---
name: retro
description: 이미 완료된 작업을 역방향으로 library에 기록. "사후 기록", "역방향", "retro", "이미 만들었는데" 등 요청 시 활성화. inbox/drafts를 건너뛰고 바로 library로.
---

# Retro Skill (사후처리)

**이미 완료된 작업**의 의사결정 과정을 역방향으로 library에 기록합니다.

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

## 언제 사용하나

- 아이디어 논의 → 바로 구현해버린 경우
- inbox → drafts → library 흐름을 건너뛰고 작업한 경우
- 사후에 의사결정/지식을 library에 남기고 싶을 때

## 일반 흐름 vs Retro 흐름

```
[일반 흐름]
inbox → drafts → library → 구현

[Retro 흐름]
아이디어 → 구현(완료) → /gemify:retro → library
```

## 동작

1. 대화 맥락에서 **완료된 작업** 파악
2. 소크라테스식 질문 (순차, 하나씩)
   - "뭘 만들었어?" / "왜 만들었어?"
   - "핵심 결정 사항이 뭐였어?"
   - "나중에 참고할 만한 교훈이 있어?"
   - "6개 domain 중 어디야?"
3. library 문서 초안 제시
4. 사용자 컨펌 후 `library/{domain}/{slug}.md` 저장

## library 파일 형식

```markdown
---
title: {제목}
domain: {product|engineering|operations|growth|business|ai-automation}
created_via: retro
---

## Context

{왜 이 작업을 했는지, 배경}

## Decision

{핵심 결정 사항}

## Outcome

{결과물, 만든 것}

## Lessons

{나중에 참고할 교훈 - 선택적}
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
- `created_via: retro`로 사후 기록임을 표시
- slug는 영문 kebab-case

## 예시 시나리오

```
사용자: 방금 improve-plugin 스킬을 만들었는데, library에 기록해줘
→ /gemify:retro 활성화
→ 질문을 통해 핵심 결정 추출
→ library/ai-automation/improve-plugin-workflow.md 저장
```
