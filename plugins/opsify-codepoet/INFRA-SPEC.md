# opsify-codepoet Infrastructure Spec

> codepoet 홈랩 인프라를 하나의 플러그인으로 운영하기 위한 설계 문서.
> 이 문서를 기반으로 opsify-codepoet 플러그인을 개발한다.

---

## 1. Infrastructure Overview

### 1.1 Machines

| Device | Arch | LAN IP | Tailscale IP | Tailscale Name | Role |
|--------|------|--------|-------------|----------------|------|
| Mac Mini 1 (M1) | arm64 | 192.168.0.48 | 100.108.195.20 | codepoet-mac-mini-1 | Entry point, TLS termination, Core services |
| Mac Mini 2 (M4) | arm64 | 192.168.0.36 | 100.120.134.19 | codepoet-mac-mini-2 | Standalone, CI/CD buildx runner |
| NAS (DS220+) | amd64 | 192.168.0.14 | 100.125.241.80 | codepoet-nas | Chain Node 2, GitLab CE, DNS, Tunnel |
| Linux (Ubuntu 24.04) | amd64 | 192.168.0.34 | 100.111.155.113 | codepoet-linux-1 | Chain Node 3, App services |
| Windows (RTX4090) | amd64 | 192.168.0.24 | 100.70.23.126 | codepoet-win | Portainer Agent only (GPU, Phase 5) |

### 1.2 Service Inventory

**Mac Mini 1 — Core/Entry Point**
- Infra (GitHub): traefik-mac, vault
- Services (GitLab): grafana, n8n, prefect, vaultwarden, authentik, gitlab-runner-mac, gitlab-runner-mac-dood, alertmanager, prometheus-mac
- Manual (Layer 1): portainer (server)

**NAS (DS220+) — Chain Node 2, GitLab**
- Infra (GitHub): traefik-nas, gitlab-ce, cloudflared, adguard-home
- Services (GitLab): prometheus-nas
- Non-Docker: MinIO (Synology package, :9000/:9001)
- Manual (Layer 1): portainer-agent

**Linux — Chain Node 3, App Services**
- Infra (GitHub): traefik-linux
- Services (GitLab): gitlab-runner-linux, gitlab-runner-linux-dood, rehab-crm, webtoon-maker, my-kanban-server, prometheus-linux
- Manual (Layer 1): portainer-agent

**Mac Mini 2 — Standalone**
- Infra (GitHub): traefik-mac2
- Services (GitLab): prometheus-mac2, sample-ssr, gameglue-demo, gameglue-framework
- Manual (Layer 1): portainer-agent

### 1.3 Bootstrap Layers

서비스 간 의존관계에 따른 부팅 순서:

```
Layer 1 (manual docker run): Portainer Server + Agents
  ↓
Layer 2 (Portainer GitOps, GitHub): vault, vaultwarden, traefik-nas, gitlab-ce, cloudflared, adguard-home, traefik-mac2, traefik-linux
  ↓
Layer 3 (Portainer GitOps, GitLab): gitlab-runner-mac, gitlab-runner-linux
  ↓
Layer 4 (Portainer GitOps, Vault-dependent): traefik-mac, grafana, n8n, prefect, authentik
```

---

## 2. Networking Architecture

### 2.1 Traffic Flow

```
[External] *.codepoet.site
  Client → Cloudflare CDN → cloudflared tunnel (NAS)
    → Mac Mini 1 Traefik :80/:443 (TLS terminate, ACME wildcard)
      ├─[priority 10+] Docker label match → local container
      ├─[priority 10] Direct route → Mac Mini 2 :80 (standalone)
      └─[priority 1] Chain fallback → NAS :8880 → Linux :80 → 404

[Internal] *.home.codepoet.site
  A) Tailscale Split DNS → Mac Mini Tailscale 100.108.195.20 → same chain
  B) AdGuard Home DNS → NAS Tailscale 100.125.241.80 → Mac Mini → same chain
```

### 2.2 Traefik Chain

| Node | Device | Port | TLS | Docker Network |
|------|--------|------|-----|----------------|
| Entry (Chain 1) | Mac Mini 1 | :80/:443/:20022 | ACME wildcard | `traefik` |
| Chain 2 | NAS | :8880 (DSM owns :80/:443) | None (HTTP) | `gateway` |
| Chain 3 (fallback) | Linux | :80 | None (HTTP) | `traefik` |
| Standalone | Mac Mini 2 | :80 | None | `traefik` |

