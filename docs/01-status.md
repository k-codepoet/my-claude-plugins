# Status - 현재 상태 진단

> 2026-03-07 기준. 에이전트 분석 결과 종합.

## 전체 요약

| 항목 | 상태 | 비고 |
|------|------|------|
| 마켓플레이스 구조 | OK | marketplace.json 8개 플러그인 등록 |
| CLAUDE.md (개발자 가이드) | OK | 248줄, 스키마/컨벤션 잘 정리 |
| README.md (사용자 대면) | OUTDATED | archived 플러그인 active 표시, 버전 불일치 |
| docs/ 표지판 문서 | MISSING | 이 문서로 신규 생성 |
| 플러그인 간 파이프라인 | DOCUMENTED | CLAUDE.md에만 존재, 사용자 대면 문서 없었음 |

## 플러그인별 상태

### 등록 vs 실제 불일치

| marketplace.json 등록 | plugin.json 버전 | README.md 표기 | 불일치 |
|----------------------|------------------|----------------|--------|
| forgeify | 3.0.0 | 1.3.0 | 버전 불일치 |
| gemify | 2.0.0 | 1.9.0 | 버전 불일치 |
| namify | 2.0.0 | 1.0.0 | 버전 불일치 |
| craftify | 1.0.0 | 0.1.0 | 버전 불일치 |
| terrafy | 4.0.0 | 1.0.0 | 버전 불일치 |
| shellify | 1.0.0 | README에 없음 | 누락 |
| git-branch-strategy | 1.1.0 | README에 없음 | 누락 |
| my-devops-tools | 1.0.0 | README에 없음 | 누락 |

### README.md 잘못된 항목

- `homeserver-gitops` → `_archived/`로 이동했으나 README에 active로 표시
- `ubuntu-dev-setup` → `_archived/`로 이동했으나 README에 active로 표시
- `opsify-codepoet` → marketplace.json에 미등록, 빈 placeholder

## craftify <-> my-boilerplates 정합성 진단

### 문제 1: 레포 이름 불일치

| 위치 | 참조하는 이름 | 실제 이름 |
|------|-------------|----------|
| craftify/skills/poc/references/boilerplate.md | `k-codepoet/craftify-boilerplates` | `k-codepoet/my-boilerplates` |
| craftify/skills/boilerplate-guide/SKILL.md | `k-codepoet/craftify-boilerplates` | `k-codepoet/my-boilerplates` |

**영향**: degit 복제 명령이 실패함. `npx degit k-codepoet/craftify-boilerplates/...` → 404

### 문제 2: 보일러플레이트 커버리지 부족

craftify가 알고 있는 boilerplate:

| craftify 매핑 | my-boilerplates 실제 |
|--------------|---------------------|
| web/ react-router-ssr-cloudflare | web/ react-router-ssr-cloudflare |
| web/ react-router-spa-cloudflare | web/ react-router-spa-cloudflare |
| web/ react-router-ssr | web/ react-router-ssr |
| web/ react-router-spa | web/ react-router-spa |
| (없음) | web/ tanstack-start-ssr |
| (없음) | web/ tanstack-router-spa |
| (없음) | cli/ ratatui-rs, bubbletea-go, ink-ts |
| (없음) | native-app/ tauri-react-router, tauri-react |
| (없음) | bot/ slack-processor-ts, -cloudflare, -python |
| (없음) | game/ gameglue-framework, gameglue-demo |
| (없음) | ai-context/ react-router-ssr-mcp |

**커버리지**: 4/17 (23.5%) - web React Router 변형만 지원

### 문제 3: 기술 스택은 정렬됨

| 항목 | craftify 기대 | my-boilerplates 실제 | 정합 |
|------|-------------|---------------------|------|
| Package Manager | pnpm | pnpm v10.12+ | OK |
| Framework | React Router v7 | React Router v7 | OK |
| Styling | Tailwind CSS v4 | Tailwind CSS v4 | OK |
| Build | Vite | Vite 7 | OK |
| Deploy | Cloudflare Workers/Pages | Cloudflare Workers/Pages | OK |
| 경로 별칭 | `~/*` → `./app/*` | `~/*` → `./app/*` | OK |

### 문제 4: setup-wizard 에이전트 범위

- webapp만 지원 (future: slack-app, discord-app 언급하나 미구현)
- bot, cli, native-app, game 카테고리 선택 플로우 없음

## 문서 표지판 역할 진단

| 필요한 표지판 | 존재 여부 | 위치 |
|-------------|----------|------|
| "이 저장소는 뭔가" 한 문장 | 부분적 | README.md 첫줄 (너무 간략) |
| 플러그인 전체 지도 | 없음 | CLAUDE.md에 아키텍처만 |
| 파이프라인 흐름도 | 없음 | CLAUDE.md inter-plugin 섹션만 |
| 시작하는 법 (Quick Start) | 부분적 | README.md 설치 섹션 |
| craftify+boilerplates 연결 가이드 | 없음 | 새로 필요 |
| 각 플러그인 한줄 요약 + 링크 | 구식 | README.md 테이블 업데이트 필요 |
