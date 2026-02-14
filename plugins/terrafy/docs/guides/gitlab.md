# GitLab CE (Self-hosted)

NAS(DS220+)에서 GitLab CE를 Portainer 스택으로 운영.

## 접근 방법

### 웹 UI

```
https://gitlab.home.codepoet.site
```

Split DNS → Mac Mini Traefik (TLS 종료, ACME `*.home.codepoet.site`) → NAS Traefik(:8880) → GitLab(:80)

### Git Clone

**SSH (권장):**

```bash
# Tailscale Magic DNS 경유 (직접 NAS:20022)
git clone ssh://git@codepoet-nas:20022/group/project.git

# ~/.ssh/config 설정 후 단축 형태
git clone gitlab-nas:group/project.git
```

**HTTPS:**

```bash
git clone https://gitlab.home.codepoet.site/group/project.git
```

### SSH 접근 규칙

| URL | 동작 | 이유 |
|-----|------|------|
| `git@gitlab.home.codepoet.site:20022` | O | Split DNS → Mac Mini Traefik TCP(:20022) → NAS:20022 |
| `git@codepoet-nas:20022` | O | Magic DNS → NAS IP 직접 |

Mac Mini Traefik이 TCP 포워딩으로 `:20022` → NAS`:20022`를 중계하므로,
`gitlab.home.codepoet.site:20022`로 SSH 접근 가능.

## SSH 설정

`~/.ssh/config.d/gitlab-ssh`:

```
Host gitlab-ssh
    HostName gitlab.home.codepoet.site
    User git
    Port 20022
```

SSH 키는 GitLab 웹에서 등록: User Settings → SSH Keys → Add new key

## 배포 정보

| 항목 | 값 |
|------|-----|
| 이미지 | `gitlab/gitlab-ce:18.8.2-ce.0` |
| 배포 방식 | Portainer GitOps 스택 |
| HTTP 포트 | 미노출 (Traefik gateway 네트워크) |
| Registry | `gitlab-registry.home.codepoet.site` (Traefik, 포트 미노출) |
| SSH 포트 | 20022 |
| 데이터 경로 | `/volume1/workspaces/k-codepoet/my-devops/infra/codepoet-nas/gitlab-ce/data/` |
| healthcheck | 비활성화 (Traefik 호환) |
| Bootstrap Layer | 3 (Vault 무관) |

## 운영 참고

### Traefik 호환

- GitLab 이미지에 내장 HEALTHCHECK가 있음
- Traefik v3는 `health:starting` 상태의 컨테이너를 라우팅에서 제외
- GitLab은 NAS에서 부팅에 5-10분 소요 → 그동안 라우팅 안됨
- 해결: compose에서 `healthcheck: disable: true` 명시

### Portainer 스택 배포 시 주의

- compose에서 새 Docker 네트워크를 생성하면 Portainer Agent 배포 실패할 수 있음
- `gateway` 외부 네트워크만 사용 (`gitlab-internal` 등 추가 네트워크 금지)

### 버전 업그레이드

- GitLab은 메이저 버전 건너뛰기 불가
- 업그레이드 경로 확인: https://docs.gitlab.com/ee/update/index.html
- 현재 버전: 18.8.2-ce.0

### 백업

```bash
# NAS에서 실행
docker exec gitlab gitlab-backup create
# 백업 위치: data/data/backups/
```

## Container Registry

`gitlab-registry.home.codepoet.site`로 Docker 이미지 push/pull 가능. HTTPS 지원.

### 트래픽 흐름

```
docker push/pull
  → Split DNS → Mac Mini Traefik (TLS 종료, ACME *.home.codepoet.site)
    → NAS Traefik (:8880, HTTP)
      → GitLab 컨테이너 (:5050, registry_nginx)
        → Registry (:5000, 내부)
```

- `external_url`과 `registry_external_url`은 `https://`로 설정
- GitLab nginx/registry_nginx는 HTTP로 유지 (TLS는 Mac Mini Traefik이 처리)
- `X-Forwarded-Proto: https` 헤더로 upstream HTTPS 인식
- JWT token realm도 `https://gitlab.home.codepoet.site/jwt/auth`로 응답 → 각 머신에 `insecure-registries` 설정 불필요

