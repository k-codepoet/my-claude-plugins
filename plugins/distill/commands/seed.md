---
name: seed
description: 내 생각의 씨앗을 seed/에 빠르게 저장
allowed-tools: Read, Write, Edit
argument-hint: [내용]
---

# /distill:seed - 씨앗 저장

seed 스킬을 사용하여 내 생각의 씨앗을 seed/에 저장한다.

## 사용법

```
/distill:seed                     # 직전 대화 내용 저장
/distill:seed 이런 생각이 들었어    # 입력 내용 저장
```

## 동작

1. $ARGUMENTS가 있으면 해당 내용 저장
2. 없으면 직전 사용자 발화 내용 저장
3. 최소한의 정돈 후 seed/에 저장
4. "/distill:grow로 키울 수 있어요" 안내

## seed vs materials

- **seed/**: 내 생각의 씨앗 (이 명령어)
- **materials/**: 외부 재료 (/import - 나중에)

## 다음 단계

저장된 씨앗은 `/distill:grow`로 대화를 통해 확장할 수 있습니다.
