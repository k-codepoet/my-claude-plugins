---
name: deploy
description: Cloudflare 배포 설정 및 실행. wrangler 설정 가이드, 배포 명령 안내. /craftify:deploy 형태로 호출.
---

# Deploy Skill

**Cloudflare Workers/Pages**로 배포합니다.

## 사용법

```
/craftify:deploy [command]
```

### 명령어

| 명령어 | 설명 |
|--------|------|
| (없음) | 배포 가이드 + 실행 |
| `setup` | Cloudflare 설정만 |
| `run` | 배포 실행 |
| `status` | 배포 상태 확인 |

## 배포 방식 (통일)

SSR/SPA 모두 **Dashboard에서 Git 연결** 방식으로 통일:
- 최초 1회 Dashboard 설정
- 이후 push마다 자동 배포
- PR에 Preview URL 자동 코멘트

| 구분 | SSR (Workers) | SPA (Pages) |
|------|--------------|-------------|
| boilerplate | `react-router-cloudflare` | `react-router-spa` |
| 배포 대상 | Workers & Pages | Pages |
| Dashboard 경로 | Workers & Pages → Create | Workers & Pages → Create |
| Preview URL | 자동 생성 | 자동 생성 |

## 동작

### 1. 프로젝트 확인

- Craftify 프로젝트인지 확인
- SSR/SPA 타입 감지 (wrangler.toml 유무)
- Git 저장소 상태 확인

### 2. 배포 설정 (Dashboard - 최초 1회)

```
📋 Cloudflare 배포 설정

⚠️ 최초 1회 Dashboard에서 Git 연결이 필요합니다.

1. GitHub에 push (main 브랜치)
2. Cloudflare Dashboard → Workers & Pages → "Create"
3. "Import a repository" 선택
4. GitHub 저장소 선택
5. Build settings:
   - Build command: pnpm build
   - Build output directory: build/client (SPA) / 자동 감지 (SSR)
6. "Save and Deploy"
```

### 3. 자동 배포 (Git 연결 후)

연결 완료 후 자동 동작:
- **main 브랜치 push** → Production 배포
- **다른 브랜치 push** → Preview URL 생성
- **PR 생성** → PR 코멘트에 Preview URL 자동 추가

### 4. Preview URL

| 타입 | Production URL | Preview URL |
|------|---------------|-------------|
| SSR | `{name}.{account}.workers.dev` | PR/브랜치별 자동 생성 |
| SPA | `{project}.pages.dev` | `{hash}.{project}.pages.dev` |

**목표 달성**: main = Production, 브랜치 = Preview (자동)

## wrangler.toml 설정

```toml
#:schema node_modules/wrangler/config-schema.json
name = "your-app-name"  # ← 이 부분 수정
compatibility_date = "2024-11-18"
compatibility_flags = ["nodejs_compat"]
main = "./workers/app.ts"
assets = { directory = "./build/client" }

[observability]
enabled = true
```

## 배포 흐름 (SSR/SPA 공통)

```
[로컬 개발]
    ↓ pnpm build (빌드 확인)
    ↓ GitHub push (main 브랜치)
    ↓ Dashboard에서 Git 연결 (최초 1회)
[Production 배포 완료]
    ↓ 이후 main push → 자동 배포
    ↓ 브랜치/PR push → Preview URL 자동 생성
```

## Progressive Disclosure

- 처음에는 설정 단계만 안내
- 설정 완료 후 배포 명령 안내
- 배포 성공 후 자동 배포 옵션 제안

## 출력 예시

### 미설정 시
```
🔨 Craftify Deploy

wrangler.toml 설정이 필요합니다.

1. apps/web/wrangler.toml 열기
2. name을 프로젝트 이름으로 변경
3. `npx wrangler login`으로 인증
4. `/craftify:deploy run`으로 배포

상세 가이드: .craftify/guides/02-cloudflare-setup.md
```

### 설정 완료 시
```
🔨 Craftify Deploy

✅ wrangler.toml 설정 확인
✅ Cloudflare 인증 확인

배포를 진행합니다...
cd apps/web && pnpm deploy
```

## 규칙

- wrangler.toml 설정은 사용자에게 안내만 (자동 수정 안 함)
- 배포 전 설정 상태 확인
- 에러 시 트러블슈팅 가이드 제공
