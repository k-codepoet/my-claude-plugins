---
name: create
description: 플러그인 생성 가이드. "플러그인 만들기", "create plugin", "새 플러그인 생성" 등 요청 시 활성화.
---

# Create Skill

지정된 경로의 내용을 기반으로 Claude Code 플러그인을 생성합니다.

## 참조 스킬 (Progressive Disclosure)

각 구성요소 생성 시 해당 스킬을 반드시 참조합니다:

| 구성요소 | 참조 스킬 | 핵심 규격 |
|----------|-----------|-----------|
| plugin.json | **plugin-guide** | name(kebab-case), version, description, author |
| commands/*.md | **command-guide** | description 필수, allowed-tools, argument-hint |
| skills/*/SKILL.md | **skill-guide** | 디렉토리명=스킬명, Progressive Disclosure |
| agents/*.md | **agent-guide** | name, description, `<example>` 블록 |

## 워크플로우

### 1단계: 소스 분석
- 지정 경로의 파일/디렉토리 내용 분석
- 플러그인화 가능한 요소 식별:
  - 반복 작업 → Commands
  - 지식/가이드 → Skills
  - 자연어 트리거 → Agents
  - 스크립트 → scripts/

### 2단계: 구조 설계 및 사용자 확인
- 생성할 컴포넌트 목록 제시
- 사용자 승인 후 진행

### 3단계: 플러그인 생성

생성할 구조:
```
plugins/{plugin-name}/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── *.md
├── skills/
│   └── {skill-name}/
│       └── SKILL.md
├── agents/
│   └── *.md
└── scripts/
    └── *.sh
```

**중요**: `agents` 필드는 반드시 개별 .md 파일 경로 (디렉토리 불가)

### 4단계: 마켓플레이스 등록
- marketplace.json에 자동 추가 (이미 등록되어 있으면 스킵)

### 5단계: 검증
- validate 스킬로 검증 실행
- 오류 발생 시 자동 수정 시도

## 생성 규칙

1. **네이밍**: plugin.json의 `name`은 kebab-case 사용
2. **스킬 구조**: `skills/{skill-name}/SKILL.md` 형태 (SKILL.md는 대문자)
3. **스크립트**: `${CLAUDE_PLUGIN_ROOT}` 환경변수 활용
4. **에이전트**: 반드시 `<example>` 블록 포함

## 예시

```
/forgeify:create ~/my-scripts/docker-utils docker-helper
```

결과:
```
plugins/docker-helper/
├── .claude-plugin/plugin.json
├── commands/build.md
├── commands/run.md
├── skills/docker-guide/SKILL.md
└── scripts/docker-utils.sh
```
