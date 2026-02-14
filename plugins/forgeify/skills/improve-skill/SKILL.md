---
name: improve-skill
description: 스킬 개선. "스킬 개선", "skill 수정", "improve skill", "SKILL.md 업데이트" 등 요청 시 활성화.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: "<name> [improvement-doc]"
---

# improve-skill Skill

## 개요

gemify에서 생성된 개선 문서를 읽고, 해당 스킬을 수정합니다.

## 단방향 흐름 원칙

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── 개선 문서 생성 ──────▶ 개선 문서 실행
```

## 인자

```
/forgeify:improve-skill <name> [improvement-doc]

- name: 스킬 이름
- improvement-doc: 개선 문서 경로 (기본: ~/.gemify/views/by-improvement/에서 탐색)
```

## 워크플로우

### 1단계: 개선 문서 파싱

개선 문서를 읽고 다음 정보를 추출:
- **frontmatter**: plugin, problem, solution, artifact
- **body**: Why, What, Scope, AC

### 2단계: 대상 스킬 확인

1. `artifact` 필드가 있으면 해당 경로 사용
2. 현재 디렉토리에서 `skills/{name}/SKILL.md` 탐색
3. 못 찾으면 사용자에게 경로 요청

### 3단계: 현재 상태 분석

대상 스킬을 읽고 분석:
- frontmatter 필드 (name, description, allowed-tools 등)
- 본문 내용 (워크플로우, 규칙)
- references/ 폴더 존재 여부
- 대응 커맨드 존재 여부

### 4단계: 개선 계획 수립

What 섹션과 AC를 기반으로 변경 계획:

```
## 개선 계획: {name} 스킬

### 문제
{problem}

### 해결책
{solution}

### 변경 사항
1. [MODIFY] skills/{name}/SKILL.md
   - frontmatter 변경: {details}
   - 워크플로우 변경: {details}
2. [CREATE/MODIFY] skills/{name}/references/{file} (필요시)

진행하시겠습니까? [Y/N]
```

### 5단계: 변경 적용

승인 후:
1. SKILL.md 수정
2. references/ 파일 생성/수정 (필요시)
3. 대응 커맨드도 수정 필요시 → `forgeify:improve-command` 제안

### 6단계: 검증

skill-guide 스킬의 규격에 맞는지 검증:
- name = 디렉토리명 일치
- description 품질 ("무엇을 + 언제" 형식)
- Progressive Disclosure (본문 <5000 토큰)

### 7단계: 완료 메시지

```
✅ 스킬 개선 완료

파일: {path}
변경: {summary}

대응 커맨드도 수정할까요? [Y/n]
```

## 규칙

1. **name = 디렉토리명**: name 필드와 디렉토리명 일치 필수
2. **SKILL.md 대문자**: 파일명은 반드시 대문자
3. **Progressive Disclosure**: 본문 5000 토큰 이하, 상세 내용은 references/로

## 참조

- skill-guide 스킬의 상세 규격 참조
- improve-plugin 스킬의 워크플로우 패턴 참조
