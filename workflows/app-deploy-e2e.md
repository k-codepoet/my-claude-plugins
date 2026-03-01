# 앱 서비스 End-to-End 배포 워크플로우

> 커스텀 앱을 홈랩에 처음부터 끝까지 배포하는 통합 가이드.
> **실제 사례:** rehab-crm (React Router v7 SSR) 배포 과정을 따라가며 설명한다.

## 전체 흐름 (Architecture Overview)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        App Deployment Pipeline                               │
│                                                                              │
│  ┌─────────────┐    ┌──────────────────┐    ┌────────────────────────────┐  │
│  │  앱 Repo     │    │  GitLab CI       │    │  Portainer GitOps          │  │
│  │  (GitLab CE) │───→│  (Mac Mini 2     │───→│  (my-devops repo)          │  │
│  │              │    │   shell runner)   │    │                            │  │
│  │ Dockerfile   │    │  buildx          │    │  docker-compose.yml        │  │
│  │ .gitlab-ci   │    │  linux/amd64     │    │  portainer-gitops.sh       │  │
│  │ 소스코드      │    │  linux/arm64     │    │  STACKS 등록               │  │
│  └─────────────┘    └────────┬─────────┘    └────────────┬───────────────┘  │
│                              │                           │                   │
│                              ▼                           ▼                   │
│                    ┌──────────────────┐    ┌────────────────────────────┐    │
│                    │  GitLab Registry │    │  Target Device             │    │
│                    │  gitlab-registry │◄───│  (Linux / Mac / NAS)       │    │
│                    │  .home.codepoet  │    │  docker pull + run         │    │
│                    │  .site           │    │                            │    │
│                    └──────────────────┘    └────────────┬───────────────┘    │
│                                                        │                    │
│                                                        ▼                    │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Traefik Chain (트래픽 라우팅)                                        │   │
│  │                                                                      │   │
│  │  외부: Client → Cloudflare → cloudflared(NAS) → Mac Mini Traefik     │   │
│  │        → chain → NAS Traefik → Linux Traefik → 서비스 컨테이너       │   │
│  │                                                                      │   │
│  │  내부: Client → Split DNS → Mac Mini Traefik (TLS 종료)              │   │
│  │        → chain → NAS Traefik → Linux Traefik → 서비스 컨테이너       │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 핵심 개념: Two-Repo 협업 패턴

홈랩에서 커스텀 앱을 배포하려면 **두 개의 repo**가 협업한다:

```
┌─────────────────────────────┐     ┌─────────────────────────────┐
│  앱 Repo (GitLab CE)         │     │  인프라 Repo (my-devops)      │
│  예: poc-rehab-crm           │     │  GitHub + GitLab 미러        │
│                              │     │                              │
│  • 소스코드                    │     │  • docker-compose.yml        │
│  • Dockerfile.prod           │     │  • portainer-gitops.sh       │
│  • .gitlab-ci.yml            │     │  • Traefik labels            │
│                              │     │  • 문서 (docs/)              │
│  결과: Registry에 이미지 push   │     │  결과: Portainer가 이미지 pull │
└─────────────────────────────┘     └─────────────────────────────┘
```

이 분리 덕분에 앱 개발과 인프라 설정을 독립적으로 관리할 수 있다.

---

## Phase 0: 사전 준비 및 계획

배포를 시작하기 전에 결정해야 할 항목들.

### 0-1. 배포 대상 디바이스 선택

| 디바이스 | IP | 적합한 서비스 | 네트워크 이름 |
|----------|-----|--------------|--------------|
| Mac Mini 1 (M1) | 192.168.0.48 | 주력 서비스 (Vault 연동 필요 시) | `traefik` |
| Mac Mini 2 (M4) | 192.168.0.37 | 빌드 전담 (보통 배포 대상 아님) | `traefik` |
| Linux | 192.168.0.34 | 경량 서비스, Vault 불필요 서비스 | `traefik` |
| NAS (DS220+) | 192.168.0.14 | 저전력 상시 서비스 | `gateway` |

> **rehab-crm 사례:** Linux (192.168.0.34) 선택. Vault 연동 불필요, amd64 네이티브 실행.

### 0-2. Runner 선택

| Runner | 디바이스 | Executor | Tags | 용도 |
|--------|---------|----------|------|------|
| mac-mini-2-shell | Mac Mini 2 | shell | `shell`, `mac-mini-2` | **멀티플랫폼 buildx** (arm64 네이티브 + QEMU amd64) |
| mac-mini-runner | Mac Mini 1 | docker (DinD) | `mac-mini`, `arm64`, `docker` | 범용 Docker 빌드 |
| linux-runner | Linux | docker (DinD) | `linux`, `amd64`, `docker` | 경량 작업 |