**Router priority**: 100 = dashboard, 10+ = Docker labels, 1 = chain fallback.

### 2.3 DNS Management

| Layer | Domain | Target | Provider |
|-------|--------|--------|----------|
| External | `*.codepoet.site` | Cloudflare tunnel | Cloudflare |
| Internal (Tailscale) | `*.home.codepoet.site` | 100.108.195.20 (Mac Mini) | Tailscale Split DNS |
| Internal (LAN) | `*.home.codepoet.site` | 100.125.241.80 (NAS) → Mac Mini | AdGuard Home |

와일드카드 DNS로 개별 서비스별 설정 불필요.

### 2.4 Certificate Management

- ACME wildcard: `*.codepoet.site` + `*.home.codepoet.site`
- Challenge: Cloudflare DNS challenge (`CF_DNS_API_TOKEN` from Vault)
- Storage: Mac Mini 1 persistent volume
- Chain 하위 노드: TLS 없음 (HTTP only, Mac Mini에서 TLS 종단)

### 2.5 Authentication

**A. Traefik BasicAuth (simple, per-service)**
- Split-router 패턴: internal (*.home.*) = no auth, external (*.codepoet.site) = BasicAuth
- htpasswd in docker-compose labels (`$$` escaping)

**B. Authentik OIDC (full IdP)**
- Stack: Mac Mini 1, `auth.codepoet.site`
- Flow: Google OAuth → Authentik → OIDC → App
- 4-group role system: `{app}-users-pending`, `{app}-users`, `{app}-admins`, `{app}-users-banned`
- Blueprint IaC: YAML in `services/codepoet-mac-mini-1/authentik/blueprints/custom/`
- 통합 앱: rehab-crm, webtoon-maker, my-kanban-server

**Known limitation**: Docker Desktop Mac bridge mode에서 source IP 유실 → IPAllowList 사용 불가 → Authentik 자체 인증에 의존.

### 2.6 Port Assignments

| Range | Usage | Examples |
|-------|-------|---------|
| 53 | DNS | AdGuard Home |
| 80/443 | Traefik entry | Mac Mini 1 |
| 8880 | NAS chain | Traefik NAS |
| 9000-9002 | Object storage / Portainer Agent | MinIO, Portainer |
| 20000-20999 | SSH/Git | GitLab SSH :20022 |
| 23000-25999 | App services | Grafana, Prefect, n8n |
| 28000-28999 | Infra services | Vault, Vaultwarden |
| 29000-29999 | Management | Portainer |

---

## 3. Container Management

### 3.1 Docker + Portainer

- **Portainer Server**: Mac Mini 1 (:29000/:29443), manual docker run (Layer 1)
- **Portainer Agent**: 각 노드에 :9001 또는 :9002
- **Endpoint IDs**: mac-mini=3, mac-mini-2=17, nas=16, linux=15

### 3.2 Portainer GitOps

- `scripts/portainer-gitops.sh` — 핵심 배포 스크립트
- **Polling interval**: 5분
- **Webhook**: 즉시 재배포 트리거 (CI/CD에서 사용)
- **Commands**: `create`, `update`, `recreate`, `create-all`, `delete`, `list`
- **Credentials**: Vault에서 로드 (`secret/data/portainer/scripts`)

### 3.3 Hybrid GitOps Source Split

```
infra/ stacks → GitHub source (bootstrap reliability, GitLab 순환 의존 방지)
services/ stacks → GitLab CE source (CI 통합)
```

---

## 4. CI/CD Pipeline

### 4.1 GitLab CE

- **Host**: NAS (DS220+), `gitlab/gitlab-ce:18.8.2-ce.0`
- **Web**: `gitlab.home.codepoet.site`
- **Registry**: `gitlab-registry.home.codepoet.site`
- **SSH**: `:20022` (Mac Mini TCP forward → NAS → GitLab)
- **Group**: `k-codepoet` (namespace_id=2)

### 4.2 Pipeline Flow

