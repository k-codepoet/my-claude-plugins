# Boilerplate 사용법

## 소스 경로

```
~/k-codepoet/my-materials/authored-repos/ai-devteam/boilerplates/web/
├── react-router-cloudflare/  # SSR (Cloudflare Workers)
└── react-router-spa/         # SPA (정적 배포)
```

## 복제 명령

```bash
# SSR
cp -r ~/k-codepoet/my-materials/authored-repos/ai-devteam/boilerplates/web/react-router-cloudflare apps/web

# SPA
cp -r ~/k-codepoet/my-materials/authored-repos/ai-devteam/boilerplates/web/react-router-spa apps/web
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

- `~/k-codepoet/my-materials/authored-repos/ai-devteam/boilerplates/README.md` - 공식 사용법