> **멀티플랫폼 빌드 → Mac Mini 2 shell runner 사용 (권장)**
> DinD executor에서 buildx를 사용하면 TLS 인증서 이슈, 캐시 휘발 등 문제가 발생할 수 있다.
> Mac Mini 2 shell runner는 호스트 Docker를 직접 사용하여 이 문제를 완전히 회피한다.

> **rehab-crm 실제 경험:** 처음 Linux DinD runner(`tags: [linux]`)로 시도 → buildx docker-container driver에서
> TLS 인증서 에러 발생 → Mac Mini 2 shell runner(`tags: [shell, mac-mini-2]`)로 전환하여 해결.
> 이 경험이 "멀티플랫폼 buildx는 Mac Mini 2 shell runner" 원칙의 근거다.

### 0-3. 포트 할당 확인

호스트 포트 바인딩이 필요한 경우 `docs/reference/ports.md` 확인. 새 서비스는 20000-29999 범위.

> **rehab-crm 사례:** 호스트 포트 바인딩 없음. Traefik 네트워크를 통해 컨테이너 포트(3000)만 노출.

### 0-4. 외부 공개 여부 결정

| 접근 방식 | 도메인 패턴 | 인증 |
|-----------|------------|------|
| 내부 전용 | `*.home.codepoet.site` | 없음 (Split DNS) |
| 외부 공개 (인증 없음) | `*.codepoet.site` | 없음 (Cloudflare Tunnel) |
| 외부 공개 (BasicAuth) | `*.codepoet.site` | BasicAuth middleware |

> **rehab-crm 사례:** 외부 공개 + BasicAuth. 내부는 인증 없이 접근.

### 0-5. Portainer Registry 인증 확인 (최초 1회)

Portainer가 GitLab Container Registry에서 이미지를 pull하려면, Registry 인증이 등록되어 있어야 한다. **전역 설정이므로 한 번만 하면 된다.**

1. Portainer 웹 UI → **Registries** → **Add registry**
2. 설정:

| 항목 | 값 |
|------|-----|
| Registry type | GitLab |
| Name | GitLab CE Registry |
| URL | `gitlab-registry.home.codepoet.site` |
| Authentication | enabled |
| Username | `gitlab-ci-token` |
| Password | GitLab PAT (`secret/data/common/gitlab` → `GITLAB_TOKEN`) |

> **이미 등록되어 있다면 건너뛴다.** 확인 방법: Portainer → Registries에 `gitlab-registry.home.codepoet.site`가 있는지 확인.

### 0-6. DNS 와일드카드 확인 (새 설정 불필요)

두 가지 와일드카드가 이미 설정되어 있으므로, 새 서비스마다 DNS를 추가할 필요가 **없다**:

| 도메인 | 방식 | 설명 |
|--------|------|------|
| `*.home.codepoet.site` | AdGuard DNS rewrite | → Mac Mini Tailscale IP (100.108.195.20) |
| `*.codepoet.site` | Cloudflare Tunnel | `cloudflared` 와일드카드 ingress → Mac Mini |

---

## Phase 1: 앱 Repo 준비

### 1-1. GitLab 프로젝트 생성

GitLab CE에 프로젝트를 만든다. 이미 존재하면 건너뛴다.

```bash
# 방법 1: glab CLI (권장)
glab api projects --method POST -f name=poc-rehab-crm -f namespace_id=2 -f visibility=private

# 방법 2: GitLab API 스크립트
./scripts/gitlab-api.sh projects create poc-rehab-crm --group 2 --visibility private

# 방법 3: GitLab 웹 UI
# https://gitlab.home.codepoet.site/projects/new
```

> **팁:** `namespace_id=2`는 `k-codepoet` 그룹. 프로젝트를 만들면 Container Registry가 자동 활성화된다.

### 1-2. Git Remote 설정

```bash
cd /path/to/app-repo

# GitLab CE를 origin으로 설정
git remote add origin ssh://git@codepoet-nas:20022/k-codepoet/poc-rehab-crm.git

# 또는 HTTPS
git remote add origin https://gitlab.home.codepoet.site/k-codepoet/poc-rehab-crm.git

# 첫 push
git push -u origin main
```