### 사용법

```bash
# 로그인 (PAT에 read_registry, write_registry 스코프 필요)
docker login gitlab-registry.home.codepoet.site -u <username>

# 이미지 push
docker tag myimage gitlab-registry.home.codepoet.site/<group>/<project>/<image>:<tag>
docker push gitlab-registry.home.codepoet.site/<group>/<project>/<image>:<tag>

# 이미지 pull
docker pull gitlab-registry.home.codepoet.site/<group>/<project>/<image>:<tag>
```

### 주의사항

- PAT에 `read_registry`/`write_registry` 스코프가 있어야 push/pull 가능
- Traefik 멀티 서비스: 한 컨테이너에 서비스가 여럿이면 라우터마다 `.service` 라벨 명시 필수
- Registry 데이터는 `data/data/gitlab-rails/shared/registry/`에 저장 (기존 data 볼륨에 포함)

## CI/CD (GitLab Runner)

### Runner 구성

| Runner | Device | Executor | Tags | 용도 |
|--------|--------|----------|------|------|
| mac-mini-runner (arm64) | Mac Mini 1 | docker (DinD) | `mac-mini`, `arm64`, `docker` | 빌드 전담 (buildx 멀티플랫폼) |
| linux-runner (amd64) | Linux | docker (DinD) | `linux`, `amd64`, `docker` | 경량 작업 (deploy, test 등) |

### Runner 용도별 관리 전략

**원칙:** 빌드(Docker buildx)는 Mac Mini, 경량 작업(deploy/test)은 아무 Runner.

| Job 유형 | CI tags 지정 | 실행 Runner | 이유 |
|----------|-------------|-------------|------|
| Docker buildx (멀티플랫폼) | `tags: [mac-mini]` | Mac Mini | arm64 네이티브 + amd64 QEMU |
| 단일 아키텍처 빌드 | `tags: [mac-mini]` 또는 `tags: [linux]` | 해당 Runner | 네이티브 빌드 |
| deploy (git push, image tag 업데이트) | 미지정 | 아무 Runner | 경량, CPU 불필요 |
| test / lint | 미지정 | 아무 Runner | 경량 |

**왜 빌드는 Mac Mini 전담인가:**
- buildx 멀티플랫폼 빌드 시, arm64가 네이티브로 빌드되고 amd64만 QEMU 에뮬레이션
- 반대로 Linux Runner에서 빌드하면 amd64만 네이티브이고 arm64를 QEMU로 해야 하는데, Rust 빌드 같은 무거운 작업은 QEMU arm64 에뮬레이션이 비현실적으로 느림 (30분+ 소요)
- Mac Mini(arm64)에서 amd64 QEMU 에뮬레이션은 상대적으로 빠름

**`.gitlab-ci.yml` 예시:**

```yaml
build:
  stage: build
  tags:
    - mac-mini  # 빌드는 반드시 Mac Mini
  image: docker:latest
  services:
    - name: docker:dind
      alias: docker
  # ...

deploy:
  stage: deploy
  # tags 미지정 → 아무 Runner에서 실행
  image: alpine:latest
  # ...
```

**두 Runner 모두 `run_untagged: true`** → tag 없는 job은 양쪽 모두 수용 가능.

### Runner 등록 절차

#### 1. GitLab에서 Runner 토큰 생성

Admin → CI/CD → Runners → New instance runner
- Tags: `docker,dind,linux,amd64`
- Run untagged jobs: Yes

#### 2. Runner 컨테이너에서 등록

```bash
ssh codepoet-linux-1 "docker exec gitlab-runner-linux gitlab-runner register \
  --non-interactive \
  --url 'https://gitlab.home.codepoet.site' \
  --token 'glrt-YOUR_TOKEN' \
  --executor 'docker' \
  --docker-image 'docker:latest' \
  --docker-privileged \
  --docker-volumes '/certs/client' \
  --description 'linux-runner (amd64)' \
  --tag-list 'docker,dind,linux,amd64'"
```

