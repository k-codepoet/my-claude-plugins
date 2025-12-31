---
name: draft
description: inbox의 원석을 대화로 다듬어 drafts/에 기록. facet(넓게)/polish(연마) 모드로 동작. 완성되면 /gemify:library 전환 제안.
---

# Draft Skill

inbox의 원석을 **대화를 통해 다듬습니다**.

## 입력 소스

```
inbox/thoughts/   ← 내 생각 (원석)
inbox/materials/  ← 외부 재료
       ↓
drafts/           ← 해체 → 재조립 → 연마
```

## 두 가지 모드

```
/gemify:draft
├── facet  - 여러 면 탐색, 넓게 (BFS)
└── polish - 깊이 연마, 광택 (DFS) → library 준비
```

### facet (기본)

여러 면에서 탐색하고 연결점을 찾는 모드.

**질문 스타일:**
- "다른 면에서 보면?"
- "연결되는 건?"
- "비슷한 사례가 있어?"

### polish

깊이 파고들어 핵심을 연마하는 모드.

**트리거:** "연마해봐", "좀 더 다듬자", "핵심이 뭐야"

**질문 스타일:**
- "왜 이게 중요해?"
- "한 문장으로 줄이면?"
- "진짜 핵심만 남기면?"

## 핵심 행동

### 1. 대화 파트너

**도전**: "왜 필요해?", "반대로 생각하면?"
**확장**: "연결되는 건?", "극단적으로 밀면?"
**구체화**: "예를 들면?", "첫 번째 단계가 뭐야?"

### 2. 누적 기록

모든 대화는 `drafts/{slug}.md`에 축적. (상세: `references/drafts-format.md`)

### 3. 소스 추적

inbox 파일 사용 시:
- 해당 파일 `status` → `used`
- 해당 파일 `used_in` → drafts 경로 기록

### 4. revision (스냅샷)

**pivot(방향 전환) 시 revision 증가:**
- facet 중 → 다른 방향 facet
- facet → polish 전환
- polish 중 → 다른 방향 polish

스냅샷은 `.history/{slug}/` 폴더에 저장.

### 5. 완성도 감지

다음 조건 시 library 전환 제안:
- turns >= 5
- Open Questions 대부분 해결
- 같은 포인트 반복

## 파일 형식 (drafts/)

```markdown
---
title: "{제목}"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD HH:MM"
turns: 0
revision: 1
status: developing
sources: []
history:
  - rev: 1
    mode: facet
    date: YYYY-MM-DD
    summary: "요약"
    file: .history/{slug}/01-facet-YYYY-MM-DD.md
---

## Current State
{현재까지 종합}

---

## Open Questions
- [ ]
```

## 히스토리 구조

```
drafts/
├── {slug}.md              # 현재 상태 (압축)
└── .history/{slug}/
    ├── 01-facet-2024-12-31.md
    └── 02-polish-2024-12-31.md
```

**스냅샷 파일 형식:**
```markdown
---
session: 1
mode: facet
date: YYYY-MM-DD
summary: "요약"
---

## 결정사항
{확정된 것들}

## 다음 작업
- [ ] ...
```

## 세션 동작

| 시점 | 동작 |
|------|------|
| 시작 | drafts/ 확인, 진행 중 목록 표시 |
| 대화 | 매 턴 업데이트, turns 증가, 모드 체크 |
| pivot | revision++, 스냅샷 생성 |
| 종료 | 상태 요약, "/gemify:draft {파일명}" 안내 |

## 규칙

- 질문은 **하나씩 순차적으로**
- **강요 안 함** - library는 사용자 수락 시만
- 이전 세션 맥락 이어감
- `_template.md` 제외

## References

상세 형식과 예시는 `references/` 폴더 참조:
- `references/drafts-format.md` - drafts 파일 형식, 히스토리 구조
- `references/example-drafts.md` - 실제 drafts 파일 + 스냅샷 예시
