---
name: improve-command
description: 커맨드 개선. "커맨드 개선", "command 수정", "improve command" 등 요청 시 활성화.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "<name> [improvement-doc]"
---

# improve-command Skill

## 개요

gemify에서 생성된 개선 문서를 읽고, 해당 커맨드를 수정합니다.

## 단방향 흐름 원칙

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── 개선 문서 생성 ──────▶ 개선 문서 실행
```

## 인자

```
/forgeify:improve-command <name> [improvement-doc]

- name: 커맨드 이름
- improvement-doc: 개선 문서 경로 (기본: ~/.gemify/views/by-improvement/에서 탐색)
```

## 워크플로우

### 1단계: 개선 문서 파싱

개선 문서를 읽고 다음 정보를 추출:
- **frontmatter**: plugin, problem, solution, artifact
- **body**: Why, What, Scope, AC

### 2단계: 대상 커맨드 확인

1. `artifact` 필드가 있으면 해당 경로 사용
2. 현재 디렉토리에서 `commands/{name}.md` 탐색
3. 못 찾으면 사용자에게 경로 요청

### 3단계: 현재 상태 분석

대상 커맨드 파일을 읽고 분석:
- frontmatter 필드 (description, allowed-tools, argument-hint)
- 본문 내용
- 대응 스킬 존재 여부

### 4단계: 개선 계획 수립

What 섹션과 AC를 기반으로 변경 계획:

```
## 개선 계획: {name} 커맨드

### 문제
{problem}

### 해결책
{solution}

### 변경 사항
1. [MODIFY] commands/{name}.md
   - frontmatter 변경: {details}
   - 본문 변경: {details}

진행하시겠습니까? [Y/N]
```

### 5단계: 변경 적용

승인 후:
1. 커맨드 파일 수정
2. 대응 스킬도 수정 필요시 → `forgeify:improve-skill` 제안

### 6단계: 검증

command-guide 스킬의 규격에 맞는지 검증:
- description 필수
- allowed-tools 형식
- argument-hint 형식

### 7단계: 완료 메시지

```
✅ 커맨드 개선 완료

파일: {path}
변경: {summary}

대응 스킬도 수정할까요? [Y/n]
```

## 규칙

1. **Command-Skill 1:1 원칙**: 커맨드 수정 시 대응 스킬도 확인
2. **description 필수**: 빈 description 허용 안 함
3. **스킬 Read 지시 유지**: 커맨드 본문에 스킬 Read 지시 포함

## 참조

- command-guide 스킬의 상세 규격 참조
- improve-plugin 스킬의 워크플로우 패턴 참조
