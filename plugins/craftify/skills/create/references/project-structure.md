# 프로젝트 구조 상세

## 전체 구조

```
{name}/
├── apps/
│   └── web/
│       ├── app/
│       │   ├── root.tsx
│       │   ├── routes.ts
│       │   ├── routes/
│       │   │   └── home.tsx
│       │   ├── lib/
│       │   │   └── utils.ts
│       │   ├── app.css
│       │   └── entry.server.tsx
│       ├── workers/
│       │   └── app.ts
│       ├── package.json
│       ├── tsconfig.json
│       ├── vite.config.ts
│       ├── react-router.config.ts
│       ├── wrangler.toml
│       └── components.json
├── packages/
│   └── .gitkeep
├── turbo.json
├── package.json
├── pnpm-workspace.yaml
├── .gitignore
├── CRAFTIFY.md
└── .craftify/
    └── guides/
        ├── 01-local-dev.md
        ├── 02-cloudflare-setup.md
        └── 03-auto-deploy.md
```

## apps/web/ 구조

React Router 7 + Cloudflare Workers 기반 웹앱

### 주요 파일

| 파일 | 용도 |
|------|------|
| `app/root.tsx` | 루트 레이아웃 |
| `app/routes.ts` | 라우팅 설정 |
| `app/routes/home.tsx` | 홈 페이지 |
| `workers/app.ts` | Cloudflare Worker 진입점 |
| `wrangler.toml` | Cloudflare 설정 |

### 의존성

- React 19
- React Router 7
- Tailwind CSS 4
- Vite 7
- Wrangler (Cloudflare CLI)

## packages/ 구조

공유 패키지용 디렉토리 (향후 확장)

```
packages/
├── ui/           # 공유 UI 컴포넌트
├── config/       # 공유 설정
└── utils/        # 공유 유틸리티
```

## 설정 파일

### turbo.json

turborepo 태스크 설정

```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["build/**", ".react-router/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

### pnpm-workspace.yaml

모노레포 워크스페이스 설정

```yaml
packages:
  - "apps/*"
  - "packages/*"
```
