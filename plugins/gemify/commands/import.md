---
description: 외부 재료(기사, 문서, 대화 등)를 inbox/materials/에 저장
allowed-tools: Read, Write, Edit, WebFetch
argument-hint: [URL/내용]
---

# /gemify:import - 외부 재료 가져오기

**반드시 `skills/import/SKILL.md`를 먼저 읽고 그 지침대로 동작하세요.**

## 사용법

```
/gemify:import                              # 직전 대화에서 외부 콘텐츠 추출
/gemify:import https://example.com/article  # URL에서 콘텐츠 가져오기
/gemify:import "복사한 텍스트 내용"            # 텍스트 직접 저장
```

## 동작

1. $ARGUMENTS가 URL이면 → WebFetch로 콘텐츠 가져오기
2. $ARGUMENTS가 텍스트면 → 해당 내용 저장
3. 없으면 → 직전 대화에서 외부 콘텐츠 추출
4. type 자동 감지 (article, document, conversation, snippet)
5. inbox/materials/에 저장
6. "/gemify:draft로 내 생각과 함께 다듬을 수 있어요" 안내

## inbox 구조

- **inbox/thoughts/**: 내 생각 (원석) - /gemify:inbox
- **inbox/materials/**: 외부 재료 - 이 명령어

## 다음 단계

가져온 재료는 `/gemify:draft`에서 내 생각(thoughts)과 함께 다듬을 수 있습니다.
