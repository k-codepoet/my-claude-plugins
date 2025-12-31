---
description: 지정된 경로의 내용을 기반으로 Claude Code 플러그인을 생성합니다. 가이드라인에 맞춰 plugin.json, commands, skills, agents 구조를 자동 생성합니다.
argument-hint: "<path> <topic>"
allowed-tools: Read, Write, Bash, Glob, Grep
---

# /ced:create - 플러그인 생성

사용자가 지정한 경로와 주제를 기반으로 Claude Code 플러그인을 생성합니다.

## 사용법

```
/ced:create <path> <topic>
```

- `<path>`: 플러그인 소스가 될 파일 또는 디렉토리 경로
- `<topic>`: 플러그인 주제/이름 (예: "docker-helper", "git-workflow")

## 워크플로우

### 1단계: 소스 분석

지정된 경로에서 내용을 읽고 분석합니다:
- 파일인 경우: 해당 파일 내용 분석
- 디렉토리인 경우: 주요 파일들 (*.md, *.sh, *.json 등) 탐색 및 분석
- 내용에서 플러그인화 가능한 요소 식별:
  - 반복 작업 → Commands로 변환
  - 지식/가이드 → Skills로 변환
  - 자연어 트리거 패턴 → Agents로 변환
  - 스크립트 → scripts/ 디렉토리로 이동

### 2단계: 플러그인 구조 설계

분석 결과를 바탕으로 플러그인 구조를 제안합니다:

```
plugins/{topic}/
├── .claude-plugin/
│   └── plugin.json
├── commands/          # 슬래시 명령어
├── skills/            # 컨텍스트 기반 지식
├── agents/            # 자연어 트리거 에이전트
└── scripts/           # 실행 스크립트
```

### 3단계: 사용자 확인

생성할 구조와 내용을 사용자에게 제시하고 확인받습니다:
- 플러그인 이름 및 설명
- 생성할 컴포넌트 목록 (commands, skills, agents)
- 각 컴포넌트의 역할 설명

### 4단계: 플러그인 생성

확인 후 다음 가이드라인에 따라 생성합니다:

**plugin.json** (plugin-guide 스킬 참조):
```json
{
  "name": "{topic}",
  "version": "1.0.0",
  "description": "...",
  "author": { "name": "..." },
  "commands": ["./commands/"],
  "skills": ["./skills/"],
  "agents": ["./agents/"]
}
```

**Commands** (command-guide 스킬 참조):
- YAML frontmatter: name, description, allowed-tools, argument-hint
- 명확한 워크플로우 설명
- `${CLAUDE_PLUGIN_ROOT}` 변수 사용

**Skills** (skill-guide 스킬 참조):
- 디렉토리별 SKILL.md 구조
- Progressive Disclosure 원칙
- 명확한 description으로 자동 활성화 유도

**Agents** (agent-guide 스킬 참조):
- 상세한 description (트리거 조건)
- `<example>` 블록으로 트리거 예시
- tools 배열 지정

### 5단계: 마켓플레이스 등록 안내

생성 완료 후 마켓플레이스 등록 방법 안내:
```json
// .claude-plugin/marketplace.json에 추가
{
  "name": "{topic}",
  "source": "./plugins/{topic}",
  "description": "..."
}
```

## 예시

```
/ced:create ~/my-scripts/docker-utils docker-helper
```

위 명령은:
1. `~/my-scripts/docker-utils` 경로의 스크립트들을 분석
2. `docker-helper` 플러그인 구조 생성
3. 스크립트를 commands와 연동
4. 사용 패턴을 agents로 변환

## 주의사항

- 기존 플러그인 디렉토리가 있으면 덮어쓰기 전 확인
- 스크립트는 idempotent하게 수정 권장
- 생성 후 `/ced:validate` 로 검증 권장