> **주의:** SSH clone에는 `~/.ssh/config`에 GitLab SSH 설정이 필요하다.
> ```
> Host codepoet-nas
>     HostName codepoet-nas  # Tailscale Magic DNS
>     User git
>     Port 20022
> ```

### 1-3. Dockerfile.prod 작성

프로덕션 빌드를 위한 multi-stage Dockerfile을 앱 repo 루트에 작성한다.

**rehab-crm의 실제 `Dockerfile.prod`:**

```dockerfile
# Rehab CRM Production - Multi-stage build (monorepo-aware)
# Build: docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile.prod .

# Stage 1: Build
FROM node:22-alpine AS builder

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# 모노레포 루트 파일 복사
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json apps/web/

# 의존성 설치 (dev deps 포함 - 빌드에 필요)
RUN pnpm install --frozen-lockfile

# 소스 복사 + 빌드
COPY apps/web/ apps/web/
RUN pnpm build

# Stage 2: Production
FROM node:22-alpine

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# 모노레포 루트 + production deps만 설치
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/web/package.json apps/web/
RUN pnpm install --frozen-lockfile --prod

# 빌드 결과물 복사
COPY --from=builder /app/apps/web/build ./apps/web/build

EXPOSE 3000

WORKDIR /app/apps/web
CMD ["npx", "react-router-serve", "./build/server/index.js"]
```

**작성 시 핵심 포인트:**

| 항목 | 설명 |
|------|------|
| **Multi-stage** | build stage에서 devDependency 포함 설치, production stage에서 prod만 설치 |
| **Monorepo** | 루트 lockfile → 워크스페이스 package.json → install → 소스 복사 순서 (캐시 최적화) |
| **Platform 독립** | `node:22-alpine`은 amd64/arm64 모두 지원 |
| **ENV** | `NODE_ENV=production`, 앱이 사용하는 `PORT` 등 명시 |

> **팁:** monorepo가 아닌 단일 앱이라면 구조가 훨씬 단순해진다:
> ```dockerfile
> FROM node:22-alpine AS builder
> WORKDIR /app
> COPY package.json pnpm-lock.yaml ./
> RUN pnpm install --frozen-lockfile
> COPY . .
> RUN pnpm build
>
> FROM node:22-alpine
> WORKDIR /app
> COPY --from=builder /app/build ./build
> COPY --from=builder /app/package.json ./
> RUN pnpm install --frozen-lockfile --prod
> CMD ["node", "build/index.js"]
> ```

### 1-4. .gitlab-ci.yml 작성

Mac Mini 2 shell runner에서 buildx 멀티플랫폼 빌드를 실행하는 CI 파이프라인.

**rehab-crm의 실제 `.gitlab-ci.yml`:**

```yaml
# GitLab CI/CD - poc-rehab-crm
#
# 멀티플랫폼 Docker 이미지 빌드 (linux/amd64 + linux/arm64)
# → GitLab Container Registry에 push
# → Portainer Stack에서 pull하여 배포
#
# 트리거: main 브랜치 push 또는 v* 태그
#
# Runner: mac-mini-2-shell (arm64, shell executor, Colima Docker)
#   tags: [shell, mac-mini-2]
#   buildx builder: multiarch (docker-container driver)
#
# Docker Registry:
#   gitlab-registry.home.codepoet.site/k-codepoet/poc-rehab-crm/web:{tag}

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
    # QEMU refresh (binfmt registration may expire after VM restart)
    - docker run --privileged --rm tonistiigi/binfmt --install all
    # Use existing multiarch builder
    - docker buildx use multiarch || docker buildx create --name multiarch --use --driver docker-container
    - docker buildx inspect --bootstrap
    # Login to GitLab Registry
    - docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
  script:
    - export PATH="/opt/homebrew/bin:$PATH"
    - |
      if [ -n "$CI_COMMIT_TAG" ]; then
        TAG="${CI_COMMIT_TAG}"
      else
        TAG="${CI_COMMIT_SHORT_SHA}"
      fi

      echo "Building multi-platform image: ${IMAGE_NAME}:${TAG}"

      docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -f Dockerfile.prod \
        -t ${IMAGE_NAME}:${TAG} \
        -t ${IMAGE_NAME}:latest \
        --push \
        .

      echo ""
      echo "=== Images pushed ==="
      echo "  ${IMAGE_NAME}:${TAG}"
      echo "  ${IMAGE_NAME}:latest"
```

**CI 설정 핵심 포인트:**

