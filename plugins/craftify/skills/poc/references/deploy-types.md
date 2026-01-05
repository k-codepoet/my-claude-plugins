# SSR vs SPA 배포 차이

## 배포 방식 (통일)

SSR/SPA 모두 **Dashboard에서 Git 연결** 방식으로 통일됩니다.

| 구분 | SSR (Workers) | SPA (Pages) |
|------|--------------|-------------|
| boilerplate | `react-router-cloudflare` | `react-router-spa` |
| 배포 대상 | Workers & Pages | Pages |
| 최초 설정 | Dashboard에서 Git 연결 | Dashboard에서 Git 연결 |
| Preview 배포 | 자동 | 자동 |

## 공통 배포 플로우 (SSR/SPA)

### 최초 배포 (Dashboard - 1회)
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

### 자동 배포 (Git 연결 후)
- `main` 브랜치 push → Production 배포
- 다른 브랜치 push → Preview URL 자동 생성
- PR 생성 → PR 코멘트에 Preview URL 자동 추가

## Preview URL

| 타입 | Production URL | Preview URL |
|------|---------------|-------------|
| SSR | `{name}.{account}.workers.dev` | PR/브랜치별 자동 생성 |
| SPA | `{project}.pages.dev` | `{hash}.{project}.pages.dev` |

**목표 달성**: main = Production, 브랜치 = Preview (자동)

## SSR vs SPA 선택 기준

| 상황 | 권장 |
|------|------|
| 서버 로직 필요 (API 호출, 외부 서비스 연동) | SSR |
| 정적 콘텐츠 위주, 목업/프로토타입 | SPA |
| 빌드 속도 중요 | SPA |
| SEO 중요 | SSR |
