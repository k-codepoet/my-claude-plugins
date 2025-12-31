---
description: inbox의 원석을 대화로 다듬기 (facet/polish 모드)
allowed-tools: Read, Write, Edit
argument-hint: [파일/아이디어]
---

# /gemify:draft - 원석 다듬기 커맨드

draft 스킬로 원석을 대화로 다듬는다.

## 사용법

```
/gemify:draft                            # drafts/ 목록 또는 새 시작
/gemify:draft "이런 생각이 있어..."        # 새 원석으로 시작
/gemify:draft drafts/my-idea.md          # 기존 이어가기
/gemify:draft inbox/thoughts/my-idea.md  # inbox에서 시작
/gemify:draft inbox/materials/article.md # material과 함께 시작
```

## 입력 소스

```
inbox/thoughts/   ← 내 생각 (원석)
inbox/materials/  ← 외부 재료 (기사, 문서, 대화 등)
       ↓
drafts/           ← 둘이 만나서 해체 → 재조립 → 연마
```

## 동작

1. $ARGUMENTS 없으면 → drafts/ 폴더의 파일 목록 표시 후 선택 또는 새 시작
2. 따옴표로 감싼 문자열이면 → 새 원석으로 drafts/ 파일 생성 후 대화 시작
3. 파일 경로면 → 해당 파일 읽고 이어가기 (inbox/, drafts/ 모두 가능)

## 두 가지 모드

```
/gemify:draft
├── facet  - 여러 면 탐색, 넓게 (기본)
└── polish - 깊이 연마 → library 준비
```

- **facet**: 넓게 탐색 ("다른 면에서 보면?", "연결되는 건?")
- **polish**: 깊이 연마 ("왜 중요해?", "핵심만 남기면?")

**polish 트리거:** "연마해봐", "좀 더 다듬자", "핵심이 뭐야"

## revision (스냅샷)

방향 전환(pivot) 시 자동으로 스냅샷 생성:
- `.history/{slug}/` 폴더에 저장
- frontmatter의 `history` 배열에 기록

## 종료 조건

1. 사용자 선언: "library 해줘", "정리하자", "이 정도면 됐어"
2. Claude 제안 수락: 완성도 감지 후 "library 해볼까?" → 사용자 OK
3. 세션 종료: 자동 저장, 다음에 `/gemify:draft 파일명`으로 이어가기

## library 전환

```
사용자: "library 해줘" 또는 "정리하자"
→ Claude: /gemify:library 워크플로우 호출 (drafts → library 직접 처리)
```