| 항목 | 값 / 설명 |
|------|-----------|
| **Runner tags** | `shell`, `mac-mini-2` — Mac Mini 2의 shell executor 지정 |
| **PATH 설정** | `/opt/homebrew/bin:$PATH` — Colima 환경의 docker 바이너리 경로 |
| **QEMU refresh** | `tonistiigi/binfmt --install all` — VM 재시작 시 binfmt 초기화 대응 |
| **Builder 재사용** | `docker buildx use multiarch || docker buildx create ...` — 기존 builder 우선 사용 |
| **태깅 전략** | `v*` 태그면 태그명, 아니면 short SHA. `latest`도 항상 push |
| **Registry 인증** | `CI_REGISTRY_USER`, `CI_REGISTRY_PASSWORD`는 GitLab이 자동 주입 |
| **timeout** | 20분 — 멀티플랫폼 빌드는 시간이 걸림 (QEMU 에뮬레이션) |

> **주의: `export PATH="/opt/homebrew/bin:$PATH"`가 `before_script`와 `script` 양쪽에 모두 필요하다.**
> Shell executor에서 `before_script`와 `script`는 별도 셸 세션으로 실행될 수 있다.

### 1-5. Push 및 CI 확인

```bash
# 코드 + Dockerfile + CI 설정을 push
git add Dockerfile.prod .gitlab-ci.yml
git commit -m "feat: add production Dockerfile and CI pipeline"
git push origin main

# CI 파이프라인 확인
# 방법 1: GitLab 웹 UI
#   https://gitlab.home.codepoet.site/k-codepoet/poc-rehab-crm/-/pipelines

# 방법 2: glab CLI
glab ci view --repo k-codepoet/poc-rehab-crm
```

> **팁:** 첫 빌드는 Docker 이미지 캐시가 없어 10-15분 걸릴 수 있다. 이후 빌드는 buildx 캐시로 더 빠르다.

---

## Phase 2: CI 파이프라인 검증

### 2-1. 파이프라인 성공 확인

GitLab UI 또는 glab CLI에서 파이프라인이 성공(green)했는지 확인.

**실패 시 체크리스트:**

| 증상 | 원인 | 해결 |
|------|------|------|
| `exec format error` | QEMU binfmt 미등록 | Mac Mini 2에서 `docker run --privileged --rm tonistiigi/binfmt --install all` |
| `buildx: command not found` | docker-buildx 미설치 | `brew install docker-buildx` (Mac Mini 2) |
| `unauthorized: authentication required` | Registry 인증 실패 | `docker login` 확인, GitLab 프로젝트 가시성 확인 |
| `Dockerfile.prod: not found` | 파일 경로 불일치 | 앱 repo 루트에 `Dockerfile.prod`가 있는지 확인 |
| 빌드 timeout (20m 초과) | QEMU 에뮬레이션 느림 | 의존성 캐시 최적화, timeout 늘리기 |

### 2-2. 이미지 확인

```bash
# GitLab UI에서 확인
# https://gitlab.home.codepoet.site/k-codepoet/poc-rehab-crm/container_registry

# 또는 CLI로 pull 테스트
docker pull gitlab-registry.home.codepoet.site/k-codepoet/poc-rehab-crm/web:latest
```

> **Portainer에서 Registry 인증이 필요하다.**
> Portainer > Registries에 GitLab Registry가 등록되어 있어야 스택 배포 시 이미지를 pull할 수 있다.
> - Registry: `gitlab-registry.home.codepoet.site`
> - Type: GitLab (4)
> - 인증: `gitlab-ci-token` + GitLab PAT

---

## Phase 3: 인프라 구성 (my-devops repo)

### 3-1. docker-compose.yml 작성

`my-devops/services/codepoet-{device}/{service}/docker-compose.yml`에 Portainer 스택용 compose를 작성.

**rehab-crm의 실제 `docker-compose.yml` (최종 버전 — BasicAuth 포함):**

