---
description: 이미 완료된 작업을 역방향으로 library에 기록 (사후처리)
allowed-tools: Read, Write, Edit
---

# /gemify:retro - 사후처리 (역방향 기록)

**반드시 `skills/retro/SKILL.md`를 먼저 읽고 그 지침대로 동작하세요.**

## 사용법

```
/gemify:retro                  # 직전 대화에서 완료된 작업 추출하여 library로
```

## 언제 사용하나

- 아이디어 → 바로 구현해버린 경우
- inbox → drafts → library 흐름을 건너뛴 경우
- 의사결정 과정을 사후에 library에 남기고 싶을 때

## 일반 vs Retro 흐름

```
[일반]  inbox → drafts → library → 구현
[Retro] 아이디어 → 구현(완료) → /gemify:retro → library
```

## 동작

1. 대화 맥락에서 완료된 작업 파악
2. **밀도 평가**: 대화 내용이 어느 수준인지 판단
3. 수준에 맞는 소크라테스식 질문 (하나씩)
   - inbox 수준 → inbox에 저장 후 나중에 다듬기
   - draft 수준 → 핵심 추출, 다듬기
   - library 수준 → type 분류 (principle/decision/insight/how-to/spec/workflow)
4. **역방향 추적**: 빠진 단계가 있다면 채우기 제안
5. 컨펌 후 해당 단계에 저장 (`library/{type}s/{slug}.md`)

## 특징

- `created_via: retro`로 사후 기록임을 표시
- 밀도에 따라 적절한 단계 제안 (무조건 library 직행 아님)
