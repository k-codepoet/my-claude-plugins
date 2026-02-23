# GitLab CI 멀티플랫폼 빌드 → Portainer 스택 배포

> 앱 repo에서 GitLab CI로 Docker 이미지를 빌드하고, my-devops Portainer 스택으로 배포하는 전체 과정.

## 전제 조건

- GitLab CE에 앱 repo 존재 (Container Registry 활성화)
- Mac Mini 2에 buildx 설치됨 (`multiarch` builder)
- Portainer에 GitLab Registry 인증 설정 완료

## 1단계: Production Dockerfile 작성

앱 repo 루트에 `Dockerfile.prod` 생성. monorepo인 경우 workspace 구조 반영 필수.

```dockerfile
# Build stage
FROM node:22-alpine AS builder
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app

# monorepo 루트 파일 먼저 복사 (lockfile 캐시 활용)
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json apps/web/
RUN pnpm install --frozen-lockfile

COPY apps/web/ apps/web/
RUN pnpm build

# Production stage
FROM node:22-alpine
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
ENV NODE_ENV=production PORT=3000

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json apps/web/
RUN pnpm install --frozen-lockfile --prod

COPY --from=builder /app/apps/web/build ./apps/web/build
WORKDIR /app/apps/web
EXPOSE 3000
CMD ["npx", "react-router-serve", "./build/server/index.js"]
```

## 2단계: .gitlab-ci.yml 작성

앱 repo에 `.gitlab-ci.yml` 생성. **Mac Mini 2 shell 러너** 사용 (arm64 네이티브 + QEMU amd64).

```yaml
stages:
  - build

variables:
  IMAGE_NAME: ${CI_REGISTRY_IMAGE}/web

docker-build:
  stage: build
  tags:
    - shell
    - mac-mini-2
  timeout: 20m
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v.+/'
    - if: '$CI_COMMIT_BRANCH == "main"'
  before_script:
    - export PATH="/opt/homebrew/bin:$PATH"
    - docker run --privileged --rm tonistiigi/binfmt --install all
    - docker buildx use multiarch || docker buildx create --name multiarch --use --driver docker-container
    - docker buildx inspect --bootstrap
    - docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
  script:
    - export PATH="/opt/homebrew/bin:$PATH"
    - |
      TAG="${CI_COMMIT_TAG:-${CI_COMMIT_SHORT_SHA}}"
      docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -f Dockerfile.prod \
        -t ${IMAGE_NAME}:${TAG} \
        -t ${IMAGE_NAME}:latest \
        --push .
```

### 주의사항

| 항목 | 설명 |
|------|------|
| **러너 선택** | Mac Mini 2 shell (arm64 네이티브). Linux DinD는 buildx TLS 에러 발생 |
| **QEMU refresh** | Colima VM 재시작 후 binfmt 재등록 필요 → `before_script`에 매번 실행 |
| **builder 재사용** | `docker buildx use multiarch \|\| docker buildx create ...` 패턴 |
| **amd64 에뮬레이션** | arm64 머신에서 QEMU로 amd64 빌드. 반대(Linux에서 arm64)보다 빠름 |

## 3단계: Portainer 스택 compose 작성

`my-devops/services/{device}/{service}/docker-compose.yml` 에 작성.

```yaml
services:
  my-service:
    image: gitlab-registry.home.codepoet.site/k-codepoet/{repo}/{image}:latest
    container_name: my-service
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    labels:
      - "traefik.enable=true"
      # 내부 접근 (인증 없음)
      - "traefik.http.routers.my-service-internal.rule=Host(`my-service.home.codepoet.site`)"
      - "traefik.http.routers.my-service-internal.entrypoints=web"
      - "traefik.http.routers.my-service-internal.service=my-service"
      # 외부 접근 (BasicAuth — 필요 시 middleware 활성화)
      - "traefik.http.routers.my-service-external.rule=Host(`my-service.codepoet.site`)"
      - "traefik.http.routers.my-service-external.entrypoints=web"
      # - "traefik.http.routers.my-service-external.middlewares=my-service-auth"
      - "traefik.http.routers.my-service-external.service=my-service"
      # BasicAuth middleware (필요 시 주석 해제)
      # - "traefik.http.middlewares.my-service-auth.basicauth.users=username:$$apr1$$xxxx$$xxxx"
      # Service (공유)
      - "traefik.http.services.my-service.loadbalancer.server.port=3000"
    networks:
      - traefik  # Linux/Mac은 traefik, NAS는 gateway

networks:
  traefik:
    external: true
```

> **BasicAuth 상세** → [Traefik BasicAuth 외부 전용](../networking/traefik-basicauth-external-only.md)

### Traefik Host 규칙

| 도메인 | 경로 | 용도 |
|--------|------|------|
| `*.home.codepoet.site` | Split DNS → Mac Mini Traefik → chain → 서비스 | 내부 접근 |
| `*.codepoet.site` | Cloudflare Tunnel → Mac Mini Traefik → chain → 서비스 | 외부 접근 |

외부 도메인은 cloudflared ingress가 `*.codepoet.site` 와일드카드이므로 별도 설정 불필요.

## 4단계: portainer-gitops.sh에 스택 등록

`scripts/portainer-gitops.sh`의 STACKS 배열에 추가:

```zsh
rehab-crm "linux:services/codepoet-linux-1/rehab-crm/docker-compose.yml"
```

형식: `"endpoint:compose_path"` (GitLab 소스 기본) 또는 `"endpoint:compose_path:github"` (GitHub 소스)

## 5단계: 배포

```bash
# 1. 앱 repo push → CI 자동 트리거
cd /path/to/app-repo
git push origin main

# 2. CI 완료 대기 (GitLab 파이프라인 확인)

# 3. my-devops에서 스택 생성
cd /path/to/my-devops
export VAULT_TOKEN='hvs.xxxxx'
./scripts/portainer-gitops.sh create rehab-crm

# 4. 확인
curl -sk https://rehab-crm.home.codepoet.site  # 내부
curl -sk https://rehab-crm.codepoet.site        # 외부 (Cloudflare Tunnel)
```

> **외부 접근 인증이 필요하면** → [Traefik BasicAuth 외부 전용](../networking/traefik-basicauth-external-only.md)

## 6단계: 문서 업데이트

| 파일 | 내용 |
|------|------|
| `docs/services/{service}.md` | 서비스 운영 문서 (my-kanban-server.md 패턴) |
| `docs/guides/gitlab.md` | buildx 관련 내용 추가 시 |
| `docs/machines/codepoet-mac-mini-2.md` | buildx 설치 정보 |

## 실제 적용 사례: rehab-crm

```
poc-rehab-crm (GitLab CE)
├── Dockerfile.prod          ← 프로덕션 멀티스테이지
├── .gitlab-ci.yml           ← Mac Mini 2 buildx
└── apps/web/                ← React Router v7 SSR

my-devops (이 repo)
├── services/codepoet-linux-1/rehab-crm/docker-compose.yml  ← Portainer 스택
└── scripts/portainer-gitops.sh                              ← STACKS에 등록
```

Registry 이미지: `gitlab-registry.home.codepoet.site/k-codepoet/poc-rehab-crm/web:latest`
