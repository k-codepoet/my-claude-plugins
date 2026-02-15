---
description: 새 커맨드 생성. "커맨드 만들기", "new command", "슬래시 커맨드 추가" 등 요청 시 활성화.
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: "<name> [plugin-path]"
---

# new-command Skill

## 개요

Claude Code 플러그인에 새 슬래시 커맨드를 생성합니다.

## 인자

```
/forgeify:new-command <name> [plugin-path]

- name: 커맨드 이름 (예: deploy, setup)
- plugin-path: 플러그인 경로 (기본: 현재 디렉토리)
```

## 워크플로우

### 1단계: 대상 플러그인 확인

1. `plugin-path` 인자 확인
2. 없으면 현재 디렉토리에서 `.claude-plugin/plugin.json` 탐색
3. 없으면 사용자에게 플러그인 경로 요청

### 2단계: 커맨드 정보 수집 (대화)

사용자에게 질문:

```
새 커맨드를 생성합니다.

1. 커맨드 설명 (description):
   > 예: "애플리케이션을 프로덕션에 배포"

2. 필요한 도구 (allowed-tools):
   > 예: Read, Write, Bash (기본: 제한 없음)

3. 인자 형식 (argument-hint):
   > 예: [--env <environment>] (선택사항)

4. 대응 스킬 생성 여부:
   > Command-Skill 1:1 원칙에 따라 스킬도 함께 생성할까요? [Y/n]
```

### 3단계: 커맨드 파일 생성

**경로**: `{plugin-path}/commands/{name}.md`

**템플릿**:

```markdown
---
description: {description}
allowed-tools: {allowed-tools}
argument-hint: {argument-hint}
---

# /{plugin-name}:{name}

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/{name}/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법

/{plugin-name}:{name} {argument-hint}

ARGUMENTS: $ARGUMENTS
```

### 4단계: 대응 스킬 생성 (선택)

사용자가 스킬 생성을 원하면:

```
Skill 도구로 forgeify:new-skill 호출
인자: {name} {plugin-path}
```

### 5단계: plugin.json 확인

`plugin.json`의 `commands` 필드에 경로가 포함되어 있는지 확인:

```json
{
  "commands": ["./commands/"]
}
```

없으면 추가 제안.

### 6단계: 완료 메시지

```
✅ 커맨드 생성 완료

파일: {plugin-path}/commands/{name}.md
사용: /{plugin-name}:{name}

다음 단계:
- 커맨드 내용 검토 및 수정
- /forgeify:validate로 검증
```

## 규칙

1. **description 필수**: 빈 description은 허용하지 않음
2. **파일명 = 커맨드명**: `name` frontmatter 필드는 특별한 경우에만 사용
3. **스킬 참조 명시**: 커맨드 본문에 스킬 Read 지시 포함
4. **ARGUMENTS 변수**: 인자 전달을 위해 `$ARGUMENTS` 포함

## 참조

- command-guide 스킬의 상세 규격 참조
