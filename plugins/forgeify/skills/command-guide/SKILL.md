---
name: command-guide
description: Claude Code 슬래시 커맨드 작성법 가이드. 커맨드 만들기, YAML frontmatter 작성, Skills vs Commands 비교에 대해 질문할 때 사용합니다.
---

# Commands (커맨드) 가이드

## 개념

**사용자가 `/` 슬래시로 명시적으로 실행하는 커스텀 명령어**입니다. Skills와 달리 사용자가 직접 호출합니다.

## 디렉토리 구조

```
plugin-root/
└── commands/
    ├── deploy.md      # /{pluginname}:deploy 커맨드
    └── analyze.md     # /{pluginname}:analyze 커맨드
```

## 작성법

```markdown
---
description: Deploy the application to production
allowed-tools: Bash, Read, Write
argument-hint: [--env <environment>]
---

# Deploy Command

## Steps
1. Build the application
2. Run tests
3. Deploy to production

## Usage
/{pluginname}:deploy --env production
```

## Frontmatter 필드

| 필드 | 필수 | 설명 |
|------|------|------|
| `description` | 권장 | 커맨드 설명 |
| `allowed-tools` | ❌ | 사용 가능한 도구 제한 |
| `argument-hint` | ❌ | 인자 힌트 표시 |
| `name` | ❌ | **파일명 override** (아래 참고) |
| `model` | ❌ | 사용할 모델 지정 (예: `claude-3-5-haiku-20241022`) |
| `hooks` | ❌ | 커맨드 실행 중 훅 정의 (PreToolUse, PostToolUse, Stop) |
| `disable-model-invocation` | ❌ | `true` 설정 시 Claude가 자동 호출 불가 (메타데이터도 컨텍스트에서 제외) |

## 명령어 이름 규칙

**기본**: 파일명이 명령어 이름이 됩니다.
- `commands/deploy.md` → `/{pluginname}:deploy`
- `commands/setup-env.md` → `/{pluginname}:setup-env`

**Override**: `name` 필드로 파일명과 다른 이름 지정 가능
```yaml
---
name: my-custom-name
description: ...
---
```
- `commands/deploy.md` + `name: d` → `/{pluginname}:d`

⚠️ **주의**: `name` 필드 없이 파일명만 사용하는 것이 기본 권장 패턴입니다. prefix가 자동으로 붙어 `/{pluginname}:{filename}` 형식이 됩니다.

## Skills vs Commands 비교

| 구분 | Skills | Commands |
|------|--------|----------|
| 호출 방식 | Claude가 자동 판단 | 사용자가 명시적으로 `/command` |
| 범위 | 작업별, 필요시 로드 | 항상 사용 가능 |
| 표준 | Agent Skills 오픈 스탠다드 | Claude Code 전용 |
| 사용 목적 | 재사용 가능한 전문 워크플로우 | 특정 프로젝트 작업 자동화 |

## Command-Skill 1:1 쌍 원칙 (필수)

**모든 기능 커맨드는 대응하는 스킬과 1:1 쌍을 이루어야 합니다.**

```
commands/setup.md      ↔  skills/setup/SKILL.md
commands/status.md     ↔  skills/status/SKILL.md
commands/deploy.md     ↔  skills/deploy/SKILL.md
```

### 왜 1:1 쌍인가?

1. **Single Source of Truth**: 로직은 스킬에만 존재 → 중복 방지, 유지보수 용이
2. **AI Agent 위임**: 스킬은 Claude가 자동으로 활성화 가능 → 커맨드 없이도 AI가 적절히 사용
3. **Progressive Disclosure**: 커맨드는 진입점, 상세 로직은 스킬이 담당

### 예외

- `help.md` - 단순 도움말 출력, 스킬 불필요
- `howto.md` - 가이드 안내, 스킬 불필요

## 스킬 명시적 로드 (필수)

**중요**: 커맨드에서 스킬을 암묵적으로 참조하면 Claude가 로드하지 않습니다.

### 잘못된 예 (동작 안 함)

```markdown
# /gemify:draft

draft 스킬을 사용하여 원석을 다듬는다.
```

Claude는 "draft 스킬을 사용하여"라는 문구만으로 스킬을 자동 로드하지 **않습니다**.

### 올바른 예 (권장)

```markdown
---
description: inbox의 원석을 대화로 다듬기
allowed-tools: Read, Write, Edit
---

# /gemify:draft - 원석 다듬기

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/draft/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법
...
```

### 핵심 규칙

1. **커맨드에 로직을 직접 구현하지 않음** - 스킬이 로직 담당
2. **커맨드에서 스킬 Read를 명시적으로 지시** - Claude가 확실히 로드
3. **커맨드는 사용법과 다음 단계만 안내** - 진입점 역할

### 구조

```
commands/draft.md     ← 진입점 (스킬 Read 지시)
skills/draft/SKILL.md ← 실제 로직
```
