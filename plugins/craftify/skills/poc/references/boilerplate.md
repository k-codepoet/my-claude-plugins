# Boilerplate 사용법

## 소스 저장소

```
https://github.com/k-codepoet/craftify-boilerplates
├── web/
│   ├── react-router-cloudflare/  # SSR (Cloudflare Workers)
│   ├── react-router-spa/         # SPA (정적 배포)
│   ├── react-router-vercel/      # (예정)
│   ├── tanstack-start-cloudflare/ # (예정)
│   └── nextjs-vercel/            # (예정)
├── api/
│   └── hono-cloudflare/          # (예정)
└── lib/
    └── typescript-package/       # (예정)
```

## 복제 명령 (degit 사용)

```bash
# SSR (Cloudflare Workers)
npx degit k-codepoet/craftify-boilerplates/web/react-router-cloudflare apps/web

# SPA (정적 배포)
npx degit k-codepoet/craftify-boilerplates/web/react-router-spa apps/web
```

## 로컬 개발용 (cp 사용)

```bash
# 로컬에 클론해둔 경우
cp -r ~/k-codepoet/my-boilerplates/web/react-router-cloudflare apps/web
cp -r ~/k-codepoet/my-boilerplates/web/react-router-spa apps/web
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

## 외부 참조

- https://github.com/k-codepoet/craftify-boilerplates - Boilerplate 저장소
- `~/k-codepoet/my-boilerplates/README.md` - 로컬 클론 (개발용)
