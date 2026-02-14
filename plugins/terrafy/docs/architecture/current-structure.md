# 현재 인프라 구조 (2026-02)

> 하이브리드 GitOps 전환 완료 후 최종 구조

---

## 1. 전체 아키텍처

```
                         ┌──────────────────────────────┐
                         │     EXTERNAL (Internet)       │
                         │   *.codepoet.site             │
                         └──────────┬───────────────────┘
                                    │
                              Cloudflare CDN
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────┐
│  NAS (192.168.0.14)                                                  │
│  ┌──────────────┐                                                    │
│  │ cloudflared  │──── Tunnel ────► Mac Mini 1 :80                   │
│  └──────────────┘                                                    │
└──────────────────────────────────────────────────────────────────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │   INTERNAL          │                      │
              │ *.home.codepoet.site│                      │
              │ Split DNS → Mac Mini│Tailscale IP          │
              └─────────┬──────────┘                      │
                        │                                  │
                        ▼                                  │
┌════════════════════════════════════════════════════════════════════┐
║  MAC MINI 1 (192.168.0.48) — ENTRY POINT + CORE                  ║
║                                                                    ║
║  ┌────────────────────────────────────────────────────────────┐   ║
║  │ Traefik (:80, :443, :20022)                                │   ║
║  │ ACME wildcard cert (Cloudflare DNS challenge)              │   ║
║  │                                                            │   ║
║  │  Host match? ─Yes─► Local Docker service                   │   ║
║  │       │                                                    │   ║
║  │      No ─► Mac Mini 2? ─Yes─► 192.168.0.37:80            │   ║
║  │       │                                                    │   ║
║  │      No ─► Chain → NAS(:8880) → Linux(:80) → 404         │   ║
║  │                                                            │   ║
║  │  TCP :20022 ─► NAS:20022 (GitLab SSH)                     │   ║
║  └────────────────────────────────────────────────────────────┘   ║
║                                                                    ║
║  ┌────────┐ ┌───────────┐ ┌─────┐ ┌───────┐ ┌───────┐          ║
║  │ Vault  │ │ Portainer │ │ n8n │ │Prefect│ │Grafana│          ║
║  │ :28200 │ │ :29000    │ │:25678│ │:24200 │ │:23000 │          ║
║  └────────┘ └───────────┘ └─────┘ └───────┘ └───────┘          ║
║  ┌────────────┐ ┌───────────────┐                                ║
║  │Vaultwarden │ │GitLab Runner  │                                ║
║  │ :28888     │ │(arm64, DinD)  │                                ║
║  └────────────┘ └───────────────┘                                ║
╚════════════════════════════════════════════════════════════════════╝

┌════════════════════════════════════════════════════════════════════┐
║  NAS (192.168.0.14) — Chain Node 2, GitLab                       ║
║                                                                    ║
║  ┌─────────────────────────────────────────────────────────┐     ║
║  │ Traefik (:8880)                                         │     ║
║  │  Host match? ─Yes─► Local (GitLab, AdGuard)             │     ║
║  │       │                                                 │     ║
║  │      No ─► Linux(:80)                                   │     ║
║  └─────────────────────────────────────────────────────────┘     ║
║                                                                    ║
║  ┌──────────┐ ┌───────────┐ ┌──────────────┐ ┌──────────────┐  ║
║  │GitLab CE │ │cloudflared│ │ AdGuard Home │ │Portainer Agt │  ║
║  │:20022 SSH│ │           │ │ DNS :53      │ │ :9002        │  ║
║  └──────────┘ └───────────┘ └──────────────┘ └──────────────┘  ║
╚════════════════════════════════════════════════════════════════════╝

┌════════════════════════════════════════════════════════════════════┐
║  Linux (192.168.0.34) — Chain Node 3 (Final)                     ║
║                                                                    ║
║  ┌─────────────────────────────────────┐  ┌───────────────────┐  ║
║  │ Traefik (:80) → 404 fallback       │  │ GitLab Runner     │  ║
║  └─────────────────────────────────────┘  │ (amd64, DinD)     │  ║
║  ┌───────────────────┐                    └───────────────────┘  ║
║  │ Portainer Agent   │                                            ║
║  │ :9001             │                                            ║
║  └───────────────────┘                                            ║
╚════════════════════════════════════════════════════════════════════╝

┌════════════════════════════════════════════════════════════════════┐
║  Mac Mini 2 (192.168.0.37) — Standalone                          ║
║                                                                    ║
║  ┌─────────────────────────────────────┐  ┌───────────────────┐  ║
║  │ Traefik (:80) — 체인 미참여         │  │ Portainer Agent   │  ║
║  │ Mac Mini 1에서 Host 매칭 직접 전달   │  │ :9001             │  ║
║  └─────────────────────────────────────┘  └───────────────────┘  ║
╚════════════════════════════════════════════════════════════════════╝
```

---

## 2. 하이브리드 GitOps 구조

