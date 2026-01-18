---
description: 버그/문제 분석 및 가설 도출. bugfix 스킬과 연계 가능.
allowed-tools: Read, Write, Glob, Grep, Bash
argument-hint: [버그 설명 또는 에러 메시지]
---

# /gemify:troubleshoot - 문제 분석 및 가설 도출

**반드시 `skills/troubleshoot/SKILL.md`를 먼저 읽고 그 지침대로 동작하세요.**

## 사용법

```
/gemify:troubleshoot                           # 대화형으로 증상 수집
/gemify:troubleshoot "에러 메시지나 버그 설명"  # 직접 입력
```

## 언제 사용하나

- 버그 원인을 모를 때
- 에러 메시지 분석이 필요할 때
- 여러 가설 중 검증 순서를 정해야 할 때

## 워크플로우

```
문제 발생
    │
    ▼
/gemify:troubleshoot
    │
    ├─ 증상 수집 (에러 메시지, 로그, 재현 단계)
    ├─ 관련 코드/설정 탐색
    ├─ 가설 도출 (우선순위 나열)
    └─ inbox/materials/에 분석 기록 저장
    │
    ▼
/gemify:bugfix (선택적 연계)
```

## 동작

1. 증상 수집 (에러 메시지, 재현 단계, 발생 조건)
2. 관련 코드 탐색 및 분석
3. 가설 도출 (우선순위순)
4. `inbox/materials/YYYY-MM-DD-troubleshoot-{slug}.md`에 저장
5. bugfix 연계 여부 제안

## 출력 형식

```markdown
### 가설 (우선순위순)

1. **[HIGH] 가설 1**
   - 근거: 왜 이 가설을 세웠는지
   - 검증 방법: 어떻게 확인할지

2. **[MEDIUM] 가설 2**
   - 근거: ...
   - 검증 방법: ...
```

## 규칙

- **코드 수정 금지**: 분석 및 기록만 담당
- 가설은 검증 가능해야 함 (구체적인 검증 방법 필수)
