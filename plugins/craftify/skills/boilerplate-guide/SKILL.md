---
description: boilerplate 선택 가이드. 프로젝트 요구사항에 맞는 boilerplate 추천. "boilerplate 선택", "어떤 템플릿", "SSR vs SPA", "CLI", "봇", "데스크톱", "게임" 등 질문 시 활성화.
---

# Boilerplate Guide Skill

프로젝트 요구사항에 맞는 **boilerplate 선택을 가이드**합니다.

## 의사결정 플로우차트

```
어떤 종류의 프로젝트인가요?
│
├── 1. 웹앱 → (아래 웹앱 플로우)
├── 2. CLI/TUI → (아래 CLI 플로우)
├── 3. 데스크톱 앱 → (아래 데스크톱 플로우)
├── 4. 봇/프로세서 → (아래 봇 플로우)
├── 5. 게임 → (아래 게임 플로우)
└── 6. AI 컨텍스트 앱 → react-router-ssr-mcp
```

### 웹앱 플로우

```
프레임워크 선호?
├── React Router (권장) 또는 상관없음
│   └── SEO 또는 동적 메타태그 필요?
│       ├── 예 → SSR
│       │   ├── Cloudflare → react-router-ssr-cloudflare
│       │   └── Docker → react-router-ssr
│       └── 아니오 → SPA
│           ├── Cloudflare → react-router-spa-cloudflare
│           └── Docker → react-router-spa
└── TanStack (type-safe routing 선호)
    ├── SSR 필요 → tanstack-start-ssr
    └── SPA → tanstack-router-spa
```

### CLI/TUI 플로우

```
선호 언어?
├── Rust (성능, 크로스컴파일) → ratatui-rs
├── Go (빠른 빌드, 단일 바이너리) → bubbletea-go
└── TypeScript (npm 생태계) → ink-ts
```

### 데스크톱 앱 플로우

```
페이지 구조?
├── 멀티 페이지 (라우팅 필요) → tauri-react-router
└── 싱글 페이지 (단순 UI) → tauri-react
```

### 봇/프로세서 플로우

```
배포 환경?
├── Cloudflare Workers (서버리스, 엣지) → slack-processor-ts-cloudflare
├── Docker (TS, Socket Mode) → slack-processor-ts
└── Docker (Python, Socket Mode) → slack-processor-python
```

### 게임 플로우

```
용도?
├── 게임 엔진 코어 개발 → gameglue-framework
└── 게임 + 웹앱 통합 데모 → gameglue-demo
```

## Boilerplate Pool

### 웹앱 (6종)

| boilerplate | 카테고리 | 렌더링 | 플랫폼 | 프레임워크 |
|-------------|---------|--------|--------|-----------|
| `react-router-ssr-cloudflare` | web | SSR | Cloudflare Workers | React Router v7 |
| `react-router-spa-cloudflare` | web | SPA | Cloudflare Pages | React Router v7 |
| `react-router-ssr` | web | SSR | Docker/Node.js | React Router v7 |
| `react-router-spa` | web | SPA | Docker/nginx | React Router v7 |
| `tanstack-start-ssr` | web | SSR | Docker/vinxi | TanStack Start |
| `tanstack-router-spa` | web | SPA | Vite | TanStack Router |

### CLI/TUI (3종)

| boilerplate | 카테고리 | 언어 | 특징 |
|-------------|---------|------|------|
| `ratatui-rs` | cli | Rust | Ratatui TUI, 크로스컴파일, npm 배포 지원 |
| `bubbletea-go` | cli | Go | Bubbletea TUI, 단일 바이너리, npm 배포 지원 |
| `ink-ts` | cli | TypeScript | Ink (React for CLI), npm 네이티브 |

### 데스크톱 앱 (2종)

| boilerplate | 카테고리 | 특징 |
|-------------|---------|------|
| `tauri-react-router` | native-app | Tauri v2, React Router 멀티 페이지, 플러그인 시스템 |
| `tauri-react` | native-app | Tauri v2, React 싱글 페이지, 경량 |

### 봇/프로세서 (3종)

| boilerplate | 카테고리 | 런타임 | 특징 |
|-------------|---------|--------|------|
| `slack-processor-ts` | bot | Docker/Node.js | Slack Bolt, Socket Mode |
| `slack-processor-ts-cloudflare` | bot | Cloudflare Workers | Hono + D1, HTTP 모드 |
| `slack-processor-python` | bot | Docker/Python | slack-bolt, Socket Mode |

### 게임 (2종)

| boilerplate | 카테고리 | 특징 |
|-------------|---------|------|
| `gameglue-framework` | game | GameGlue 코어, 4 어댑터 (Canvas/PixiJS/Three.js/Phaser) |
| `gameglue-demo` | game | GameGlue + React Router SPA, 데모 앱 |