```
Developer ── git push ──► GitLab CE (SSOT, origin)
                                │
                    ┌───────────┴───────────┐
                    │                       │
              Push Mirror (auto)     Portainer polling
              (Phase 2 이후)         (서비스 스택)
                    │                       │
                    ▼                       ▼
               GitHub (mirror)       services/ 폴더 참조
                    │                (GitLab URL)
              Portainer polling             │
              (인프라 스택)          ┌──────┴──────┐
                    │               │ grafana     │
                    ▼               │ n8n         │
             infra/ 폴더 참조       │ prefect     │
             (GitHub URL)           │ vaultwarden │
                    │               │ runners     │
             ┌──────┴──────┐       └─────────────┘
             │ traefik (4) │
             │ vault       │
             │ gitlab-ce   │
             │ cloudflared │
             │ adguard     │
             └─────────────┘
```

| 폴더 | Portainer Git Source | 이유 |
|------|---------------------|------|
| `infra/` | **GitHub** | 순환 의존성 해소 — GitLab/NAS 다운에도 배포 가능 |
| `services/` | **GitLab CE** | GitLab CI 빌드/배포 자동화 연동 |

운영 가이드: `docs/guides/hybrid-gitops.md` (Phase 1→2→3)

---

## 3. Repo 폴더 구조

```
my-devops/
├── infra/                                    # Portainer → GitHub에서 clone
│   ├── codepoet-mac-mini-1/
│   │   ├── traefik/docker-compose.yml        # 진입점, ACME TLS, Chain Node 1
│   │   ├── vault/docker-compose.yml          # Secret 관리 (auto-unseal)
│   │   └── portainer/docker-compose.yml      # [수동] Layer 1 부트스트랩
│   ├── codepoet-nas/
│   │   ├── traefik/docker-compose.yml        # Chain Node 2, 내부 라우팅
│   │   ├── gitlab-ce/docker-compose.yml      # GitLab CE + Registry
│   │   ├── cloudflared/docker-compose.yml    # Cloudflare Tunnel
│   │   ├── adguard-home/docker-compose.yml   # DNS
│   │   └── portainer-agent/docker-compose.yml # [수동] Layer 1
│   ├── codepoet-mac-mini-2/
│   │   ├── traefik/docker-compose.yml        # Standalone, 체인 미참여
│   │   └── portainer-agent/docker-compose.yml # [수동] Layer 1
│   └── codepoet-linux-1/
│       ├── traefik/docker-compose.yml        # Chain Node 3, 404 fallback
│       └── portainer-agent/docker-compose.yml # [수동] Layer 1
│
├── services/                                 # Portainer → GitLab CE에서 clone
│   ├── codepoet-mac-mini-1/
│   │   ├── grafana/docker-compose.yml        # 모니터링
│   │   ├── n8n/docker-compose.yml            # 워크플로우 자동화
│   │   ├── prefect/docker-compose.yml        # 데이터 오케스트레이션
│   │   ├── vaultwarden/docker-compose.yml    # 패스워드 매니저
│   │   └── gitlab-runner/docker-compose.yml  # CI Runner (arm64, DinD)
│   └── codepoet-linux-1/
│       └── gitlab-runner/docker-compose.yml  # CI Runner (amd64, DinD)
│
├── scripts/
│   ├── portainer-gitops.sh                   # GitOps 배포 (하이브리드 GitHub+GitLab)
│   ├── gitlab-api.sh                         # GitLab REST API 헬퍼
│   └── docker-cleanup.sh                     # Docker 정리 (로컬/원격)
│
└── docs/
    ├── architecture/                         # 아키텍처 상세
    ├── guides/                               # How-to 가이드
    ├── reference/                            # 참조 (포트, 시크릿 구조)
    └── sessions/                             # 작업 로그
```

---

## 4. 등록된 Portainer GitOps 스택

### 인프라 스택 (GitHub 소스)

| Stack | Endpoint | Compose Path | Bootstrap Layer |
|-------|----------|--------------|-----------------|
| traefik-mac | mac-mini | `infra/codepoet-mac-mini-1/traefik/` | Layer 4 (Vault) |
| vault | mac-mini | `infra/codepoet-mac-mini-1/vault/` | Layer 2 |
| traefik-nas | nas | `infra/codepoet-nas/traefik/` | Layer 2 |
| gitlab-ce | nas | `infra/codepoet-nas/gitlab-ce/` | Layer 2 |
| cloudflared | nas | `infra/codepoet-nas/cloudflared/` | Layer 4 (Vault) |
| adguard-home | nas | `infra/codepoet-nas/adguard-home/` | Layer 2 |
| traefik-mac2 | mac-mini-2 | `infra/codepoet-mac-mini-2/traefik/` | Layer 2 |
| traefik-linux | linux | `infra/codepoet-linux-1/traefik/` | Layer 2 |

### 서비스 스택 (GitLab CE 소스)

