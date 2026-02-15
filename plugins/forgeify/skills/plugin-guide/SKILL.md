---
description: Claude Code 플러그인 구조와 plugin.json 작성법 가이드. 플러그인 만들기, plugin.json 스키마, 설치 스코프, CLI 명령어에 대해 질문할 때 사용합니다.
---

# Plugin (플러그인) 가이드

## 개념

**Commands, Skills, Agents, Hooks, MCP Servers를 하나로 묶은 배포 단위**입니다. 플러그인은 마켓플레이스를 통해 공유됩니다.

## 필수 구조

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # 필수: 플러그인 매니페스트
├── commands/              # 선택: 커맨드
├── agents/                # 선택: 서브에이전트
├── skills/                # 선택: 스킬
│   ├── skill-1/
│   │   └── SKILL.md
│   └── skill-2/
│       └── SKILL.md
├── hooks/                 # 선택: 훅 설정
│   └── hooks.json
├── .mcp.json              # 선택: MCP 서버
├── .lsp.json              # 선택: LSP 서버
└── scripts/               # 선택: 유틸리티 스크립트
```

## plugin.json 작성법

```json
{
  "name": "my-plugin",
  "version": "1.2.0",
  "description": "Brief plugin description",
  "author": {
    "name": "Author Name",
    "email": "author@example.com",
    "url": "https://github.com/author"
  },
  "homepage": "https://docs.example.com/plugin",
  "repository": "https://github.com/author/plugin",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"],
  "commands": ["./commands/"],
  "agents": ["./agents/my-agent.md"],
  "skills": ["./skills/"],
  "hooks": "./config/hooks.json",
  "mcpServers": "./mcp-config.json",
  "lspServers": "./.lsp.json"
}
```

## 필드 설명

### 필수 필드

| 필드 | 타입 | 설명 | 예시 |
|------|------|------|------|
| `name` | string | 고유 식별자 (kebab-case) | `"deployment-tools"` |

### 권장 필드

| 필드 | 타입 | 설명 | 예시 |
|------|------|------|------|
| `version` | string | semver 형식 | `"1.0.0"` |
| `description` | string | 간결한 설명 | `"Deploy tools"` |
| `author.name` | string | 작성자 이름 | `"Author Name"` |

### 선택 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `author.email` | string | 작성자 이메일 |
| `author.url` | string | 작성자 URL |
| `homepage` | string | 플러그인 문서 URL |
| `repository` | string | 소스 저장소 URL |
| `license` | string | 라이선스 (예: MIT) |
| `keywords` | string[] | 검색용 키워드 |
| `commands` | string[] | 커맨드 경로 |
| `agents` | string[] | 에이전트 파일 경로 (개별 .md 파일) |
| `skills` | string[] | 스킬 경로 |
| `hooks` | string | hooks.json 경로 |
| `mcpServers` | string | MCP 설정 경로 |
| `lspServers` | string | LSP 설정 경로 |

## 중요 환경 변수

**`${CLAUDE_PLUGIN_ROOT}`**: 플러그인 디렉토리의 절대 경로. 모든 스크립트와 경로에서 사용 필수.

```json
{
  "hooks": {
    "PostToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/process.sh"
      }]
    }]
  }
}
```

## 설치 스코프

| 스코프 | 설정 파일 | 용도 |
|--------|-----------|------|
| `user` | `~/.claude/settings.json` | 개인용, 모든 프로젝트에서 사용 (기본값) |
| `project` | `.claude/settings.json` | 팀 공유용, 버전 관리 포함 |
| `local` | `.claude/settings.local.json` | 프로젝트별, gitignore |
| `managed` | `managed-settings.json` | 기업 관리용 (읽기 전용) |

## scripts/ 디렉토리

> **원칙**: 정형화된 작업은 shell script로 만들어야 한다.
> → `principles/script-repetitive-tasks.md` 참조

플러그인에서 반복되는 정형화된 작업은 `scripts/`에 스크립트로 작성합니다:

```
scripts/
├── validate-plugin.sh   # 플러그인 검증
├── build.sh             # 빌드 스크립트
└── test.sh              # 테스트 실행
```

### 스크립트 작성 원칙

1. **Exit code로 결과 반환** (0: 성공, 1: 실패, 2: 입력 오류)
2. **명확한 출력 형식** (파싱 가능하거나 사람이 읽기 쉽게)
3. **실행 권한 부여** (`chmod +x`)

### 스크립트화 판단 기준

| 조건 | 스크립트화 |
|------|-----------|
| 동일한 로직이 반복됨 | ✅ 필수 |
| 입력/출력이 정형화됨 | ✅ 필수 |
| 매번 다른 판단이 필요 | ❌ 불필요 |

## CLI 명령어

```bash
# 플러그인 설치
claude plugin install <plugin>[@marketplace] --scope user|project|local

# 플러그인 제거
claude plugin uninstall <plugin> --scope user|project|local

# 플러그인 활성화/비활성화
claude plugin enable <plugin> --scope user
claude plugin disable <plugin> --scope user

# 플러그인 업데이트
claude plugin update <plugin> --scope user|project|local|managed

# 디버깅
claude --debug
```
