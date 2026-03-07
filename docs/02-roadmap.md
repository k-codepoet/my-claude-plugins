# Roadmap - 스텝별 진행 계획

> 현재 상태(01-status.md)에서 의도(00-intent.md)까지 도달하기 위한 단계.

## Phase 1: 즉시 수정 (문서 정합성)

> 목표: 누구든 docs/를 열면 전체 그림을 즉시 파악

### Step 1.1: README.md 현행화
- [ ] archived 플러그인 (homeserver-gitops, ubuntu-dev-setup) 제거
- [ ] 신규 플러그인 추가 (shellify, git-branch-strategy, my-devops-tools)
- [ ] 각 플러그인 버전을 plugin.json 실제 값으로 갱신
- [ ] opsify-codepoet 빈 placeholder 정리 방침 결정
- [ ] 플러그인 테이블에 유형(Knowledge/Product/Infra/Automation) 컬럼 추가

### Step 1.2: craftify 레포 이름 수정
- [ ] `boilerplate.md`: `craftify-boilerplates` → `my-boilerplates` 전체 치환
- [ ] `boilerplate-guide/SKILL.md`: degit 경로 수정
- [ ] 수정 후 degit 명령 실제 테스트

## Phase 2: craftify 커버리지 확장

> 목표: my-boilerplates 17종 전체를 craftify가 안내할 수 있게

### Step 2.1: boilerplate-guide 매핑 테이블 확장

현재 의사결정 플로우:
```
SEO 필요? → SSR/SPA → 배포환경? → Cloudflare/Docker
```

확장 필요한 플로우:
```
프로젝트 유형?
├── 웹앱 → (현재 플로우 유지, TanStack 옵션 추가)
├── CLI/TUI → 언어 선택 (Rust/Go/TS)
├── 데스크톱 앱 → Tauri (멀티페이지/싱글페이지)
├── 봇/프로세서 → 플랫폼(Slack) + 런타임(Docker/Cloudflare/Python)
├── 게임 → GameGlue (framework/demo)
└── AI 컨텍스트 앱 → react-router-ssr-mcp
```

### Step 2.2: boilerplate.md 매핑 테이블 확장

추가할 항목:

| 카테고리 | boilerplate | degit 경로 |
|----------|------------|-----------|
| web | tanstack-start-ssr | `my-boilerplates/web/tanstack-start-ssr` |
| web | tanstack-router-spa | `my-boilerplates/web/tanstack-router-spa` |
| cli | ratatui-rs | `my-boilerplates/cli/ratatui-rs` |
| cli | bubbletea-go | `my-boilerplates/cli/bubbletea-go` |
| cli | ink-ts | `my-boilerplates/cli/ink-ts` |
| native-app | tauri-react-router | `my-boilerplates/native-app/tauri-react-router` |
| native-app | tauri-react | `my-boilerplates/native-app/tauri-react` |
| bot | slack-processor-ts | `my-boilerplates/bot/slack-processor-ts` |
| bot | slack-processor-ts-cloudflare | `my-boilerplates/bot/slack-processor-ts-cloudflare` |
| bot | slack-processor-python | `my-boilerplates/bot/slack-processor-python` |
| game | gameglue-framework | `my-boilerplates/game/gameglue-framework` |
| game | gameglue-demo | `my-boilerplates/game/gameglue-demo` |
| ai-context | react-router-ssr-mcp | `my-boilerplates/ai-context/react-router-ssr-mcp` |

### Step 2.3: setup-wizard 에이전트 확장
- [ ] 프로젝트 유형 질문에 webapp 외 카테고리 추가
- [ ] 카테고리별 후속 질문 분기 설계
- [ ] 복제 후 작업(post-clone) 카테고리별 차이 반영
  - web: pnpm install → build
  - cli/rust: cargo build
  - cli/go: go build
  - native-app: pnpm install → tauri:dev
  - bot: pnpm install (또는 uv venv for python)
  - game: pnpm install → dev

## Phase 3: 파이프라인 강화

> 목표: gemify → craftify → deploy 파이프라인이 끊김 없이 동작

### Step 3.1: gemify:poc → craftify:poc 연결 검증
- [ ] gemify:poc가 생성하는 POC.md 형식과 craftify:poc가 기대하는 형식 대조
- [ ] 카테고리 확장 시 POC.md에 프로젝트 유형 필드 추가 필요 여부 검토

### Step 3.2: craftify:deploy 카테고리별 배포 경로
- [ ] 현재: Cloudflare (Workers/Pages)만 지원
- [ ] Docker 배포 가이드 추가 (web/react-router-ssr, bot/slack-processor-ts)
- [ ] Tauri 빌드/배포 가이드 추가
- [ ] CLI npm publish 가이드 추가

### Step 3.3: 에러 핸들링 확장
- [ ] error-handling.md에 비-web 카테고리 에러 케이스 추가
- [ ] Rust/Go 빌드 에러, Tauri 빌드 에러, Python 환경 에러

## Phase 4: 문서 완성

> 목표: 표지판 문서 체계 완성

### Step 4.1: README.md 리뉴얼
- [ ] 플러그인 지도 (유형별 분류 테이블)
- [ ] 파이프라인 흐름도 (ASCII)
- [ ] Quick Start (3분 안에 첫 프로젝트 시작)
- [ ] docs/ 링크

### Step 4.2: docs/ 유지보수 규칙
- [ ] 이 3개 문서(intent/status/roadmap)를 living document로 유지
- [ ] 플러그인 변경 시 status 갱신 체크리스트 추가

---

## 우선순위 요약

| 순서 | 작업 | 영향도 | 난이도 |
|------|------|--------|--------|
| 1 | craftify 레포 이름 수정 | **Critical** - degit 실패 | 낮음 (텍스트 치환) |
| 2 | README.md 현행화 | High - 첫인상 | 낮음 |
| 3 | boilerplate 매핑 확장 | High - 커버리지 23%→100% | 중간 |
| 4 | setup-wizard 확장 | Medium - UX 개선 | 중간 |
| 5 | deploy 카테고리별 분기 | Medium - E2E 완성 | 높음 |
| 6 | README 리뉴얼 | Medium - 온보딩 | 중간 |