```
Code push (main or v* tag)
  → GitLab CI trigger
  → build stage (Mac Mini 2 shell runner, arm64 native)
    → QEMU binfmt refresh
    → docker buildx build --platform linux/amd64,linux/arm64
    → push to gitlab-registry.home.codepoet.site
  → deploy stage (same runner)
    → clone my-devops (Deploy Token)
    → sed: update image tag in docker-compose.yml
    → git commit + push → Portainer polling
    → curl webhook → immediate redeploy
```

**Two-repo pattern**: App repo (source + Dockerfile + CI) → Infra repo (compose + Portainer stack)

### 4.3 Buildx Multiplatform

- **Runner**: Mac Mini 2 (M4) — **shell executor** (DinD + buildx = TLS 에러, 실증)
- **Builder**: `multiarch` (docker-container driver, persistent)
- **Platform**: `linux/amd64,linux/arm64`
- **QEMU**: arm64 native + amd64 emulation (Colima restart 후 binfmt 재등록 필요)
- **PATH**: `/opt/homebrew/bin:$PATH` — before_script AND script 모두에 필요 (shell executor 특성)
- **Tag strategy**: `v*` tag → tag name, otherwise → short SHA. 항상 `:latest`도 push
- **Timeout**: 20분

### 4.4 Runner Registry

| Runner | Device | Executor | Tags | Use |
|--------|--------|----------|------|-----|
| mac-mini-2-shell | Mac Mini 2 (M4) | shell | `shell, mac-mini-2` | multiplatform buildx |
| mac-mini-runner | Mac Mini 1 (M1) | docker (DinD) | `mac-mini, arm64, docker` | general Docker builds |
| linux-runner | Linux | docker (DinD) | `linux, amd64, docker` | lightweight tasks |

### 4.5 Scripts

- `portainer-gitops.sh` — Portainer API wrapper (Vault-integrated)
- `gitlab-api.sh` — GitLab REST API helper (Vault PAT)
- `docker-cleanup.sh` — Local/remote Docker cleanup
- `sync-blueprints.sh` — Authentik blueprint rsync
- `sync-scripts-to-minio.sh` — Scripts → MinIO sync

---

## 5. Secrets Management

### 5.1 Vault

- **Server**: Mac Mini 1 (:28200), HashiCorp Vault
- **Auth**: Token-based (root), AppRole (services)
- **Vault Agent**: sidecar pattern with `-exit-after-auth` → injects secrets at container startup

### 5.2 Secret Paths

```
secret/common/
  cloudflare, cloudflare-approle          — Tunnel credentials
  cloudflare-acme, cloudflare-acme-approle — ACME DNS challenge token
  portainer                                — Portainer API
  git                                      — GitHub credentials (for mirror)
  gitlab                                   — GitLab PAT

secret/services/
  {service-name}                           — Per-service secrets
  {service-name}-approle                   — Per-service AppRole

secret/data/portainer/
  scripts                                  — PORTAINER_API_KEY, GIT_USERNAME, GIT_TOKEN
  {service}                                — Stack variables per service
```

### 5.3 Security Rules

- Root token은 파일/커밋에 저장 금지
- `set +x` — secret 로깅 억제
- AppRole secret_id는 safe path만 사용
- Policy match 확인 후 secret 추가

---

## 6. Git Management Policy

### 6.1 Dual Management (Phase 1: Dual Push)

- **SSOT**: GitLab CE (primary)
- **GitHub**: mirror/backup
- my-devops remote:
  - `origin fetch` → GitLab
  - `origin push` → GitLab + GitHub (dual push URL)
  - `upstream` → GitHub (emergency)

### 6.2 Phase 2 Plan (Post-stabilization)

- GitLab Push Mirror → GitHub (~5min delay)
- Remove GitHub dual push URL
- Mirror via `glab api --method POST projects/.../remote_mirrors`

### 6.3 App Repo Init Pattern

1. `gh repo create` (GitHub)
2. `glab repo create` (GitLab CE)
3. Dual push remote setup
4. `git push -u origin main`
5. GitLab Push Mirror 설정
6. **Guard**: dual-push + mirror 동시 사용 금지 (conflict risk)

### 6.4 Portainer Source Split

- `infra/` → GitHub source (bootstrap reliability)
- `services/` → GitLab CE source (CI integration)

---

## 7. my-devops Repo Structure