- `url`: HTTPS 경유 (Mac Mini Traefik TLS 종료 → NAS:8880 → GitLab)

#### 3. config.toml 수동 수정 (필수)

등록 후 자동 생성된 config.toml에 다음을 추가/수정해야 합니다.

```bash
ssh codepoet-linux-1 "docker exec -it gitlab-runner-linux vi /etc/gitlab-runner/config.toml"
```

**수정할 항목:**

```toml
[[runners]]
  clone_url = "https://gitlab.home.codepoet.site"  # ← 추가
  [runners.docker]
    extra_hosts = ["gitlab.home.codepoet.site:192.168.0.48", "gitlab-registry.home.codepoet.site:192.168.0.48"]  # ← 추가
    dns = ["100.100.100.100", "8.8.8.8"]                       # ← 추가
```

**전체 config.toml 예시:**

```toml
concurrent = 2

[[runners]]
  name = "linux-runner (amd64)"
  url = "https://gitlab.home.codepoet.site"
  token = "glrt-YOUR_TOKEN"
  executor = "docker"
  clone_url = "https://gitlab.home.codepoet.site"
  [runners.docker]
    image = "docker:latest"
    privileged = true
    volumes = ["/certs/client", "/cache"]
    extra_hosts = ["gitlab.home.codepoet.site:192.168.0.48", "gitlab-registry.home.codepoet.site:192.168.0.48"]
    dns = ["100.100.100.100", "8.8.8.8"]
```

#### 4. Runner 재시작

```bash
ssh codepoet-linux-1 "docker restart gitlab-runner-linux"
```

### config.toml 각 설정의 역할

CI에서 `docker push`를 실행하면 DinD daemon이 registry에 HTTPS 요청을 보냅니다.

```
docker login/push (job container, Docker client)
  → DinD daemon (service container)
    → HTTPS: gitlab-registry.home.codepoet.site/v2/ (registry 접근)
    → HTTPS: gitlab.home.codepoet.site/jwt/auth     (JWT 인증)
```

| 설정 | 값 | 적용 대상 | 역할 |
|------|-----|----------|------|
| `url` | `https://gitlab.home.codepoet.site` | Runner 컨테이너 | GitLab API 통신, artifact 업로드 |
| `clone_url` | `https://gitlab.home.codepoet.site` | job container | Git clone 경로 |
| `extra_hosts` | `gitlab.home.codepoet.site:192.168.0.48`, `gitlab-registry.home.codepoet.site:192.168.0.48` | DinD `/etc/hosts` | JWT auth, registry 접근 시 Mac Mini Traefik 경유 |
| `dns` | `100.100.100.100, 8.8.8.8` | DinD 내부 컨테이너 | Tailscale DNS로 `gitlab-registry` → Mac Mini Tailscale IP |

**HTTPS 통일 — 모든 트래픽이 Mac Mini Traefik을 경유:**

```
Runner/Job/DinD → gitlab.home.codepoet.site:443
  → extra_hosts → Mac Mini(192.168.0.48):443
    → Mac Mini Traefik (TLS 종료, 인증서: *.home.codepoet.site)
      → NAS Traefik(:8880, HTTP)
        → GitLab(:80)
```

- `url`, `clone_url` 모두 HTTPS로 통일 → Runner/Job 동일 경로
- docker-compose.yml `extra_hosts`도 Mac Mini IP(192.168.0.48)로 통일
- NAS:443은 DSM이 응답(인증서 불일치)하므로 반드시 Mac Mini 경유 필요

### .gitlab-ci.yml 작성 가이드

#### DinD Docker Build + Registry Push 템플릿

```yaml
stages:
  - build

.docker-build:
  stage: build
  image: docker:latest
  services:
    - name: docker:dind
      alias: docker
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
    REGISTRY_URL: gitlab-registry.home.codepoet.site
  before_script:
    - echo "$CI_REGISTRY_PASSWORD" | docker login $REGISTRY_URL -u $CI_REGISTRY_USER --password-stdin
```