### AI 컨텍스트 (1종)

| boilerplate | 카테고리 | 특징 |
|-------------|---------|------|
| `react-router-ssr-mcp` | ai-context | React Router SSR + MCP Server + SQLite, Docker |

## 복제 명령

```bash
# === 웹앱 ===
npx degit k-codepoet/my-boilerplates/web/react-router-ssr-cloudflare apps/web
npx degit k-codepoet/my-boilerplates/web/react-router-spa-cloudflare apps/web
npx degit k-codepoet/my-boilerplates/web/react-router-ssr apps/web
npx degit k-codepoet/my-boilerplates/web/react-router-spa apps/web
npx degit k-codepoet/my-boilerplates/web/tanstack-start-ssr apps/web
npx degit k-codepoet/my-boilerplates/web/tanstack-router-spa apps/web

# === CLI/TUI ===
npx degit k-codepoet/my-boilerplates/cli/ratatui-rs apps/cli
npx degit k-codepoet/my-boilerplates/cli/bubbletea-go apps/cli
npx degit k-codepoet/my-boilerplates/cli/ink-ts apps/cli

# === 데스크톱 앱 ===
npx degit k-codepoet/my-boilerplates/native-app/tauri-react-router apps/desktop
npx degit k-codepoet/my-boilerplates/native-app/tauri-react apps/desktop

# === 봇/프로세서 ===
npx degit k-codepoet/my-boilerplates/bot/slack-processor-ts apps/bot
npx degit k-codepoet/my-boilerplates/bot/slack-processor-ts-cloudflare apps/bot
npx degit k-codepoet/my-boilerplates/bot/slack-processor-python apps/bot

# === 게임 ===
npx degit k-codepoet/my-boilerplates/game/gameglue-framework apps/game
npx degit k-codepoet/my-boilerplates/game/gameglue-demo apps/game

# === AI 컨텍스트 ===
npx degit k-codepoet/my-boilerplates/ai-context/react-router-ssr-mcp apps/ai-context
```

## 복제 후 작업 (카테고리별)

| 카테고리 | 의존성 설치 | 빌드 확인 | 로컬 실행 |
|----------|-----------|----------|----------|
| web, bot(TS), game | `pnpm install` | `pnpm build` | `pnpm dev` |
| cli/ratatui-rs | - | `cargo build` | `cargo run` |
| cli/bubbletea-go | - | `go build ./cmd` | `go run ./cmd` |
| cli/ink-ts | `pnpm install` | `pnpm build` | `pnpm dev` |
| native-app | `pnpm install` | `pnpm tauri:build` | `pnpm tauri:dev` |
| bot/python | `uv venv && source .venv/bin/activate && uv pip install -e .` | - | `python -m src.main` |
| ai-context | `pnpm install` | `pnpm build` | `pnpm dev` |

## 사용자 대화 가이드

boilerplate 선택 시 다음 순서로 질문:

### 1단계: 프로젝트 유형

```
어떤 종류의 프로젝트인가요?

1. 웹앱 (프론트엔드/풀스택)
2. CLI/TUI (명령줄 도구)
3. 데스크톱 앱 (Tauri)
4. 봇/프로세서 (Slack 등)
5. 게임
6. AI 컨텍스트 앱 (MCP 서버)
```

### 2단계: 카테고리별 세부 질문

웹앱이면 프레임워크 → 렌더링 → 배포 순서로 질문.
CLI면 언어 선택. 데스크톱이면 페이지 구조. 봇이면 배포 환경.

### 3단계: 확인

```
선택: {카테고리} / {boilerplate-name}
→ degit 경로: k-codepoet/my-boilerplates/{category}/{name}

이대로 진행할까요? (y/n)
```

## craftify 권장 사항

> **웹앱의 경우, craftify는 Cloudflare + SSR (react-router-ssr-cloudflare)을 기본 권장합니다.**

이유:
1. **엣지 SSR**: 사용자와 가까운 곳에서 렌더링
2. **무료 티어**: 대부분의 PoC에 충분
3. **Git 연동 배포**: 푸시만 하면 자동 배포
4. **글로벌 CDN**: 별도 설정 없이 전 세계 빠른 응답

단, 다음 경우는 예외:
- 기존 k8s 인프라 활용 필요 → Docker
- Workers 제한 초과 예상 → Docker SSR
- 극도로 단순한 정적 사이트 → SPA
- Type-safe routing 중시 → TanStack

## 외부 참조

- https://github.com/k-codepoet/my-boilerplates - Boilerplate 저장소
