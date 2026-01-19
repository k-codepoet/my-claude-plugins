# Forgeify

*Forge your ideas into Claude extensions*

Claude Code 메타도구(plugin, skill, command, agent, hook) 개발을 위한 **한국어 가이드** 플러그인입니다.

## 개요

이 플러그인은 Claude Code의 확장 시스템 개발 방법을 스킬 형태로 제공합니다. Claude가 대화 컨텍스트에 따라 관련 스킬을 자동으로 활성화합니다.

## 설치

```bash
# 마켓플레이스 추가
/plugin marketplace add k-codepoet/my-claude-plugins

# 플러그인 설치
/plugin install forgeify@k-codepoet-plugins
```

## 커맨드

### 기본

| 커맨드 | 설명 |
|--------|------|
| `/forgeify:help` | 도움말 표시 |
| `/forgeify:howto` | 가능한 가이드 주제 목록 |
| `/forgeify:howto <topic>` | 특정 주제 가이드 표시 |

### 생성 (new-*)

| 커맨드 | 설명 |
|--------|------|
| `/forgeify:new` | 메타도구 생성 라우터 |
| `/forgeify:new-plugin` | 새 플러그인 생성 |
| `/forgeify:new-skill` | 새 스킬 생성 |
| `/forgeify:new-command` | 새 커맨드 생성 |
| `/forgeify:new-agent` | 새 에이전트 생성 |
| `/forgeify:new-hook` | 새 훅 생성 |

### 개선 (improve-*)

| 커맨드 | 설명 |
|--------|------|
| `/forgeify:improve` | 메타도구 개선 라우터 |
| `/forgeify:improve-plugin` | gemify 개선 문서 기반 플러그인 수정 |
| `/forgeify:improve-skill` | 스킬 개선 |
| `/forgeify:improve-command` | 커맨드 개선 |
| `/forgeify:improve-agent` | 에이전트 개선 |
| `/forgeify:improve-hook` | 훅 개선 |

### 유틸리티

| 커맨드 | 설명 |
|--------|------|
| `/forgeify:validate [path]` | 가이드라인 준수 검증 |
| `/forgeify:align [path]` | 공식문서/외부 레퍼런스 기반 정렬 |
| `/forgeify:compose <plugins...>` | 여러 플러그인 조립 |

## 스킬 (자동 활성화)

### 가이드 스킬
- `plugin-guide` - 플러그인 구조, plugin.json 작성법
- `skill-guide` - SKILL.md 작성법, Agent Skills 표준
- `command-guide` - 슬래시 커맨드 작성법
- `agent-guide` - 서브에이전트 정의, frontmatter 필드
- `hook-guide` - 이벤트 훅, hooks.json 작성법
- `marketplace-guide` - 마켓플레이스 구축
- `workflow-guide` - 플러그인 개발 실전 워크플로우

### 작업 스킬
- `new-plugin`, `new-skill`, `new-command`, `new-agent`, `new-hook` - 생성
- `improve-plugin`, `improve-skill`, `improve-command`, `improve-agent`, `improve-hook` - 개선
- `align` - 공식문서 기반 정렬
- `validate` - 검증
- `compose` - 조립
- `bugfix` - 버그 수정

## 사용 방법

**명시적 호출**:
```bash
/forgeify:howto plugin    # 플러그인 구조, plugin.json 작성법
/forgeify:howto agent     # 서브에이전트 정의, frontmatter 필드
/forgeify:new-skill       # 새 스킬 생성
/forgeify:improve-plugin  # 플러그인 개선
```

**자동 활성화**: 대화 컨텍스트에 따라 Claude가 관련 스킬 자동 로드
```
"플러그인 만드는 방법 알려줘"
"agent 파일 어떻게 작성해?"
"hook 이벤트 종류가 뭐야?"
"새 스킬 만들어줘"
```

## 아키텍처

```
forgeify/
├── .claude-plugin/plugin.json  # 플러그인 메타데이터 (v2.0.0)
├── commands/                   # 슬래시 커맨드 (17개)
│   ├── help.md, howto.md      # 기본
│   ├── new*.md                # 생성 시리즈 (6개)
│   ├── improve*.md            # 개선 시리즈 (5개)
│   └── validate.md, align.md, compose.md  # 유틸리티
└── skills/                     # 자동 활성화 스킬 (21개)
    ├── *-guide/               # 가이드 스킬 (7개)
    ├── new-*/                 # 생성 스킬 (5개)
    ├── improve-*/             # 개선 스킬 (5개)
    └── validate/, align/, compose/, bugfix/  # 유틸리티 (4개)
```

## gemify 연계

forgeify는 [gemify](../gemify/) 플러그인과 연계됩니다:
- `gemify:poc` → 아이디어 정제 → 메타도구 타입 결정 → `forgeify:new-*`
- `gemify:improve-plugin` → 개선 문서 생성 → `forgeify:improve-plugin`
- `gemify:bugfix` → 버그 분석 문서 → `forgeify:bugfix`

**흐름**: gemify(지식 생산) → forgeify(실행)

## 참고 자료

- [Agent Skills 표준](https://agentskills.io)
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
