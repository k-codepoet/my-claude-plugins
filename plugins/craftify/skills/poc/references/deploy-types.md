# 배포 플랫폼별 가이드

## 플랫폼 선택 기준

| 상황 | 권장 플랫폼 |
|------|------------|
| 빠른 글로벌 배포 | Cloudflare |
| 엣지 컴퓨팅 필요 | Cloudflare |
| 기존 k8s/Docker 인프라 활용 | Docker |
| 셀프호스팅 필요 | Docker |
| 비용 최적화 (트래픽 많음) | Docker |

## SSR vs SPA 선택 기준

| 상황 | 권장 |
|------|------|
| 서버 로직 필요 (API 호출, 외부 서비스 연동) | SSR |
| SEO 중요 | SSR |
| 정적 콘텐츠 위주, 목업/프로토타입 | SPA |
| 빌드 속도 중요 | SPA |

---

## Cloudflare 배포

### SSR (Workers)

**boilerplate**: `react-router-ssr-cloudflare`

```bash
# 배포
pnpm deploy
```

- Cloudflare Workers에서 서버 렌더링
- `wrangler.toml` 설정 포함
- Production URL: `{name}.{account}.workers.dev`

### SPA (Pages)

**boilerplate**: `react-router-spa-cloudflare`

```bash
# 배포
pnpm deploy
```

- Cloudflare Pages 정적 호스팅
- `wrangler.toml` 설정 포함
- Production URL: `{project}.pages.dev`

### Cloudflare 공통 배포 플로우

**최초 배포 (Dashboard - 1회)**
```
1. GitHub에 push (main 브랜치)
2. Cloudflare Dashboard → Workers & Pages → "Create"
3. "Import a repository" 선택
4. GitHub 저장소 선택
5. Build settings:
   - Build command: pnpm build
   - Build output directory: build/client (SPA) / 자동 감지 (SSR)
6. "Save and Deploy"
```

**자동 배포 (Git 연결 후)**
- `main` 브랜치 push → Production 배포
- 다른 브랜치 push → Preview URL 자동 생성
- PR 생성 → PR 코멘트에 Preview URL 자동 추가

---

## Docker 배포

### SSR (Node.js)

**boilerplate**: `react-router-ssr`

```bash
# 빌드 & 실행
docker-compose up -d
```

- Node.js 서버에서 SSR
- `Dockerfile`, `docker-compose.yml` 포함
- 포트: 3000 (기본)

### SPA (nginx)

**boilerplate**: `react-router-spa`

```bash
# 빌드 & 실행
docker-compose up -d
```

- nginx로 정적 파일 서빙
- `Dockerfile`, `docker-compose.yml` 포함
- 포트: 80 (기본)

### Docker 공통 배포 플로우

**로컬 실행**
```bash
docker-compose up -d
```

**k8s 배포**
```bash
# 이미지 빌드 & 푸시
docker build -t {registry}/{image}:{tag} .
docker push {registry}/{image}:{tag}

# k8s 배포 (예시)
kubectl apply -f k8s/
```

**클라우드 VM 배포**
```bash
# SSH 접속 후
git clone {repo}
cd {project}
docker-compose up -d
```

---

## Preview URL 비교

| 플랫폼 | Production URL | Preview URL |
|--------|---------------|-------------|
| Cloudflare SSR | `{name}.{account}.workers.dev` | PR/브랜치별 자동 생성 |
| Cloudflare SPA | `{project}.pages.dev` | `{hash}.{project}.pages.dev` |
| Docker | 직접 설정 | 직접 설정 |
