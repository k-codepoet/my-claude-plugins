# Boilerplate 사용법

## 소스 저장소

```
https://github.com/k-codepoet/my-boilerplates
```

## Boilerplate 매핑 테이블

### 웹앱 (6종)

| 카테고리 | boilerplate | 렌더링 | 플랫폼 | 프레임워크 |
|----------|-------------|--------|--------|-----------|
| web | `react-router-ssr-cloudflare` | SSR | Cloudflare Workers | React Router v7 |
| web | `react-router-spa-cloudflare` | SPA | Cloudflare Pages | React Router v7 |
| web | `react-router-ssr` | SSR | Docker/Node.js | React Router v7 |
| web | `react-router-spa` | SPA | Docker/nginx | React Router v7 |
| web | `tanstack-start-ssr` | SSR | Docker/vinxi | TanStack Start |
| web | `tanstack-router-spa` | SPA | Vite | TanStack Router |

### CLI/TUI (3종)

| 카테고리 | boilerplate | 언어 | 특징 |
|----------|-------------|------|------|
| cli | `ratatui-rs` | Rust | Ratatui TUI, 크로스컴파일, npm 배포 |
| cli | `bubbletea-go` | Go | Bubbletea TUI, 단일 바이너리, npm 배포 |
| cli | `ink-ts` | TypeScript | Ink (React for CLI), npm 네이티브 |

### 데스크톱 앱 (2종)

| 카테고리 | boilerplate | 특징 |
|----------|-------------|------|
| native-app | `tauri-react-router` | Tauri v2, React Router 멀티 페이지 |
| native-app | `tauri-react` | Tauri v2, React 싱글 페이지 |

### 봇/프로세서 (3종)

| 카테고리 | boilerplate | 런타임 | 특징 |
|----------|-------------|--------|------|
| bot | `slack-processor-ts` | Docker/Node.js | Slack Bolt, Socket Mode |
| bot | `slack-processor-ts-cloudflare` | Cloudflare Workers | Hono + D1, HTTP |
| bot | `slack-processor-python` | Docker/Python | slack-bolt, Socket Mode |

### 게임 (2종)

| 카테고리 | boilerplate | 특징 |
|----------|-------------|------|
| game | `gameglue-framework` | GameGlue 코어, 4 어댑터 |
| game | `gameglue-demo` | GameGlue + React Router SPA |

### AI 컨텍스트 (1종)

| 카테고리 | boilerplate | 특징 |
|----------|-------------|------|
| ai-context | `react-router-ssr-mcp` | React Router SSR + MCP Server + SQLite |

## 복제 명령 (degit 사용)

```bash
# 공통 패턴: npx degit k-codepoet/my-boilerplates/{category}/{name} apps/{target}

# 웹앱
npx degit k-codepoet/my-boilerplates/web/react-router-ssr-cloudflare apps/web
npx degit k-codepoet/my-boilerplates/web/react-router-spa-cloudflare apps/web
npx degit k-codepoet/my-boilerplates/web/react-router-ssr apps/web
npx degit k-codepoet/my-boilerplates/web/react-router-spa apps/web
npx degit k-codepoet/my-boilerplates/web/tanstack-start-ssr apps/web
npx degit k-codepoet/my-boilerplates/web/tanstack-router-spa apps/web

# CLI/TUI
npx degit k-codepoet/my-boilerplates/cli/ratatui-rs apps/cli
npx degit k-codepoet/my-boilerplates/cli/bubbletea-go apps/cli
npx degit k-codepoet/my-boilerplates/cli/ink-ts apps/cli

# 데스크톱 앱
npx degit k-codepoet/my-boilerplates/native-app/tauri-react-router apps/desktop
npx degit k-codepoet/my-boilerplates/native-app/tauri-react apps/desktop

# 봇/프로세서
npx degit k-codepoet/my-boilerplates/bot/slack-processor-ts apps/bot
npx degit k-codepoet/my-boilerplates/bot/slack-processor-ts-cloudflare apps/bot
npx degit k-codepoet/my-boilerplates/bot/slack-processor-python apps/bot

# 게임
npx degit k-codepoet/my-boilerplates/game/gameglue-framework apps/game
npx degit k-codepoet/my-boilerplates/game/gameglue-demo apps/game

# AI 컨텍스트
npx degit k-codepoet/my-boilerplates/ai-context/react-router-ssr-mcp apps/ai-context
```

## 복제 후 작업

### Node.js 계열 (web, bot/TS, game, ai-context, cli/ink-ts)

```bash
# 1. package.json name 수정
# @boilerplates/{category}-{name} → @apps/{product}

# 2. 의존성 설치
pnpm install

# 3. 빌드 확인
pnpm build

# 4. 로컬 실행
pnpm dev
```

### Rust CLI (cli/ratatui-rs)

```bash
# 1. Cargo.toml name 수정
# 2. 빌드 확인
cargo build
# 3. 로컬 실행
cargo run
```

### Go CLI (cli/bubbletea-go)

```bash
# 1. go.mod module 수정
# 2. 빌드 확인
go build -o mycli ./cmd
# 3. 로컬 실행
go run ./cmd
```

### Python Bot (bot/slack-processor-python)

```bash
# 1. pyproject.toml name 수정
# 2. 가상환경 생성 + 설치
uv venv && source .venv/bin/activate && uv pip install -e .
# 3. 로컬 실행
python -m src.main
```

### 데스크톱 앱 (native-app/*)

```bash
# 1. package.json + tauri.conf.json 수정
# 2. 의존성 설치
pnpm install
# 3. 개발 모드
pnpm tauri:dev
# 4. 빌드
pnpm tauri:build
```

## turborepo 구조

복제 후 생성할 파일:
- `turbo.json`
- `package.json` (루트)
- `pnpm-workspace.yaml`
- `CRAFTIFY.md`
- `.craftify/guides/`

상세 구조는 `/craftify:create` 스킬 참조.

## 외부 참조

- https://github.com/k-codepoet/my-boilerplates - Boilerplate 저장소
