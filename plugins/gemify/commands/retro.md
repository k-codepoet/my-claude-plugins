---
description: 이미 완료된 작업을 역방향으로 library에 기록 (사후처리)
allowed-tools: Read, Write, Edit
---

# /gemify:retro - 사후처리 (역방향 기록)

retro 스킬을 사용하여 이미 완료된 작업을 library에 기록한다.

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
2. 소크라테스식 질문 (하나씩)
   - 뭘/왜 만들었는지
   - 핵심 결정 사항
   - 교훈
   - domain 분류
3. library 문서 초안 제시
4. 컨펌 후 `library/{domain}/{slug}.md` 저장

## 특징

- `created_via: retro`로 사후 기록임을 표시
- drafts를 건너뛰는 단축 경로