```
my-devops/
├── infra/{device}/             — Portainer stacks → GitHub
│   ├── codepoet-mac-mini-1/   (traefik-mac, vault)
│   ├── codepoet-mac-mini-2/   (traefik-mac2)
│   ├── codepoet-nas/          (traefik-nas, gitlab-ce, cloudflared, adguard-home)
│   └── codepoet-linux-1/      (traefik-linux)
├── services/{device}/          — Portainer stacks → GitLab CE
│   ├── codepoet-mac-mini-1/   (grafana, n8n, prefect, vaultwarden, authentik, runners, prometheus, alertmanager)
│   ├── codepoet-mac-mini-2/   (prometheus-mac2, sample-ssr, gameglue-*)
│   ├── codepoet-nas/          (prometheus-nas)
│   └── codepoet-linux-1/      (runners, rehab-crm, webtoon-maker, my-kanban-server, prometheus)
├── scripts/
│   ├── portainer-gitops.sh     — Portainer stack manager
│   ├── gitlab-api.sh           — GitLab REST API helper
│   ├── docker-cleanup.sh       — Docker cleanup
│   ├── sync-blueprints.sh      — Authentik blueprints
│   └── sync-scripts-to-minio.sh
├── docs/
│   ├── architecture/           (traefik-chain, dns-split, vault-agent, current-structure, redesign-2026-02)
│   ├── guides/                 (bootstrap, add-new-service, gitlab, hybrid-gitops, vault-cli, docker-maintenance, app-to-production)
│   ├── machines/               (per-device notes)
│   ├── services/               (per-service ops notes)
│   └── reference/              (ports, stacks-registry, deployed-services, secrets-structure)
└── .claude/skills/             (deploy-stack, secrets, networking, cicd, init-repo)
```

---

## 8. Proposed opsify-codepoet Skill Map

### 8.1 Skill Structure

```
plugins/opsify-codepoet/
├── .claude-plugin/plugin.json
├── skills/
│   ├── setup/SKILL.md              ← 6-phase 홈서버 부트스트랩
│   ├── status/SKILL.md             ← 인프라 전체 상태 스캔 (+ 환경 체크)
│   ├── deploy-stack/SKILL.md       ← 서비스 배포 (Portainer GitOps)
│   │   └── references/
│   │       └── app-deploy-e2e.md
│   ├── cicd/SKILL.md               ← CI/CD 파이프라인 + glab CLI
│   │   └── references/
│   │       └── gitlab-ci-multiplatform.md
│   ├── networking/SKILL.md         ← Traefik chain + DNS + TLS + Auth
│   │   └── references/
│   │       ├── traefik-basicauth-split-router.md
│   │       ├── authentik-oidc-onboarding.md
│   │       └── react-router-7-oidc-impl.md
│   ├── secrets/SKILL.md            ← Vault 아키텍처 + CLI 운영
│   ├── init-repo/SKILL.md          ← GitHub + GitLab 듀얼 레포 초기화
│   ├── init-ssh/SKILL.md           ← SSH 서버 셋업 (노드 온보딩)
│   ├── env-setup/SKILL.md          ← 개발 환경 셋업 (packages + shell + nvm + devtools)
│   ├── branch-strategy/SKILL.md    ← Git 브랜치 전략 선택 + 셋업
│   │   └── references/
│   │       ├── downstream-fork.md
│   │       ├── vendor-branch.md
│   │       ├── github-flow.md
│   │       ├── upstream-sync.md
│   │       └── vendor-update.md
│   └── help/SKILL.md               ← 플러그인 도움말 + 스킬 목록
├── scripts/                         ← terrafy + shellify + my-devops-tools 스크립트 통합
├── agents/
│   └── opsify-codepoet.md          ← NL 트리거 ("배포해", "인프라", "서버 상태")
├── commands/
│   ├── help.md
│   └── howto.md
└── docs/
    ├── phases.md                    ← 6 Phase 부트스트랩 상세
    └── principles.md               ← 설계 원칙
```

### 8.2 Skill Summary (11 skills)

