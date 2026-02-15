---
description: 세션 마무리 스킬. "마무리", "wrapup", "세션 끝", "놓친 거 있니" 등 세션 종료 요청 시 활성화. HITL 체크 후 세션 리포트 생성.
allowed-tools: Read, Write, Edit, Glob
---

# Wrapup Skill (세션 마무리)

세션 종료를 **HITL(Human-in-the-Loop) 체크** 후 **세션 리포트**로 기록합니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 언제 사용하나

- 세션 마무리할 때
- "놓친 거 있니?" 확인이 필요할 때
- 작업 내용을 리포트로 남기고 싶을 때

## 동작 흐름

```
1. 놓친 것 체크 (interactive, HITL)
   ├─ 다룬 파일, 상태, 열린 질문 확인
   ├─ 누락 있으면 사용자가 추가 지시
   └─ "이 정도면 됐다" 승인
        ↓
2. 리포트 생성 (sessions/에 저장)
   ├─ Summary (이번 세션에서 한 일)
   ├─ Outputs (생성/수정된 파일)
   ├─ Stashed for Next (inbox에 챙겨둔 것)
   └─ Next Actions (파생 TODO, 우선순위)
        ↓
3. 자동 동기화 (sync push)
   ├─ git remote 설정 확인
   ├─ remote 있음 → git add, commit, push 실행
   └─ remote 없음 → 스킵 (로컬 저장만 완료)
```

## HITL 체크 질문

1. "이번 세션에서 다룬 내용 요약해드릴까요?"
2. "혹시 빠뜨린 것이나 추가로 하고 싶은 작업이 있나요?"
3. "이 정도면 마무리해도 될까요?"

## 저장 위치

```
sessions/
└── YYYYMMDD-HHMMSS-{slug}.md
```

- gemify 지식 파이프라인 바깥의 **운영 계층**
- 파일명 형식: `{YYYYMMDD}-{HHMMSS}-{slug}.md` (시간순 정렬 가능)
- slug: 세션 주제를 나타내는 kebab-case 식별자 (예: `gemify-wrapup-impl`)

## 리포트 템플릿

```markdown
---
title: Session Wrapup
date: YYYY-MM-DD
created_at: "YYYY-MM-DDTHH:MM:SS+09:00"
slug: "{slug}"
---

## Summary

{세션에서 수행한 작업 한두 문장 요약}

## Outputs

| 파일 | 설명 |
|------|------|
| `{경로}` | {설명} |

## Stashed for Next

{다음에 처리할 것으로 옆에 빼둔 항목. 없으면 "없음"}

## Next Actions

1. {다음 할 일}
```

## 세션 범위

- **기본값**: 대화 전체 (Claude Code 세션)
- **사용자 지정**: 리포팅 요청 시 "어디서부터 어디까지?" 확인

## 핵심 구분

inbox 항목 = "미완료"가 아니라 **"의도적으로 챙겨둔 것"**
- Stashed for Next 섹션에서 이 의도를 명확히 표현

## 자동 동기화 (3단계)

리포트 저장 후 자동으로 remote에 push합니다.

### 동작 조건

```bash
# 현재 도메인 경로에서 실행
cd {domain_path}
git remote -v  # remote 설정 확인
```

| 상태 | 동작 |
|------|------|
| remote 있음 | git add → commit → push 실행 |
| remote 없음 | 스킵 (로컬 저장만 완료) |

### 실행 명령

```bash
cd {domain_path}  # scope 스킬에서 결정된 경로
git add .
git commit -m "session: {slug}"
git push origin main
```

### 결과 메시지

| 상태 | 메시지 |
|------|--------|
| 성공 | ✅ 세션 리포트 저장 및 동기화 완료 |
| 스킵 | 📝 세션 리포트 저장 완료 (remote 미설정) |
| 실패 | ⚠️ 세션 리포트 저장 완료, 동기화 실패: {에러} |

## 규칙

- **HITL 체크 필수**: 놓친 것 확인 없이 리포트 생성 안 함
- **컨펌 없이 저장 안 함**
- slug는 세션 주제를 요약한 kebab-case
- **리포트 저장 후 자동 sync**: remote 설정 시 자동 push

## 예시 시나리오

```
사용자: 오늘 작업 마무리하자
→ /gemify:wrapup 활성화
→ HITL 체크 (놓친 것 확인)
→ 사용자 승인
→ sessions/20260103-143052-gemify-wrapup-impl.md 저장
→ git add, commit, push (자동)
→ "✅ 세션 리포트 저장 및 동기화 완료"
```

## 마이그레이션 스크립트

기존 `YYYY-MM-DD-{slug}.md` 형식 파일을 새 형식으로 변환:

```bash
# dry run (미리보기)
~/.claude/plugins/*/gemify/*/scripts/migrate-sessions.sh --dry-run

# 실제 마이그레이션
~/.claude/plugins/*/gemify/*/scripts/migrate-sessions.sh
```