```yaml
# Rehab CRM - Portainer GitOps Stack
# Linux (192.168.0.34)
#
# 이미지: GitLab CI 멀티플랫폼 빌드 → GitLab Registry push
# 라우팅: rehab-crm.home.codepoet.site → Linux Traefik → 이 컨테이너
#         rehab-crm.codepoet.site → Cloudflare Tunnel → Mac Mini Traefik → chain → Linux Traefik → 이 컨테이너
#
# Portainer Stack Variables: (없음 - 현재 시크릿 불필요)
#
# 인증: 외부(codepoet.site) → BasicAuth, 내부(home.codepoet.site) → 패스

services:
  rehab-crm:
    image: gitlab-registry.home.codepoet.site/k-codepoet/poc-rehab-crm/web:latest
    container_name: rehab-crm
    restart: unless-stopped
    environment:
      - NODE_ENV=production
      - PORT=3000
    labels:
      - "traefik.enable=true"
      # 내부 접근 (인증 없음)
      - "traefik.http.routers.rehab-crm-internal.rule=Host(`rehab-crm.home.codepoet.site`)"
      - "traefik.http.routers.rehab-crm-internal.entrypoints=web"
      - "traefik.http.routers.rehab-crm-internal.service=rehab-crm"
      # 외부 접근 (BasicAuth)
      - "traefik.http.routers.rehab-crm-external.rule=Host(`rehab-crm.codepoet.site`)"
      - "traefik.http.routers.rehab-crm-external.entrypoints=web"
      - "traefik.http.routers.rehab-crm-external.middlewares=rehab-crm-auth"
      - "traefik.http.routers.rehab-crm-external.service=rehab-crm"
      # BasicAuth middleware
      - "traefik.http.middlewares.rehab-crm-auth.basicauth.users=gemgem400:$$apr1$$.tCZtG0K$$m0DkHux/U/RIXcsWQh045/"
      # Service
      - "traefik.http.services.rehab-crm.loadbalancer.server.port=3000"
    networks:
      - traefik

networks:
  traefik:
    external: true
```

**compose 작성 핵심 체크리스트:**

- [ ] **이미지 경로**: `gitlab-registry.home.codepoet.site/k-codepoet/{repo}/{image}:latest`
- [ ] **네트워크**: 디바이스에 맞는 이름 (`traefik` 또는 `gateway`)
- [ ] **entrypoints**: Linux/Mac Mini 2/NAS는 `web`만 (체인 노드이므로 `websecure` 사용 불가)
- [ ] **split-router**: 외부 접근 시 처음부터 내부/외부 라우터 분리 패턴 적용
- [ ] **service 명시**: 라우터가 2개이면 양쪽 모두 `.service={name}` 명시 필수
- [ ] **`$$` 이스케이프**: htpasswd의 `$`를 `$$`로 이스케이프

> **주의 (흔한 실수):** 처음 배포 시 단일 라우터로 시작했다가 나중에 BasicAuth를 추가하면
> 라우터를 분리해야 하므로 재배포가 필요하다. **외부 공개 서비스는 처음부터 split-router 패턴을 적용**하는 것이 좋다.

#### 디바이스별 compose 템플릿 차이

| 항목 | Mac Mini 1 | Linux / Mac Mini 2 | NAS |
|------|-----------|-------------------|-----|
| entrypoints | `web,websecure` | `web` 만 | `web` 만 |
| TLS | `certresolver=cloudflare` | 없음 | 없음 |
| 네트워크 | `traefik` | `traefik` | `gateway` |
| 볼륨 (영속) | `/Volumes/mac-ext-storage/.{svc}/` | 사용자에게 확인 | 절대경로 호스트 마운트 |

### 3-2. htpasswd 생성 (BasicAuth 필요 시)

```bash
# htpasswd 명령어 사용
htpasswd -nb username password
# 출력 예: username:$apr1$xyz...$abc...

# htpasswd 없으면 openssl로 대체
printf "username:$(openssl passwd -apr1 password)\n"

# Docker로 실행
docker run --rm httpd:alpine htpasswd -nb username password
```

생성된 해시에서 `$`를 `$$`로 이스케이프:

```
# 원본:  gemgem400:$apr1$.tCZtG0K$m0DkHux/U/RIXcsWQh045/
# Compose용: gemgem400:$$apr1$$.tCZtG0K$$m0DkHux/U/RIXcsWQh045/
```

### 3-3. STACKS 배열에 등록

`scripts/portainer-gitops.sh`의 `STACKS` 배열에 새 서비스를 추가:

```bash
STACKS=(
    # 기존 스택들...

    # App services (GitLab Registry images)
    rehab-crm "linux:services/codepoet-linux-1/rehab-crm/docker-compose.yml"
    # 형식: {stack-name} "{endpoint}:{compose-path}"
    #   endpoint: mac-mini | mac-mini-2 | nas | linux
    #   compose-path: infra/ 또는 services/ 하위
    #   GitHub 소스: 뒤에 :github 추가 (기본은 GitLab)
)
```

### 3-4. Git Push

