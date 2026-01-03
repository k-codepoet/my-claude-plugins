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

## 동작

### 1. 프로젝트 확인

- Craftify 프로젝트인지 확인
- SSR/SPA 타입 감지
- `wrangler.toml` 설정 상태 확인

### 2. Cloudflare 설정 가이드

wrangler.toml이 기본값이면 설정 안내:

```
📋 Cloudflare 배포 설정

1. wrangler.toml 수정:
   - name: "your-app-name"  ← 프로젝트 이름 입력

2. Cloudflare 로그인:
   npx wrangler login

3. 배포:
   pnpm deploy
```

### 3. 배포 실행

설정이 완료되었으면:

```bash
cd apps/web && pnpm deploy
```

### 4. 자동 배포 안내 (선택)

GitHub 연동 시:
```
🔄 자동 배포 설정

1. GitHub에 push
2. Cloudflare Dashboard → Pages → 프로젝트 연결
3. 이후 push마다 자동 배포
```

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

## 배포 흐름

```
[로컬 개발]
    ↓ /craftify:deploy setup
[wrangler.toml 설정]
    ↓ npx wrangler login
[Cloudflare 인증]
    ↓ pnpm deploy
[배포 완료]
    ↓ (선택) GitHub 연동
[자동 배포]
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
