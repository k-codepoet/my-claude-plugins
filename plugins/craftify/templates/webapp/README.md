# Webapp Templates

## Boilerplate 소스

React Router 공식 템플릿을 사용합니다:

```bash
# SSR (Cloudflare Workers)
npx degit reactrouter/templates/cloudflare apps/web

# SPA (정적 배포)
npx degit reactrouter/templates/spa apps/web
```

## 사용법

`/craftify:create webapp` 실행 시 위 명령어로 템플릿을 복제합니다.

## 템플릿 정보

### react-router-cloudflare (SSR)

| 항목 | 값 |
|------|---|
| 프레임워크 | React Router 7 |
| 렌더링 | SSR (Server-Side) |
| 배포 | Cloudflare Workers |
| 스타일링 | Tailwind CSS 4 |
| 빌드 | Vite 7 |

### react-router-spa (SPA)

| 항목 | 값 |
|------|---|
| 프레임워크 | React Router 7 |
| 렌더링 | CSR (Client-Side) |
| 배포 | Cloudflare Pages (정적) |
| 스타일링 | Tailwind CSS 4 |
| 빌드 | Vite 7 |
