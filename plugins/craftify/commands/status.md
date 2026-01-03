---
name: status
description: Craftify 프로젝트 상태 표시
allowed-tools: Read, Bash, Glob
---

# /craftify:status

현재 Craftify 프로젝트의 상태를 표시합니다.

## 확인 항목

1. **프로젝트 감지**
   - `CRAFTIFY.md` 존재 여부
   - `turbo.json` 존재 여부

2. **구조 확인**
   - `apps/` 디렉토리
   - `packages/` 디렉토리

3. **앱 목록**
   - apps/ 하위 앱들
   - 각 앱의 타입 (webapp 등)

4. **의존성 상태**
   - `node_modules` 존재 여부
   - pnpm-lock.yaml 상태

5. **배포 설정**
   - wrangler.toml 설정 상태
   - Cloudflare 인증 상태

## 출력 예시

```
🔨 Craftify Status

프로젝트: my-app
경로: /path/to/my-app

📦 Apps
├── web (webapp/ssr)
│   ├── 의존성: ✅ 설치됨
│   └── 배포: ⚠️ wrangler.toml 설정 필요

📁 Packages
└── (없음)

🔧 다음 단계
- /craftify:deploy setup - 배포 설정
```

## 프로젝트 미감지 시

```
⚠️ Craftify 프로젝트가 아닙니다.

현재 경로: /path/to/current

새 프로젝트 생성:
/craftify:create webapp my-app
```
