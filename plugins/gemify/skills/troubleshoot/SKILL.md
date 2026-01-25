---
name: troubleshoot
description: 버그/문제 분석 및 가설 도출. "문제 분석", "버그 원인", "왜 안되지", "에러 분석" 등 요청 시 활성화. bugfix 스킬과 연계.
---

# Troubleshoot Skill

버그나 문제 상황을 분석하고 가설을 도출합니다. `bugfix` 스킬 전 단계로 사용하거나 독립적으로 분석만 수행할 수 있습니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 워크플로우

```
문제 발생
    │
    ▼
/gemify:troubleshoot
    │
    ├─ 증상 수집 (에러 메시지, 로그, 재현 단계)
    │
    ├─ 관련 코드/설정 탐색
    │
    ├─ 가설 도출 (우선순위 나열)
    │
    └─ inbox/materials/에 분석 기록 저장
    │
    ▼
/gemify:bugfix (선택적 연계)
```

## 동작

### 1. 증상 수집

대화를 통해 파악:
- **에러 메시지**: 정확한 에러 텍스트
- **재현 단계**: 어떤 상황에서 발생하는지
- **발생 조건**: 항상? 특정 조건에서만?
- **최근 변경**: 언제부터? 뭘 바꿨는지?

### 2. 탐색 및 분석

- 관련 코드 위치 파악
- 로그/스택트레이스 분석
- 설정 파일 확인
- 의존성 버전 확인

### 3. 가설 도출

우선순위를 매겨 가설 나열:

```markdown
### 가설 (우선순위순)

1. **[HIGH] 가설 1**
   - 근거: 왜 이 가설을 세웠는지
   - 검증 방법: 어떻게 확인할지

2. **[MEDIUM] 가설 2**
   - 근거: ...
   - 검증 방법: ...

3. **[LOW] 가설 3**
   - 근거: ...
   - 검증 방법: ...
```

### 4. 분석 기록 저장

`inbox/materials/`에 troubleshoot 기록 저장:

```
inbox/materials/YYYY-MM-DD-troubleshoot-{slug}.md
```

형식:
```yaml
---
type: troubleshoot
project: {프로젝트명}
symptom: "{증상 요약}"
created: "YYYY-MM-DD"
status: analyzing|resolved|escalated
---

## Symptom
{증상 상세}

## Analysis
{분석 내용}

## Hypotheses
{가설 목록}

## Next Steps
{다음 단계}
```

### 5. bugfix 연계

분석 완료 후:

```
분석이 완료되었습니다.

다음 단계:
1. 버그 수정 문서 작성 → /gemify:bugfix
2. 분석만 저장하고 종료

선택하세요 (1/2):
```

## 규칙

- **코드 수정 금지**: 분석 및 기록만 담당
- 가설은 검증 가능해야 함 (구체적인 검증 방법 필수)
- 불확실한 경우 여러 가설을 나열
- 분석 기록은 나중에 참조할 수 있도록 inbox에 저장