| Stack | Endpoint | Compose Path | Bootstrap Layer |
|-------|----------|--------------|-----------------|
| grafana | mac-mini | `services/codepoet-mac-mini-1/grafana/` | Layer 4 (Vault) |
| n8n | mac-mini | `services/codepoet-mac-mini-1/n8n/` | Layer 4 (Vault) |
| prefect | mac-mini | `services/codepoet-mac-mini-1/prefect/` | Layer 4 (Vault) |
| vaultwarden | mac-mini | `services/codepoet-mac-mini-1/vaultwarden/` | Layer 2 |
| gitlab-runner-mac | mac-mini | `services/codepoet-mac-mini-1/gitlab-runner/` | Layer 3 |
| gitlab-runner-linux | linux | `services/codepoet-linux-1/gitlab-runner/` | Layer 3 |

### 수동 관리 (Layer 1 부트스트랩)

| Service | Device | 방식 |
|---------|--------|------|
| Portainer Server | Mac Mini 1 | `docker run` |
| Portainer Agent | NAS, Linux, Mac Mini 2 | `docker run` |

---

## 5. 부트스트랩 레이어

```
Layer 1 (수동)
  │  Portainer Server (Mac Mini 1)
  │  Portainer Agents (NAS, Linux, Mac Mini 2)
  │
  ▼
Layer 2 (Portainer GitOps, Vault 무관, GitHub 소스)
  │  vault, vaultwarden, traefik-nas, gitlab-ce,
  │  traefik-mac2, traefik-linux, adguard-home, cloudflared
  │
  ▼
Layer 3 (Portainer GitOps, Vault 무관, GitLab 소스)
  │  gitlab-runner-mac, gitlab-runner-linux
  │
  ▼
Layer 4 (Portainer GitOps, Vault 의존)
     traefik-mac (GitHub), grafana (GitLab),
     n8n (GitLab), prefect (GitLab)
```

---

## 6. 디바이스 네트워크 맵

| Device | LAN IP | Tailscale IP | Docker Network | 역할 |
|--------|--------|--------------|----------------|------|
| Mac Mini 1 | 192.168.0.48 | 100.108.195.20 | `traefik` | 진입점, ACME TLS, Core |
| Mac Mini 2 | 192.168.0.37 | 100.120.134.19 | `traefik` | Standalone |
| NAS | 192.168.0.14 | 100.125.241.80 | `gateway` | Chain Node 2, GitLab |
| Linux | 192.168.0.34 | 100.111.155.113 | `traefik` | Chain Node 3, 404 |
| Windows | 192.168.0.24 | 100.70.23.126 | - | 미사용 (GPU 예정) |

---

## 7. 트래픽 흐름

### 외부 접근 (*.codepoet.site)

```
Client → Cloudflare → cloudflared (NAS) → Mac Mini Traefik (:80/:443)
                                                    │
                                              TLS 종료 (ACME)
                                                    │
                                              Host 매칭 라우팅
```

### 내부 접근 (*.home.codepoet.site)

```
Client → Split DNS → Mac Mini Tailscale IP → Mac Mini Traefik (:80/:443)
                                                    │
                                              TLS 종료 (ACME)
                                                    │
                                              Host 매칭 라우팅
```

### GitLab SSH

```
Client → gitlab.home.codepoet.site:20022
       → Split DNS → Mac Mini Traefik (TCP :20022)
       → NAS:20022 → GitLab SSH
```

---

## 8. Vault Secret 주입 흐름

```
Vault (Mac Mini, :28200)
  │
  └── Vault Agent Sidecar (각 서비스 docker-compose.yml 내)
       │
       ├── traefik-mac  → secret/common/cloudflare-acme → CF_DNS_API_TOKEN
       ├── cloudflared  → secret/common/cloudflare → TUNNEL_ID, SECRET
       ├── grafana      → secret/services/grafana → ADMIN_USER, PASSWORD
       ├── n8n          → secret/services/n8n → POSTGRES_*, N8N_HOST
       └── prefect      → secret/services/prefect → POSTGRES_*
```

---

## 9. Git Remote 구성

| Remote | URL | 용도 |
|--------|-----|------|
| `origin` | `gitlab-nas:k-codepoet/my-devops.git` | 개발 primary (fetch + push) |
| `upstream` | `git@github.com:k-codepoet/my-devops.git` | Mirror 확인, 긴급 수동 push |

현재 단계: **Phase 1** (dual push URL로 양쪽 동시 push)

---

## 10. 포트 할당 현황

| Port | Service | Device |
|------|---------|--------|
| 80, 443 | Traefik (진입점) | Mac Mini 1 |
| 80 | Traefik | NAS, Linux, Mac Mini 2 |
| 8880 | Traefik (Chain) | NAS |
| 9001 | Portainer Agent | Linux, Mac Mini 2 |
| 9002 | Portainer Agent | NAS |
| 20022 | GitLab SSH | Mac Mini 1 → NAS |
| 23000 | Grafana | Mac Mini 1 |
| 24200 | Prefect | Mac Mini 1 |
| 25678 | n8n | Mac Mini 1 |
| 28200 | Vault | Mac Mini 1 |
| 28888 | Vaultwarden | Mac Mini 1 |
| 29000 | Portainer | Mac Mini 1 |
