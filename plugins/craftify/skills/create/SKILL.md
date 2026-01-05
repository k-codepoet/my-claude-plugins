---
name: create
description: 새 프로젝트 생성. turborepo + boilerplate 복제. /craftify:create webapp my-app 형태로 호출.
---

# Create Skill

새 프로젝트를 **turborepo 기반**으로 생성합니다.

## 사용법

```
/craftify:create <type> <name> [options]
```

### 지원 타입

| 타입 | 설명 | 스택 |
|------|------|------|
| `webapp` | 웹 애플리케이션 | React Router 7 + Cloudflare |

### 옵션

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `--ssr` | SSR 모드 (Cloudflare Workers) | true |
| `--spa` | SPA 모드 (정적 배포) | false |
| `--path` | 생성 경로 | 현재 디렉토리 |

## 동작

1. **타입과 이름 확인**
   - `webapp` 타입이면 계속 진행
   - 이름 없으면 사용자에게 질문

2. **boilerplate 복제**
   - SSR: `react-router-cloudflare` 템플릿 사용
   - SPA: `react-router-spa` 템플릿 사용

3. **turborepo 구조 생성**
   ```
   {name}/
   ├── apps/
   │   └── web/          # boilerplate 복제
   ├── packages/         # 공유 패키지 (향후)
   ├── turbo.json
   ├── package.json
   ├── pnpm-workspace.yaml
   ├── CRAFTIFY.md       # 사용법 가이드
   └── .craftify/
       └── guides/       # 단계별 가이드
   ```

4. **CRAFTIFY.md 생성**
   - 사용법 (pnpm dev, pnpm build 등)
   - `/craftify:deploy` 안내
   - Progressive disclosure 철학 링크

5. **의존성 설치 안내**
   ```bash
   cd {name} && pnpm install
   ```

## Boilerplate 소스

로컬 boilerplate 경로:
```
~/k-codepoet/my-materials/authored-repos/ai-devteam/boilerplates/web/
├── react-router-cloudflare/  # SSR (Cloudflare Workers)
└── react-router-spa/         # SPA (정적 배포)
```

복제 명령:
```bash
# SSR
cp -r ~/k-codepoet/my-materials/authored-repos/ai-devteam/boilerplates/web/react-router-cloudflare apps/web

# SPA
cp -r ~/k-codepoet/my-materials/authored-repos/ai-devteam/boilerplates/web/react-router-spa apps/web

# package.json name 수정
# @boilerplates/web-react-router-{type} → @apps/{project-name}
```

플러그인 내 가이드 템플릿:
```
${CLAUDE_PLUGIN_ROOT}/templates/webapp/
├── guides/                   # 생성될 가이드 문서
└── README.md                 # 템플릿 정보
```

## 생성 파일 상세

### turbo.json
```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["build/**", ".react-router/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "typecheck": {}
  }
}
```

### package.json (루트)
```json
{
  "name": "{name}",
  "private": true,
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "typecheck": "turbo typecheck"
  },
  "devDependencies": {
    "turbo": "^2"
  },
  "packageManager": "pnpm@9.15.0"
}
```

### pnpm-workspace.yaml
```yaml
packages:
  - "apps/*"
  - "packages/*"
```

### CRAFTIFY.md
```markdown
# {name}

Craftify로 생성된 프로젝트입니다.

## Quick Start

\`\`\`bash
pnpm install
pnpm dev
\`\`\`

## 배포

배포 준비가 되면:
\`\`\`
/craftify:deploy
\`\`\`

## 구조

- `apps/web/` - 웹 애플리케이션
- `packages/` - 공유 패키지 (필요시 추가)

## 가이드

- `.craftify/guides/01-local-dev.md` - 로컬 개발
- `.craftify/guides/02-cloudflare-setup.md` - Cloudflare 설정
- `.craftify/guides/03-auto-deploy.md` - 자동 배포
```

### .craftify/guides/01-local-dev.md
```markdown
# 로컬 개발 가이드

## 시작하기

\`\`\`bash
pnpm dev
\`\`\`

http://localhost:5173 에서 확인

## 스크립트

| 명령어 | 설명 |
|--------|------|
| `pnpm dev` | 개발 서버 |
| `pnpm build` | 빌드 |
| `pnpm typecheck` | 타입 체크 |
```

## 규칙

- **Progressive Disclosure**: 배포 설정은 처음에 보여주지 않음
- 순수 코드만 생성, 인프라 설정은 `/craftify:deploy` 단계에서
- wrangler.toml의 name은 플레이스홀더로 두고 배포 시 설정 안내

## References

상세 형식과 예시는 `references/` 폴더 참조:
- `references/project-structure.md` - 프로젝트 구조 상세
