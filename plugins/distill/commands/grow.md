---
name: grow
description: seed와 materials를 합쳐 대화로 확장 (branch/ripen 모드)
allowed-tools: Read, Write, Edit
argument-hint: [파일/아이디어]
---

# /distill:grow - 생각 확장 커맨드

grow 스킬로 아이디어를 대화로 확장한다.

## 사용법

```
/distill:grow                        # growing/ 목록 또는 새 시작
/distill:grow "이런 생각이 있어..."    # 새 씨앗으로 시작
/distill:grow growing/my-idea.md     # 기존 이어가기
/distill:grow seed/my-seed.md        # seed에서 시작
/distill:grow materials/article.md   # material과 함께 시작
```

## 입력 소스

```
seed/      ← 내 생각의 씨앗
materials/ ← 외부 재료 (기사, 문서, 대화 등)
    ↓
growing/   ← 둘이 만나서 해체 → 재조립 → 응축
```

## 동작

1. $ARGUMENTS 없으면 → growing/ 폴더의 파일 목록 표시 후 선택 또는 새 시작
2. 따옴표로 감싼 문자열이면 → 새 씨앗으로 growing/ 파일 생성 후 대화 시작
3. 파일 경로면 → 해당 파일 읽고 이어가기 (seed/, materials/, growing/ 모두 가능)

## 두 가지 모드

```
/distill:grow
├── branch - 가지치기, 넓게 뻗기 (기본)
└── ripen  - 익히기, 응축 → digest 준비
```

- **branch**: 넓게 탐색 ("연결되는 건?", "다른 관점에서?")
- **ripen**: 깊이 응축 ("왜 중요해?", "핵심만 남기면?")

**ripen 트리거:** "익혀봐", "좀 더 익히자", "핵심이 뭐야"

## revision (스냅샷)

방향 전환(pivot) 시 자동으로 스냅샷 생성:
- `.history/{slug}/` 폴더에 저장
- frontmatter의 `history` 배열에 기록

## 종료 조건

1. 사용자 선언: "digest 해줘", "정리하자", "이 정도면 됐어"
2. Claude 제안 수락: 성숙도 감지 후 "digest 해볼까?" → 사용자 OK
3. 세션 종료: 자동 저장, 다음에 `/distill:grow 파일명`으로 이어가기

## digest 전환

```
사용자: "digest 해줘" 또는 "정리하자"
→ Claude: /distill:digest 워크플로우 호출 (growing → corpus 직접 처리)
```