```bash
cd /home/choigawoon/k-codepoet/my-devops  # 디바이스별 경로 확인

git add services/codepoet-linux-1/rehab-crm/docker-compose.yml
git add scripts/portainer-gitops.sh
git commit -m "feat: add rehab-crm Portainer stack"
git push origin main  # GitLab + GitHub 동시 push (dual push URL)
```

### 3-5. Portainer 스택 생성

```bash
# Vault 토큰 설정 (GitLab repo 자격증명 로드에 필요)
export VAULT_TOKEN='hvs.xxxxx'

# 스택 생성
./scripts/portainer-gitops.sh create rehab-crm
```

> **주의:** `update` 명령은 DELETE + RECREATE 방식이므로 기존 데이터가 있는 서비스에는 주의.
> 최초 배포는 `create`를 사용한다.

---

## Phase 4: 네트워킹 및 DNS

### 4-1. Traefik 라우팅 (자동)

Docker labels로 Traefik에 등록되므로 별도 설정이 필요 없다. 스택이 배포되면 자동으로 라우팅된다.

**rehab-crm의 트래픽 경로:**

```
내부 (rehab-crm.home.codepoet.site):
  Client → Split DNS → Mac Mini Traefik (:443, TLS 종료)
    → Host 미매칭 → NAS Traefik (:8880, HTTP)
    → Host 미매칭 → Linux Traefik (:80)
    → Docker labels 매칭 → rehab-crm-internal 라우터 → :3000

외부 (rehab-crm.codepoet.site):
  Client → Cloudflare → cloudflared (NAS) → Mac Mini Traefik (:443, TLS 종료)
    → Host 미매칭 → NAS Traefik → Linux Traefik
    → Docker labels 매칭 → rehab-crm-external 라우터 → BasicAuth → :3000
```

### 4-2. DNS 설정

| 도메인 | DNS 유형 | 설정 | 자동? |
|--------|---------|------|-------|
| `*.home.codepoet.site` | Split DNS (Tailscale) | Mac Mini Tailscale IP로 해석 | 이미 설정됨 (와일드카드) |
| `*.codepoet.site` | Cloudflare DNS | Cloudflare Tunnel (Proxied) | 이미 설정됨 (와일드카드) |

> **결론:** 새 서비스를 위해 DNS를 별도 설정할 필요가 없다.
> 와일드카드 DNS가 이미 설정되어 있어, `{service}.home.codepoet.site`와 `{service}.codepoet.site` 모두
> 자동으로 Mac Mini Traefik으로 라우팅된다.

### 4-3. Cloudflare Tunnel (외부 접근)

`cloudflared`의 ingress 규칙이 `*.codepoet.site` 와일드카드로 설정되어 있으므로, 새 서비스를 위해 ingress를 추가할 필요가 없다.

> **주의:** 와일드카드가 아닌 특정 도메인 ingress를 사용하는 환경이라면 `cloudflared` 설정에 라우팅 규칙 추가가 필요하다.

---

## Phase 5: 검증

### 5-1. 컨테이너 상태 확인

```bash
# 대상 디바이스에서 (Linux의 경우)
ssh codepoet-linux-1 "docker ps | grep rehab-crm"
ssh codepoet-linux-1 "docker logs rehab-crm --tail 20"
```

### 5-2. 내부 접근 테스트

```bash
# HTTP 상태 코드 확인
curl -sk -o /dev/null -w "%{http_code}" https://rehab-crm.home.codepoet.site
# 기대값: 200

# 전체 응답 확인
curl -sk https://rehab-crm.home.codepoet.site | head -20
```

### 5-3. 외부 접근 테스트

```bash
# 인증 없이 → 401
curl -sk -o /dev/null -w "%{http_code}" https://rehab-crm.codepoet.site
# 기대값: 401

# BasicAuth 인증 → 200
curl -sk -o /dev/null -w "%{http_code}" -u username:password https://rehab-crm.codepoet.site
# 기대값: 200
```

> **BasicAuth가 없는 서비스는 외부 접근도 200이 정상이다.**

### 5-4. Portainer UI 확인

Portainer 웹 UI에서:
1. Environments → 해당 endpoint 선택
2. Stacks → `rehab-crm` 확인
3. Containers → 상태 확인 (running)

### 5-5. 문제 해결

