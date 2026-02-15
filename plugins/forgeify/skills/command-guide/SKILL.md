---
description: Claude Code 슬래시 커맨드 작성법 가이드. 커맨드 만들기, YAML frontmatter 작성, Skills vs Commands 비교에 대해 질문할 때 사용합니다.
---

# Commands (커맨드) 가이드

## 개념

**레거시 방식의 슬래시 명령어**입니다. Claude Code 공식 문서(2026-02) 기준으로 commands는 skills로 병합되었습니다. 기존 `.claude/commands/` 파일은 여전히 동작하지만, **skills가 우선**이며 추가 기능(지원 파일, 자동 호출 제어)을 제공합니다.

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

| 구분 | Skills (권장) | Commands (레거시) |
|------|--------------|-------------------|
| 저장 위치 | `skills/{name}/SKILL.md` | `commands/{name}.md` |
| 우선순위 | 높음 (동명 시 우선) | 낮음 |
| 호출 방식 | 자동 + `/skill-name` | `/command-name` 만 |
| 기능 | 지원 파일, 자동 호출 제어 | 기본 frontmatter만 |
| 사용 목적 | 모든 기능 구현 | help/howto만 유지 |

## Command-Skill 관계 (레거시 → 통합)

Skills가 commands를 완전히 대체했으므로, 새로운 기능은 skills로만 생성합니다. Commands는 help, howto 같은 정적 가이드용으로만 유지합니다.

### 이전 방식 (레거시)

```
commands/setup.md      ↔  skills/setup/SKILL.md   # 1:1 쌍
commands/status.md     ↔  skills/status/SKILL.md
```

### 현재 방식 (권장)

```
skills/setup/SKILL.md    # 스킬만 생성 → 자동 + /setup으로 호출 가능
skills/status/SKILL.md   # 커맨드 불필요
commands/help.md         # 정적 가이드만 커맨드로 유지
```

### 마이그레이션 원칙

1. **새 기능**: `skills/{name}/SKILL.md`로만 생성
2. **기존 커맨드**: 기능 커맨드는 삭제하고 스킬만 유지
3. **유지 대상**: help, howto 등 정적 가이드 커맨드만 유지

## 스킬 명시적 로드 (레거시)

> **Note**: Skills 통합 후에는 커맨드에서 스킬을 Read할 필요가 없습니다. 스킬이 직접 `/skill-name`으로 호출되기 때문입니다. 이 패턴은 레거시 커맨드가 남아있는 경우에만 해당됩니다.

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

## Skill 도구로 다른 스킬 호출하기

한 스킬에서 다른 스킬(또는 커맨드)로 작업을 위임할 때 Skill 도구를 사용합니다.

### 사용법

```
Skill 도구:
  skill: "plugin-name:skill-name"
  args: "인자 (선택)"
```

### 파라미터

| 파라미터 | 필수 | 설명 |
|----------|------|------|
| `skill` | O | 스킬/커맨드 이름 (예: `forgeify:improve-plugin`) |
| `args` | X | 전달할 인자 문자열 |

### 예시: gemify → forgeify 위임

gemify:improve-plugin이 문서 생성 후 forgeify:improve-plugin 호출:

```
Skill 도구:
  skill: "forgeify:improve-plugin"
  args: "~/.gemify/views/by-improvement/forgeify-add-validation.md"
```

### Read vs Skill 도구

| 방식 | 용도 |
|------|------|
| `Read: $CLAUDE_PLUGIN_ROOT/skills/...` | 같은 플러그인 내 스킬 로드 |
| `Skill 도구` | 다른 플러그인 스킬 실행, 크로스 플러그인 위임 |

### 주의사항

- `disable-model-invocation: true`인 스킬은 Skill 도구로 호출 불가
- 빌트인 커맨드 (/compact, /init 등)는 Skill 도구로 호출 불가
