# wrangler.toml 설정

## SSR (Workers) 설정

```toml
#:schema node_modules/wrangler/config-schema.json
name = "your-app-name"  # ← 프로젝트 이름으로 변경
compatibility_date = "2024-11-18"
compatibility_flags = ["nodejs_compat"]
main = "./workers/app.ts"
assets = { directory = "./build/client" }

[observability]
enabled = true
```

## 필수 수정 항목

| 항목 | 설명 |
|------|------|
| `name` | Cloudflare에서 사용할 프로젝트 이름 |

## 선택 수정 항목

| 항목 | 기본값 | 설명 |
|------|--------|------|
| `compatibility_date` | 2024-11-18 | Workers 호환성 날짜 |
| `main` | ./workers/app.ts | 엔트리 파일 |
| `assets.directory` | ./build/client | 정적 파일 경로 |

## SPA (Pages) 설정

SPA는 wrangler.toml이 필요 없음. Dashboard에서 Build settings만 설정:

| 항목 | 값 |
|------|-----|
| Build command | `pnpm build` |
| Build output directory | `build/client` |
