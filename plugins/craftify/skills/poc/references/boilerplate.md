# Boilerplate 사용법

## 소스 저장소

```
https://github.com/k-codepoet/craftify-boilerplates
```

## Boilerplate 매핑 테이블

| 플랫폼 | 렌더링 | boilerplate | 설명 |
|--------|--------|-------------|------|
| Cloudflare | SSR | `react-router-ssr-cloudflare` | Cloudflare Workers에서 SSR |
| Cloudflare | SPA | `react-router-spa-cloudflare` | Cloudflare Pages 정적 배포 |
| Docker | SSR | `react-router-ssr` | Node.js SSR (Docker, k8s 호환) |
| Docker | SPA | `react-router-spa` | nginx SPA (Docker, 정적 호스팅) |

## 복제 명령 (degit 사용)

```bash
# Cloudflare SSR
npx degit k-codepoet/craftify-boilerplates/web/react-router-ssr-cloudflare apps/web

# Cloudflare SPA
npx degit k-codepoet/craftify-boilerplates/web/react-router-spa-cloudflare apps/web

# Docker SSR
npx degit k-codepoet/craftify-boilerplates/web/react-router-ssr apps/web

# Docker SPA
npx degit k-codepoet/craftify-boilerplates/web/react-router-spa apps/web
```

## 복제 후 작업

```bash
# 1. package.json name 수정
# @boilerplates/web-react-router-{type} → @apps/{product}

# 2. 의존성 설치
pnpm install

# 3. 빌드 확인
pnpm build

# 4. 로컬 실행
pnpm dev
```

## turborepo 구조

복제 후 생성할 파일:
- `turbo.json`
- `package.json` (루트)
- `pnpm-workspace.yaml`
- `CRAFTIFY.md`
- `.craftify/guides/`

상세 구조는 `/craftify:create` 스킬 참조.

## 플랫폼별 특징

### Cloudflare

- **SSR**: Cloudflare Workers에서 서버 렌더링
- **SPA**: Cloudflare Pages 정적 호스팅
- `wrangler.toml` 설정 포함
- `pnpm deploy`로 배포

### Docker/Self-hosted

- **SSR**: Node.js 서버 (Dockerfile 포함)
- **SPA**: nginx 정적 서버 (Dockerfile 포함)
- `docker-compose.yml` 포함
- k8s, 클라우드 VM 등 자유롭게 배포

## 외부 참조

- https://github.com/k-codepoet/craftify-boilerplates - Boilerplate 저장소
