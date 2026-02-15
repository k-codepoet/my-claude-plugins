---
description: 훅 개선. "훅 개선", "hook 수정", "improve hook", "hooks.json 업데이트" 등 요청 시 활성화.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "<event-type> [improvement-doc]"
---

# improve-hook Skill

## 개요

gemify에서 생성된 개선 문서를 읽고, 해당 훅을 수정합니다.

## 단방향 흐름 원칙

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── 개선 문서 생성 ──────▶ 개선 문서 실행
```

## 인자

```
/forgeify:improve-hook <event-type> [improvement-doc]

- event-type: PreToolUse, PostToolUse, Stop, SessionStart, UserPromptSubmit
- improvement-doc: 개선 문서 경로 (기본: ~/.gemify/views/by-improvement/에서 탐색)
```

## 워크플로우

### 1단계: 개선 문서 파싱

개선 문서를 읽고 다음 정보를 추출:
- **frontmatter**: plugin, problem, solution, artifact
- **body**: Why, What, Scope, AC

### 2단계: 대상 훅 확인

1. `artifact` 필드가 있으면 해당 경로 사용
2. 현재 디렉토리에서 `hooks/hooks.json` 탐색
3. 해당 event-type의 훅 존재 확인
4. 못 찾으면 사용자에게 경로 요청

### 3단계: 현재 상태 분석

대상 훅을 읽고 분석:
- hooks.json 구조
- 해당 event-type의 설정
- 관련 스크립트 파일

### 4단계: 개선 계획 수립

What 섹션과 AC를 기반으로 변경 계획:

```
## 개선 계획: {event-type} 훅

### 문제
{problem}

### 해결책
{solution}

### 변경 사항
1. [MODIFY] hooks/hooks.json
   - {event-type} 설정 변경: {details}
2. [MODIFY] hooks/scripts/{script}.sh (해당시)
   - 스크립트 로직 변경: {details}

진행하시겠습니까? [Y/N]
```

### 5단계: 변경 적용

승인 후:
1. hooks.json 수정
2. 스크립트 파일 수정 (필요시)
3. 스크립트 실행 권한 확인

### 6단계: 검증

hook-guide 스킬의 규격에 맞는지 검증:
- type: command 만 사용 (prompt 미지원)
- ${CLAUDE_PLUGIN_ROOT} 사용
- 매처 대소문자 정확성

### 7단계: 완료 메시지

```
✅ 훅 개선 완료

설정: {hooks.json path}
스크립트: {script path}
변경: {summary}

디버깅: claude --debug hooks
```

## 규칙

1. **type: command 만 사용**: 플러그인에서 type: "prompt"는 무시됨
2. **CLAUDE_PLUGIN_ROOT 사용**: 스크립트 경로에 필수
3. **exit 코드**: 0=성공, 2=차단, 그 외=비차단 오류

## 참조

- hook-guide 스킬의 상세 규격 참조
- improve-plugin 스킬의 워크플로우 패턴 참조
