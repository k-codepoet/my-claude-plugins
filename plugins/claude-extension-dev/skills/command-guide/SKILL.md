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
| `description` | ✅ | 커맨드 설명 |
| `allowed-tools` | ❌ | 사용 가능한 도구 제한 |
| `argument-hint` | ❌ | 인자 힌트 표시 |
| `name` | ❌ | **파일명 override** (아래 참고) |

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