| Skill | Origin | Action | Description |
|-------|--------|--------|-------------|
| `setup` | terrafy:setup | KEEP | 6-phase 인프라 부트스트랩 |
| `status` | terrafy:status + shellify:status | MERGE | 전체 인프라 + 환경 상태 |
| `deploy-stack` | terrafy:deploy-stack + workflows/e2e | KEEP+REF | 서비스 배포 |
| `cicd` | terrafy:cicd + my-devops-tools:glab + workflows/cicd | MERGE | CI/CD + glab CLI |
| `networking` | terrafy:networking + workflows/networking,authentik | KEEP+REF | 네트워크 + 인증 |
| `secrets` | terrafy:secrets + my-devops-tools:vault | MERGE | Vault 아키텍처 + CLI |
| `init-repo` | terrafy:init-repo | KEEP | 듀얼 레포 초기화 |
| `init-ssh` | terrafy:init-ssh | KEEP | SSH 서버 셋업 |
| `env-setup` | shellify:setup-all (5 skills 통합) | MERGE | 개발 환경 셋업 |
| `branch-strategy` | git-branch-strategy (select+setup+refs) | MERGE | 브랜치 전략 |
| `help` | new | NEW | 플러그인 가이드 |

### 8.3 Key Design Decisions

1. **Authentik은 networking에 포함** — 별도 `auth` 스킬 대신 networking의 authentication 섹션으로 관리. 빈도가 늘면 분리 가능.
2. **shellify 5개 스킬 → env-setup 1개** — 홈랩 맥락에서는 서버 환경 셋업이 한 번에 이루어지므로 통합.
3. **git-branch-strategy 12개 → branch-strategy 1개 + references** — strategy-select 진단 + setup 스캐폴딩만 본 스킬, 패턴 레퍼런스는 references/ 디렉토리.
4. **state 디렉토리**: `~/.terrafy/` → `~/.opsify-codepoet/` (노드 상태, 클러스터 정보)
5. **scripts 통합**: terrafy 16 + shellify 6 + my-devops-tools 3 = 25 scripts → 정리 후 ~20개

---

## 9. Migration Plan

### 9.1 Phase 1: Plugin 생성

1. `plugins/opsify-codepoet/.claude-plugin/plugin.json` 생성
2. `.claude-plugin/marketplace.json`에 등록
3. 디렉토리 구조 스캐폴딩

### 9.2 Phase 2: Skills 마이그레이션

1. terrafy skills 8개 → 복사 + 수정 (`$CLAUDE_PLUGIN_ROOT` 경로, `~/.terrafy/` → `~/.opsify-codepoet/`)
2. shellify skills 5개 → `env-setup` 1개로 병합
3. my-devops-tools skills 2개 → `secrets` + `cicd`에 병합
4. git-branch-strategy → `branch-strategy` + references
5. workflows/ 5개 문서 → references/ 디렉토리

### 9.3 Phase 3: Scripts 통합

1. terrafy scripts/ → `scripts/` 복사
2. shellify scripts/ → `scripts/` 복사
3. my-devops-tools scripts/ → `scripts/` 복사
4. 중복 제거 (glab 설치 등)

### 9.4 Phase 4: Agent + Commands

1. `agents/opsify-codepoet.md` — NL 트리거 정의
2. `commands/help.md`, `commands/howto.md`

### 9.5 Phase 5: Cleanup

1. 기존 플러그인 archive 처리 (terrafy, shellify, my-devops-tools → `_archived/`)
2. git-branch-strategy는 범용이므로 유지 여부 판단 필요
3. marketplace.json 업데이트

---

## 10. Known Issues & Gaps

| Area | Issue | Status |
|------|-------|--------|
| Docker Desktop Mac | IPAllowList 사용 불가 (bridge NAT) | Authentik 인증으로 대체 |
| Authentik Blueprint | 수동 sync 필요 (CI hook 없음) | 향후 자동화 |
| Vault Agent | exit-after-auth vs manual kill 비일관 | 통합 시 표준화 |
| 모니터링 | Prometheus 수집만, 대시보드/알림 미흡 | 향후 Grafana 강화 |
| 백업/DR | persistent volume 백업 없음 | 향후 추가 |
| K8s | 도구 설치만 됨, 운영 스킬 없음 | Docker 유지, 필요시 추가 |
| Windows GPU | Phase 5 미착수 | 향후 |
| Cloud IaC | Terraform/OpenTofu 미구현 | 향후 확장 |
