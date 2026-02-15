---
description: 새 에이전트 생성. "에이전트 만들기", "new agent", "서브에이전트 추가" 등 요청 시 활성화.
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: "<name> [plugin-path]"
---

# new-agent Skill

## 개요

Claude Code 플러그인에 새 서브에이전트를 생성합니다.

## 인자

```
/forgeify:new-agent <name> [plugin-path]

- name: 에이전트 이름 (소문자+하이픈, 예: code-reviewer)
- plugin-path: 플러그인 경로 (기본: 현재 디렉토리)
```

## 워크플로우

### 1단계: 대상 플러그인 확인

1. `plugin-path` 인자 확인
2. 없으면 현재 디렉토리에서 `.claude-plugin/plugin.json` 탐색
3. 없으면 사용자에게 플러그인 경로 요청

### 2단계: 에이전트 정보 수집 (대화)

사용자에게 질문:

```
새 에이전트를 생성합니다.

1. 에이전트 설명 (description):
   > 언제 이 에이전트를 사용해야 하는지 자연어로 설명
   > 예: "코드 품질 검토 전문가. 코드 작성 후 PROACTIVELY 사용하세요."

2. 필요한 도구 (tools, 선택):
   > 예: Read, Grep, Glob, Bash
   > 생략하면 모든 도구 상속

3. 모델 선택 (model, 선택):
   > sonnet: 균형잡힌 성능 (기본)
   > opus: 복잡한 추론
   > haiku: 빠른 응답
   > inherit: 부모 모델 상속

4. 자동 위임 방식:
   > proactive: 특정 상황에서 Claude가 자동 호출
   > manual: 사용자 요청 시에만 호출
```

### 3단계: example 블록 생성 (필수)

에이전트는 반드시 `<example>` 블록이 필요합니다.

```
example 블록을 작성합니다.

에이전트가 트리거되는 상황을 설명해주세요:
> 예: "사용자가 코드 리뷰를 요청할 때"

사용자 입력 예시:
> 예: "이 코드 좀 검토해줘"

에이전트 응답 예시:
> 예: "코드 리뷰를 시작하겠습니다..."
```

### 4단계: 에이전트 파일 생성

**경로**: `{plugin-path}/agents/{name}.md`

**템플릿**:

```markdown
---
name: {name}
description: {description}
tools: {tools}
model: {model}
---

# {Name} Agent

{에이전트 역할 설명}

## 호출 시 수행 작업

1. {첫 번째 작업}
2. {두 번째 작업}
3. {세 번째 작업}

## 검토 체크리스트

- [ ] {체크 항목 1}
- [ ] {체크 항목 2}
- [ ] {체크 항목 3}

<example>
Context: {트리거 상황}
user: "{사용자 입력}"
assistant: "{에이전트 응답}"
<commentary>이 에이전트가 트리거되는 이유 설명</commentary>
</example>
```

### 5단계: plugin.json 업데이트

`plugin.json`의 `agents` 필드에 파일 경로 추가:

```json
{
  "agents": ["./agents/{name}.md"]
}
```

**주의**: agents는 디렉토리가 아닌 **개별 파일 경로** 사용

### 6단계: 완료 메시지

```
✅ 에이전트 생성 완료

파일: {plugin-path}/agents/{name}.md
호출: "{name} 에이전트로 처리해줘"
자동 위임: {proactive/manual}

다음 단계:
- 에이전트 지시사항 상세 작성
- example 블록 검토 및 보강
- /forgeify:validate로 검증
```

## 규칙

1. **example 블록 필수**: 에이전트는 반드시 `<example>` 블록 포함
2. **description 품질**: 언제 사용할지 명확히 기술
3. **최소 권한 원칙**: 필요한 도구만 `tools`에 명시
4. **개별 파일 경로**: plugin.json의 agents는 `["./agents/name.md"]` 형식

## 참조

- agent-guide 스킬의 상세 규격 참조
