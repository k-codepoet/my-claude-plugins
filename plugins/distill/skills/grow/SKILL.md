---
name: grow
description: seed와 materials를 대화로 확장하여 growing/에 기록. branch(넓게)/ripen(익히기) 모드로 동작. 익으면 /distill:digest 전환 제안.
---

# Grow Skill

seed + materials를 **대화를 통해 확장**합니다.

## 입력 소스

```
seed/      ← 내 생각의 씨앗
materials/ ← 외부 재료
    ↓
growing/   ← 해체 → 재조립 → 응축
```

## 두 가지 모드

```
/distill:grow
├── branch - 가지치기, 넓게 뻗기 (BFS)
└── ripen  - 익히기, 응축 (DFS) → digest 준비
```

### branch (기본)

넓게 탐색하고 연결점을 찾는 모드.

**질문 스타일:**
- "연결되는 건?"
- "다른 관점에서 보면?"
- "비슷한 사례가 있어?"

### ripen

깊이 파고들어 핵심을 응축하는 모드.

**트리거:** "익혀봐", "좀 더 익히자", "핵심이 뭐야"

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

모든 대화는 `growing/{slug}.md`에 축적. (상세: `references/growing-format.md`)

### 3. 소스 추적

seed/materials 사용 시:
- 해당 파일 `status` → `used`
- 해당 파일 `used_in` → growing 경로 기록

### 4. revision (스냅샷)

**pivot(방향 전환) 시 revision 증가:**
- branch 중 → 다른 방향 branch
- branch → ripen 전환
- ripen 중 → 다른 방향 ripen

스냅샷은 `.history/{slug}/` 폴더에 저장.

### 5. 성숙도 감지

다음 조건 시 digest 전환 제안:
- turns >= 5
- Open Questions 대부분 해결
- 같은 포인트 반복

## 파일 형식 (growing/)

```markdown
---
title: "{제목}"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD HH:MM"
turns: 0
revision: 1
status: growing
sources: []
history:
  - rev: 1
    mode: branch
    date: YYYY-MM-DD
    summary: "요약"
    file: .history/{slug}/01-branch-YYYY-MM-DD.md
---

## Current State
{현재까지 종합}

---

## Open Questions
- [ ]
```

## 히스토리 구조

```
growing/
├── {slug}.md              # 현재 상태 (압축)
└── .history/{slug}/
    ├── 01-branch-2024-12-31.md
    └── 02-ripen-2024-12-31.md
```

**스냅샷 파일 형식:**
```markdown
---
session: 1
mode: branch
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
| 시작 | growing/ 확인, 진행 중 목록 표시 |
| 대화 | 매 턴 업데이트, turns 증가, 모드 체크 |
| pivot | revision++, 스냅샷 생성 |
| 종료 | 상태 요약, "/distill:grow {파일명}" 안내 |

## 규칙

- 질문은 **하나씩 순차적으로**
- **강요 안 함** - digest는 사용자 수락 시만
- 이전 세션 맥락 이어감
- `_template.md` 제외

## References

상세 형식과 예시는 `references/` 폴더 참조:
- `references/growing-format.md` - growing 파일 형식, 히스토리 구조
- `references/example-growing.md` - 실제 growing 파일 + 스냅샷 예시
