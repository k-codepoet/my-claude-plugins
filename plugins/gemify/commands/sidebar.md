---
description: 본 작업 중 떠오른 것을 옆에 빼두기 (material + thought 쌍으로 저장)
allowed-tools: Read, Write, Edit
---

# /gemify:sidebar - 본론 아닌 걸 옆으로 빼두기

**반드시 `skills/sidebar/SKILL.md`를 먼저 읽고 그 지침대로 동작하세요.**

## 사용법

```
/gemify:sidebar                  # 직전 대화에서 쌍으로 추출
```

## 동작

1. 직전 대화 맥락 분석
2. Material 추출 → `inbox/materials/YYYY-MM-DD-{slug}.md`
   - 의사결정 과정, 논의 내용, 외부 정보
3. Thought 추출 → `inbox/thoughts/YYYY-MM-DD-{slug}.md`
   - 핵심 인사이트, 내 결론
4. thought의 `references`에 material 경로 연결
5. 두 파일 저장 완료 안내

## 언제 사용하나

- 본 작업 중 "이건 나중에" 싶은 게 떠올랐을 때
- `/gemify:import` + `/gemify:inbox`를 따로 쓰기 번거로울 때
- 대화에서 맥락(material)과 인사이트(thought)를 분리 저장하고 싶을 때

## 다음 단계

저장된 쌍은 `/gemify:draft`에서 함께 다듬을 수 있습니다.
