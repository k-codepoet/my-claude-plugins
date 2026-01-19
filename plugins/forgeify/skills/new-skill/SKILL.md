---
name: new-skill
description: 새 스킬 생성. "스킬 만들기", "new skill", "SKILL.md 추가" 등 요청 시 활성화.
---

# new-skill Skill

## 개요

Claude Code 플러그인에 새 스킬(SKILL.md)을 생성합니다.

## 인자

```
/forgeify:new-skill <name> [plugin-path]

- name: 스킬 이름 (소문자+하이픈, 예: pdf-processor)
- plugin-path: 플러그인 경로 (기본: 현재 디렉토리)
```

## 워크플로우

### 1단계: 대상 플러그인 확인

1. `plugin-path` 인자 확인
2. 없으면 현재 디렉토리에서 `.claude-plugin/plugin.json` 탐색
3. 없으면 사용자에게 플러그인 경로 요청

### 2단계: 스킬 정보 수집 (대화)

사용자에게 질문:

```
새 스킬을 생성합니다.

1. 스킬 설명 (description):
   > 무엇을 하는지 + 언제 활성화되는지 포함
   > 예: "PDF 파일에서 텍스트 추출. PDF, 문서 추출 관련 요청 시 활성화."

2. 필요한 도구 (allowed-tools, 선택):
   > 예: Bash(python3:*), Read, Write
   > 생략하면 제한 없음

3. 환경 요구사항 (compatibility, 선택):
   > 예: "Requires python3, poppler-utils"

4. references 폴더 필요 여부:
   > 상세 문서나 예제가 많으면 references/ 폴더 생성 [y/N]
```

### 3단계: 스킬 디렉토리 생성

**구조**:
```
{plugin-path}/skills/{name}/
├── SKILL.md           # 필수
└── references/        # 선택 (2단계에서 선택 시)
```

### 4단계: SKILL.md 생성

**경로**: `{plugin-path}/skills/{name}/SKILL.md`

**템플릿**:

```markdown
---
name: {name}
description: {description}
{allowed-tools가 있으면}allowed-tools: {allowed-tools}
{compatibility가 있으면}compatibility: {compatibility}
---

# {Name} Skill

## 개요

{description의 첫 문장}

## 워크플로우

### 1단계: {첫 번째 단계}

{내용}

### 2단계: {두 번째 단계}

{내용}

## 규칙

1. {규칙 1}
2. {규칙 2}

## 참조

- {관련 스킬이나 문서 참조}
```

### 5단계: plugin.json 확인

`plugin.json`의 `skills` 필드에 경로가 포함되어 있는지 확인:

```json
{
  "skills": ["./skills/"]
}
```

없으면 추가 제안.

### 6단계: 대응 커맨드 생성 제안

```
Command-Skill 1:1 원칙에 따라 대응 커맨드도 생성할까요?

/{plugin-name}:{name} 커맨드를 생성하면:
- 사용자가 명시적으로 스킬을 호출 가능
- 스킬이 자동 활성화되지 않을 때도 사용 가능

생성하시겠습니까? [Y/n]
```

선택 시:
```
Skill 도구로 forgeify:new-command 호출
인자: {name} {plugin-path}
```

### 7단계: 완료 메시지

```
✅ 스킬 생성 완료

파일: {plugin-path}/skills/{name}/SKILL.md
자동 활성화 조건: {description의 활성화 조건}

다음 단계:
- 스킬 워크플로우 상세 작성
- Progressive Disclosure 원칙 준수 확인 (<5000 토큰)
- /forgeify:validate로 검증
```

## 규칙

1. **name = 디렉토리명**: `name` 필드와 디렉토리명 일치 필수
2. **SKILL.md 대문자**: 파일명은 반드시 `SKILL.md` (대문자)
3. **description 품질**: "무엇을 + 언제" 형식 필수
4. **Progressive Disclosure**: 본문 5000 토큰 이하, 상세 내용은 references/로

## 참조

- skill-guide 스킬의 상세 규격 참조