- `DOCKER_TLS_CERTDIR`: job ↔ DinD 간 TLS 통신용 (registry TLS와 별개)
- `CI_REGISTRY_USER` / `CI_REGISTRY_PASSWORD`: GitLab이 job마다 자동 주입 (`gitlab-ci-token`)
- `REGISTRY_URL`: registry 도메인 (변수로 분리하여 재사용)

#### Monorepo 태그 기반 빌드

monorepo에서 패키지별 태그로 빌드를 트리거:

```
태그 규칙: {package-path}/{version}
예: web/react-router-spa/v2026.02.08
```

```yaml
build-react-router-spa:
  extends: .docker-build
  rules:
    - if: '$CI_COMMIT_TAG =~ /^web\/react-router-spa\/v.+/'
  variables:
    PKG_DIR: web/react-router-spa
    IMAGE_NAME: ${REGISTRY_URL}/k-codepoet/my-boilerplates/web/react-router-spa
  script:
    - VERSION=${CI_COMMIT_TAG##*/}
    - docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest ${PKG_DIR}
    - docker push ${IMAGE_NAME}:${VERSION}
    - docker push ${IMAGE_NAME}:latest
```

새 패키지 추가 시: `rules`의 태그 패턴과 `PKG_DIR`, `IMAGE_NAME`만 변경하여 job 복사.

#### 태그 push 방법

```bash
# 태그 생성 및 push
git tag web/react-router-spa/v2026.02.08
git push origin web/react-router-spa/v2026.02.08

# 태그 삭제 후 재시도
git tag -d web/react-router-spa/v2026.02.08
git push origin :refs/tags/web/react-router-spa/v2026.02.08
git tag web/react-router-spa/v2026.02.08
git push origin web/react-router-spa/v2026.02.08
```

### 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `x509: certificate is valid for *.tinysolver.synology.me` | DinD가 NAS:443(DSM)에 접속 | `extra_hosts`에서 Mac Mini IP(192.168.0.48)로 변경 |
| `repository not found` (clone 실패) | `clone_url`에 IP 직접 사용 → Host header 불일치 | `clone_url`에 도메인 사용 (`http://gitlab.home.codepoet.site`) |
| `405 Not Allowed` (manifest PUT) | DinD가 HTTP로 registry 접근 | `extra_hosts`로 Mac Mini HTTPS 경유, `--insecure-registry` 제거 |
| YAML 문법 에러 (`nested array`) | `\|\|` 가 YAML block scalar로 해석 | 셸 명령어를 따옴표로 감싸기: `"cmd \|\| true"` |
| `network not found` | DinD에서 호스트 Docker 네트워크 접근 불가 | `network_mode = ""` (빈 문자열) |
| `dial tcp 192.168.0.48:8880: connection refused` (artifact upload) | `url`이 HTTP:8880인데 `extra_hosts`가 Mac Mini(8880 없음)로 해석 | `url`을 `https://gitlab.home.codepoet.site`로 변경 (Mac Mini:443 경유) |
| `405 Not Allowed` (checking for jobs) | Runner `url`이 HTTP인데 `extra_hosts`가 잘못된 IP/포트로 해석 | `url`을 HTTPS로, docker-compose `extra_hosts`를 Mac Mini IP로 통일 |

## GitLab CLI (glab)

`glab`은 GitLab 공식 CLI 도구. MR 생성/조회/코멘트 등을 커맨드라인에서 수행.

### 설치 현황

| 머신 | 방식 | 경로 | 버전 |
|------|------|------|------|
| MacBook Air | brew | `glab` (PATH) | v1.82.0 |
| codepoet-linux-1 | 바이너리 | `~/bin/glab` | v1.82.0 |
| codepoet-mac-mini-1 | 바이너리 | `~/bin/glab` | v1.82.0 |
| codepoet-mac-mini-2 | 바이너리 | `~/bin/glab` | v1.82.0 |
| codepoet-nas | **미사용** | — | — |

**NAS 정책:** NAS에서는 TLS 경로 문제(Split DNS → Mac Mini Traefik 경유 불가)로 `glab` CLI 사용 불가. GitLab REST API 직접 호출(`scripts/gitlab-api.sh`)로 대체.