| 증상 | 원인 | 해결 |
|------|------|------|
| 컨테이너 `ImagePullBackOff` | Registry 인증 실패 | Portainer Registries에 GitLab Registry 등록 확인 |
| 404 Not Found | Traefik 체인에서 Host 미매칭 | labels의 Host 규칙, 네트워크 이름 확인 |
| 502 Bad Gateway | 컨테이너 시작 전 또는 포트 불일치 | `loadbalancer.server.port` 값 확인, 앱 로그 확인 |
| 내부 OK, 외부 안됨 | Cloudflare Tunnel 또는 Mac Mini chain 문제 | cloudflared 로그 확인 |
| BasicAuth 401이 내부에서도 나옴 | 단일 라우터에 middleware 적용 | split-router 패턴으로 내부/외부 분리 |

---

## Phase 6: 문서화

배포 완료 후 아래 문서를 업데이트한다.

### 6-1. 서비스 문서 생성

`my-devops/docs/services/{service}.md` 생성. [`rehab-crm.md`](https://gitlab.home.codepoet.site/k-codepoet/my-devops/-/blob/main/docs/services/rehab-crm.md)를 템플릿으로 사용.

포함할 내용:
- 위치 (머신, 접속 URL)
- 아키텍처 다이어그램
- 트래픽 경로
- Docker Registry 정보
- 이미지 빌드 방식
- Bootstrap Layer
- 배포 이력

### 6-2. 레지스트리/참조 문서 업데이트

| 문서 | 업데이트 내용 |
|------|-------------|
| `docs/reference/stacks-registry.md` | 스택 등록 + 앱 서비스 테이블 |
| `docs/reference/deployed-services.md` | 서비스 목록에 추가 |
| `docs/architecture/current-structure.md` | 구조도 + 스택 테이블 |
| `docs/reference/ports.md` | 포트 바인딩이 있는 경우 |

### 6-3. 앱 Repo 문서 업데이트

앱 repo의 `CLAUDE.md` 또는 `README.md`에 Deployment 섹션 추가:

```markdown
## Deployment

- **프로덕션**: Linux (192.168.0.34) — Portainer GitOps Stack
- **이미지**: `gitlab-registry.home.codepoet.site/k-codepoet/poc-rehab-crm/web:latest`
- **CI/CD**: main push → GitLab CI buildx → Registry push → Portainer pull
- **내부 접속**: https://rehab-crm.home.codepoet.site
- **외부 접속**: https://rehab-crm.codepoet.site (BasicAuth)
```

---

## Gap Analysis: add-new-service.md만으로 충분한가?

### 커버리지 평가

| 단계 | add-new-service.md | 이 문서가 추가하는 내용 |
|------|-------------------|----------------------|
| **Phase 0: 계획** | 포트 할당만 언급 | 디바이스 선택, Runner 선택, 외부 공개 결정 |
| **Phase 1-1: GitLab 프로젝트 생성** | 미포함 | glab/API 스크립트/웹 UI 방법 |
| **Phase 1-2: Git Remote 설정** | 미포함 | SSH config, remote 설정, 첫 push |
| **Phase 1-3: Dockerfile.prod** | 미포함 (Step 0에서 건너뛰라고만 언급) | monorepo 대응 multi-stage 작성법 + 실제 예시 |
| **Phase 1-4: .gitlab-ci.yml** | 최소 예시만 (DinD 기반) | Shell runner 기반 실전 예시 + gotchas |
| **Phase 1-5: CI 확인** | 미포함 | 파이프라인 확인 방법, 첫 빌드 시간 안내 |
| **Phase 2: CI 검증** | 미포함 | 트러블슈팅 테이블, 이미지 pull 테스트 |
| **Phase 3-1: compose** | 템플릿 제공 (3종) | split-router 패턴 처음부터 적용 권장 |
| **Phase 3-2: htpasswd** | 생성법 + labels 예시 | `$$` 이스케이프 실제 예시 |
| **Phase 3-3: STACKS 등록** | 포함 | 동일 |
| **Phase 3-5: 스택 생성** | 포함 | 동일 |
| **Phase 4: 네트워킹** | Traefik labels만 | DNS 불필요 확인, Tunnel 와일드카드 설명 |
| **Phase 5: 검증** | curl 기본 3줄 | 내부/외부/BasicAuth 각각, 트러블슈팅 |
| **Phase 6: 문서화** | 체크리스트 5항목 | 앱 repo 문서까지 포함 |

### 커버리지 수치 (분석 기반)

| 문서 조합 | E2E 커버리지 | 비고 |
|-----------|------------|------|
| `add-new-service.md` 단독 (배포 전 원본) | **~30%** | Phase 3-5 일부만 |
| `add-new-service.md` (배포 후 업데이트 버전) | **~70%** | CI 예시, BasicAuth, 문서 체크리스트 추가됨 |
| 기존 workflow 문서들 조합 (`my-claude-plugins/`) | **~90%** | 개별 문서는 잘 되어있지만 통합 내러티브 부재 |
| **이 문서 (통합 E2E)** | **~100%** | 나머지 10% (Phase 0, 두 repo 협업, DNS 불필요 확인) 보충 |

### 결론

**`add-new-service.md`는 "인프라 측면"(Phase 3~5)에서는 충분하지만, "앱 측면"(Phase 0~2)에서는 크게 부족하다.**

구체적으로:

1. **앱 repo 초기화**(GitLab 프로젝트 생성, remote 설정)가 전혀 언급되지 않음
2. **Dockerfile.prod 작성**이 "건너뛰라"는 수준으로만 기술 — monorepo, multi-stage 패턴 없음
3. **CI 파이프라인**이 DinD 기반 최소 예시만 — 실전에서 사용하는 Shell runner + buildx 패턴이 없음
4. **CI 트러블슈팅**이 없어 첫 배포자가 막혔을 때 해결이 어려움
5. **"처음부터 split-router"** 권장이 없어, 나중에 BasicAuth를 추가하면 재배포 필요
6. **DNS/Tunnel은 설정 불필요**라는 확인이 없어 불필요한 시간 낭비 가능
7. **Portainer Registry 인증 설정**이 없어, 이미지 pull 실패 시 원인 파악이 어려움
8. **체인 노드 entrypoints** — 배포 전 원본에는 Linux 서비스에 `websecure`가 포함되어 있었음 (실배포 중 수정됨)

**이 문서는 `add-new-service.md` + 기존 워크플로우 문서들을 하나의 내러티브로 엮어**, 처음 배포하는 사람이 단일 문서만으로 전체 과정을 완료할 수 있도록 한다.

### 기존 문서와의 관계

```
이 문서 (통합 E2E)
  ├─ Phase 0-2: 앱 repo 준비 + CI (이 문서 고유)
  ├─ Phase 3-5: 인프라 + 검증
  │   ├── 상세: add-new-service.md (인프라 가이드)
  │   ├── 상세: gitlab-ci-multiplatform-portainer.md (CI 워크플로우)
  │   └── 상세: traefik-basicauth-external-only.md (BasicAuth 워크플로우)
  └─ Phase 6: 문서화 (이 문서 고유 — 앱 repo 문서 포함)
```

---

## 빠른 참조 (Quick Reference)

### 전체 명령어 요약

```bash
# === Phase 1: 앱 repo ===
# GitLab 프로젝트 생성
glab api projects --method POST -f name=poc-my-app -f namespace_id=2

# Remote 설정 + push
git remote add origin ssh://git@codepoet-nas:20022/k-codepoet/poc-my-app.git
git push -u origin main

# === Phase 2: CI 확인 ===
glab ci view --repo k-codepoet/poc-my-app

# === Phase 3: 인프라 (my-devops) ===
# compose 파일 작성 후
git add services/codepoet-linux-1/my-app/docker-compose.yml scripts/portainer-gitops.sh
git commit -m "feat: add my-app Portainer stack"
git push origin main

# 스택 생성
export VAULT_TOKEN='hvs.xxxxx'
./scripts/portainer-gitops.sh create my-app

# === Phase 5: 검증 ===
curl -sk -o /dev/null -w "%{http_code}" https://my-app.home.codepoet.site  # 200
curl -sk -o /dev/null -w "%{http_code}" https://my-app.codepoet.site        # 200 또는 401
```

### 관련 문서

| 문서 | 위치 | 내용 |
|------|------|------|
| 서비스 추가 가이드 | `my-devops/docs/guides/add-new-service.md` | 인프라 측면 서비스 추가 가이드 |
| GitLab CI/CD | `my-devops/docs/guides/gitlab.md` | Runner, Registry, CI 상세 |
| CI 멀티플랫폼 빌드 | `workflows/cicd-deploy/gitlab-ci-multiplatform-portainer.md` | CI → Portainer 워크플로우 |
| BasicAuth 외부 전용 | `workflows/networking/traefik-basicauth-external-only.md` | split-router BasicAuth |
| Traefik Chain | `my-devops/docs/architecture/traefik-chain.md` | 트래픽 라우팅 구조 |
| Stacks Registry | `my-devops/docs/reference/stacks-registry.md` | 전체 스택 등록 현황 |
| rehab-crm 서비스 문서 | `my-devops/docs/services/rehab-crm.md` | 실제 배포 결과 운영 문서 |
