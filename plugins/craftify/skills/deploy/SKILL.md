---
name: deploy
description: Cloudflare 배포 설정 및 실행. Dashboard Git 연결 방식으로 SSR/SPA 통일.
allowed-tools: Read, Bash, Glob
argument-hint: "[setup|status]"
---

# Deploy Skill

**Cloudflare Workers/Pages**로 배포합니다.

## 배포 방식 (통일)

SSR/SPA 모두 **Dashboard에서 Git 연결** 방식:
- 최초 1회 Dashboard 설정
- 이후 push마다 자동 배포
- PR에 Preview URL 자동 코멘트

| 구분 | SSR (Workers) | SPA (Pages) |
|------|--------------|-------------|
| boilerplate | `react-router-cloudflare` | `react-router-spa` |
| Dashboard 경로 | Workers & Pages → Create | Workers & Pages → Create |
| Preview URL | 자동 생성 | 자동 생성 |

## 워크플로우 (3단계)

### 1. 프로젝트 확인

- SSR/SPA 타입 감지 (wrangler.toml 유무)
- Git 저장소 상태 확인

### 2. Dashboard 설정 (최초 1회)

```
📋 Cloudflare 배포 설정

1. GitHub에 push (main 브랜치)
2. Cloudflare Dashboard → Workers & Pages → "Create"
3. "Import a repository" 선택
4. GitHub 저장소 선택
5. Build settings:
   - Build command: pnpm build
   - Build output directory: build/client
6. "Save and Deploy"
```

### 3. 자동 배포 (연결 후)

- **main push** → Production 배포
- **브랜치 push** → Preview URL 생성
- **PR 생성** → PR 코멘트에 Preview URL

## Preview URL

| 타입 | Production | Preview |
|------|-----------|---------|
| SSR | `{name}.workers.dev` | 자동 생성 |
| SPA | `{project}.pages.dev` | `{hash}.{project}.pages.dev` |

## 규칙

- Dashboard 설정은 안내만 (사용자가 직접 수행)
- 배포 전 로컬 빌드 확인 권장
- 에러 시 `references/troubleshooting.md` 참조

## References

- `references/wrangler-config.md` - wrangler.toml 설정
- `references/troubleshooting.md` - 에러 해결
