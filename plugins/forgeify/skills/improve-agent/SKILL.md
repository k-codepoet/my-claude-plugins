---
name: improve-agent
description: 에이전트 개선. "에이전트 개선", "agent 수정", "improve agent" 등 요청 시 활성화.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "<name> [improvement-doc]"
---

# improve-agent Skill

## 개요

gemify에서 생성된 개선 문서를 읽고, 해당 에이전트를 수정합니다.

## 단방향 흐름 원칙

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── 개선 문서 생성 ──────▶ 개선 문서 실행
```

## 인자

```
/forgeify:improve-agent <name> [improvement-doc]

- name: 에이전트 이름
- improvement-doc: 개선 문서 경로 (기본: ~/.gemify/views/by-improvement/에서 탐색)
```

## 워크플로우

### 1단계: 개선 문서 파싱

개선 문서를 읽고 다음 정보를 추출:
- **frontmatter**: plugin, problem, solution, artifact
- **body**: Why, What, Scope, AC

### 2단계: 대상 에이전트 확인

1. `artifact` 필드가 있으면 해당 경로 사용
2. 현재 디렉토리에서 `agents/{name}.md` 탐색
3. 못 찾으면 사용자에게 경로 요청

### 3단계: 현재 상태 분석

대상 에이전트를 읽고 분석:
- frontmatter 필드 (name, description, tools, model)
- 본문 내용 (지시사항, 체크리스트)
- `<example>` 블록 존재 및 품질

### 4단계: 개선 계획 수립

What 섹션과 AC를 기반으로 변경 계획:

```
## 개선 계획: {name} 에이전트

### 문제
{problem}

### 해결책
{solution}

### 변경 사항
1. [MODIFY] agents/{name}.md
   - frontmatter 변경: {details}
   - 지시사항 변경: {details}
   - example 블록 추가/수정: {details}

진행하시겠습니까? [Y/N]
```

### 5단계: 변경 적용

승인 후:
1. 에이전트 파일 수정
2. plugin.json의 agents 필드 확인

### 6단계: 검증

agent-guide 스킬의 규격에 맞는지 검증:
- name, description 필수
- `<example>` 블록 포함 필수
- tools 필드 형식

### 7단계: 완료 메시지

```
✅ 에이전트 개선 완료

파일: {path}
변경: {summary}
```

## 규칙

1. **example 블록 필수**: 에이전트는 반드시 `<example>` 블록 포함
2. **description 품질**: 언제 사용할지 명확히 기술
3. **최소 권한 원칙**: 필요한 도구만 `tools`에 명시

## 참조

- agent-guide 스킬의 상세 규격 참조
- improve-plugin 스킬의 워크플로우 패턴 참조
