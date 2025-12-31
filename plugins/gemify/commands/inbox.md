---
name: inbox
description: 내 생각을 inbox/thoughts/에 빠르게 저장
allowed-tools: Read, Write, Edit
argument-hint: [내용]
---

# /gemify:inbox - 원석 포착

inbox 스킬을 사용하여 내 생각을 inbox/thoughts/에 저장한다.

## 사용법

```
/gemify:inbox                     # 직전 대화 내용 저장
/gemify:inbox 이런 생각이 들었어    # 입력 내용 저장
```

## 동작

1. $ARGUMENTS가 있으면 해당 내용 저장
2. 없으면 직전 사용자 발화 내용 저장
3. 최소한의 정돈 후 inbox/thoughts/에 저장
4. "/gemify:draft로 다듬을 수 있어요" 안내

## inbox 구조

- **inbox/thoughts/**: 내 생각 (원석) - 이 명령어
- **inbox/materials/**: 외부 재료 - /gemify:import

## 다음 단계

포착된 원석은 `/gemify:draft`로 대화를 통해 다듬을 수 있습니다.