### 설정 파일

**Linux:** `~/.config/glab-cli/config.yml`
**macOS:** `~/Library/Application Support/glab-cli/config.yml`

```yaml
git_protocol: ssh
host: gitlab.home.codepoet.site
telemetry: false
hosts:
    gitlab.home.codepoet.site:
        api_protocol: https
        api_host: gitlab.home.codepoet.site
        token: <PAT with api,write_repository scopes>
        container_registry_domains: gitlab-registry.home.codepoet.site
        git_protocol: ssh
        user: choigawoon
```

### 인증

```bash
# 대화형 로그인
glab auth login --hostname gitlab.home.codepoet.site

# 상태 확인
glab auth status --hostname gitlab.home.codepoet.site
```

PAT 필요 스코프: `api`, `write_repository`
생성: `https://gitlab.home.codepoet.site/-/user_settings/personal_access_tokens?scopes=api,write_repository`

### 주요 명령어

```bash
# 프로젝트 조회
glab repo view k-codepoet/my-kanban --output json

# MR 목록
glab mr list --output json --repo k-codepoet/my-kanban

# MR 생성
glab mr create --source-branch feature --target-branch main --title "title" --repo k-codepoet/my-kanban

# MR 조회
glab mr view <iid> --output json --repo k-codepoet/my-kanban

# MR 코멘트 (API 경유)
glab api projects/5/merge_requests/<iid>/notes
glab api projects/5/merge_requests/<iid>/discussions

# MR 체크아웃
glab mr checkout <iid>
```

### 설치/업데이트 방법

```bash
# 최신 버전 확인
curl -s "https://gitlab.com/api/v4/projects/34675721/releases" | python3 -c "import json,sys;print(json.load(sys.stdin)[0]['tag_name'])"

# Linux (x86_64)
curl -sSL "https://gitlab.com/gitlab-org/cli/-/releases/v1.82.0/downloads/glab_1.82.0_linux_amd64.tar.gz" | tar xz -C /tmp && cp /tmp/bin/glab ~/bin/

# macOS (Apple Silicon)
curl -sSL "https://gitlab.com/gitlab-org/cli/-/releases/v1.82.0/downloads/glab_1.82.0_darwin_arm64.tar.gz" | tar xz -C /tmp && cp /tmp/bin/glab ~/bin/
```

`~/bin`이 PATH에 있어야 함. 없으면 `~/.zshrc`에 `export PATH="$HOME/bin:$PATH"` 추가.

## API 스크립트

`scripts/gitlab-api.sh` — GitLab API v4 헬퍼. Vault에서 PAT를 자동 로드.

### 인증

PAT는 Vault `secret/common/gitlab`에 저장:

```bash
# Vault에서 자동 로드 (VAULT_TOKEN 필요)
export VAULT_TOKEN='hvs.xxxxx'

# 또는 환경변수 직접 설정
export GITLAB_URL='https://gitlab.home.codepoet.site'
export GITLAB_TOKEN='glpat-xxxxx'
```

### 사용법

```bash
# 연결 테스트
./scripts/gitlab-api.sh test

# 프로젝트
./scripts/gitlab-api.sh projects list
./scripts/gitlab-api.sh projects get <id>
./scripts/gitlab-api.sh projects create <name> [--group <id>] [--visibility private|internal|public]
./scripts/gitlab-api.sh projects delete <id>

# Merge Requests
./scripts/gitlab-api.sh mrs list <project_id>
./scripts/gitlab-api.sh mrs create <project_id> --source <branch> --target <branch> --title "title"
./scripts/gitlab-api.sh mrs merge <project_id> <mr_iid>
./scripts/gitlab-api.sh mrs comment <project_id> <mr_iid> "comment body"

# 이슈
./scripts/gitlab-api.sh issues list <project_id>
./scripts/gitlab-api.sh issues create <project_id> --title "title" [--description "desc"]
./scripts/gitlab-api.sh issues comment <project_id> <issue_iid> "comment body"

# 그룹
./scripts/gitlab-api.sh groups list
```
