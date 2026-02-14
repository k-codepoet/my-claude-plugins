# Port Allocation

> 서비스별 포트 할당표 + 포트/도메인 관리 정책

## 포트 관리 정책

### 기본 원칙: 포트 닫고 도메인으로 접근

- **호스트 포트는 기본적으로 닫는다** (`expose`만 하고 `ports` 바인딩 안 함)
- **모든 서비스는 Traefik 도메인으로 접근**한다 (Docker labels로 라우팅)
- 포트를 여는 경우는 아래 예외에 한함

### 포트 오픈이 필요한 예외

| 예외 유형 | 예시 | 이유 |
|----------|------|------|
| **Traefik 자체** | 80, 443 | 진입점 |
| **비-HTTP 프로토콜** | DNS :53, SSH :20022 | Traefik HTTP 라우팅 불가 |
| **서비스 간 직접 통신** | Vault :28200, Portainer :29000/29443 | 부트스트랩 레이어, Traefik보다 먼저 떠야 함 |
| **Agent 통신** | Portainer Agent :9001 | Portainer ↔ Agent 직접 통신 |

### DNS 접근 구분: 외부 vs 내부

| 도메인 | 경로 | 접근 범위 | 용도 |
|--------|------|----------|------|
| `*.codepoet.site` | Cloudflare → cloudflared → Mac Mini Traefik :80 | **외부** (인터넷) | 외부 공개 서비스 |
| `*.home.codepoet.site` | Split DNS → Mac Mini Tailscale IP → Traefik :443 | **내부** (Tailscale VPN) | 내부 관리 서비스 |

### 서비스별 도메인 할당

#### 외부 접근 (*.codepoet.site) — Cloudflare Tunnel 경유

| 서비스 | 도메인 | 비고 |
|--------|--------|------|
| Authelia | `auth.codepoet.site` | SSO 포털 (외부 사용자 인증) |
| n8n | `n8n.codepoet.site` | 외부 webhook 수신 필요 |
| homelab welcome | `homelab-mac-mini-1.codepoet.site` | - |
| homelab welcome | `homelab-mac-mini-2.codepoet.site` | - |
| homelab welcome | `homelab-nas.codepoet.site` | - |
| homelab welcome | `homelab-linux-1.codepoet.site` | - |

> cloudflared는 `*.codepoet.site` 와일드카드로 Mac Mini Traefik에 전달.
> Traefik에서 Host 매칭 안 되면 체인으로 흘러감.

#### 내부 접근 (*.home.codepoet.site) — Split DNS + Tailscale

| 서비스 | 도메인 | 위치 |
|--------|--------|------|
| Authelia | `auth.home.codepoet.site` | Mac Mini |
| Grafana | `grafana.home.codepoet.site` | Mac Mini |
| Prefect | `prefect.home.codepoet.site` | Mac Mini |
| n8n | `n8n.home.codepoet.site` | Mac Mini (내부 경로도 있음) |
| Vault | `vault.home.codepoet.site` | Mac Mini |
| Vaultwarden | `vaultwarden.home.codepoet.site` | Mac Mini |
| Portainer | `portainer.home.codepoet.site` | Mac Mini |
| GitLab CE | `gitlab.home.codepoet.site` | NAS |
| GitLab Registry | `gitlab-registry.home.codepoet.site` | NAS |
| AdGuard Home | `adguard.home.codepoet.site` | NAS |
| Traefik Dashboard (Mac) | `traefik-mac-mini-1.home.codepoet.site` | Mac Mini |
| Traefik Dashboard (NAS) | `traefik-nas.home.codepoet.site` | NAS |
| Traefik Dashboard (Mac2) | `traefik-mac-mini-2.home.codepoet.site` | Mac Mini 2 |
| Traefik Dashboard (Linux) | `traefik-linux-1.home.codepoet.site` | Linux |

### 새 서비스 추가 시 체크리스트

1. **포트 바인딩 하지 않는다** (Docker labels로 Traefik 연동)
2. **내부/외부 접근 결정** → `*.home.codepoet.site` or `*.codepoet.site`
3. 외부 노출 필요 시 → cloudflared는 와일드카드라 Traefik Host 매칭만 추가하면 됨
4. 비-HTTP 프로토콜이면 → 포트 오픈 필요, 아래 할당표에서 범위 확인
5. 포트 오픈 시 → 할당 범위 20000-29999 내에서 배정

## 할당 규칙

- 호스트 포트: 20000-29999 범위 사용
- 컨테이너 내부 포트: 원본 유지 (예: `23000:3000`)

## 범위별 용도

| Range | Purpose | 비고 |
|-------|---------|------|
| 20000-20999 | SSH/Git | GitLab SSH 등 |
| 21000-21999 | Reserved | - |
| 22000-22999 | Reserved | - |
| 23000-23999 | Monitoring | Grafana 등 |
| 24000-24999 | Orchestration | Prefect 등 |
| 25000-25999 | Automation | n8n 등 |
| 26000-26999 | Reserved | - |
| 27000-27999 | Reserved | - |
| 28000-28999 | Security | Vault, Vaultwarden |
| 29000-29999 | Management | Portainer |

## 현재 할당

### Mac Mini (192.168.0.48)

| Service | Host Port | Container Port | 비고 |
|---------|-----------|----------------|------|
| Traefik | 80, 443, 8080 | 80, 443, 8080 | 외부 진입점 |
| Grafana | 23000 | 3000 | - |
| Prefect | 24200 | 4200 | - |
| n8n | 25678 | 5678 | - |
| Vault | 28200 | 8200 | - |
| Vaultwarden | 28888 | 80 | - |
| Portainer | 29000, 29443 | 9000, 9443 | - |

### NAS (192.168.0.14)

| Service | Host Port | Container Port | 비고 |
|---------|-----------|----------------|------|
| Traefik | 8880 | 80 | DSM이 80/443 점유 |
| GitLab CE | 20080, 20022 | 80, 22 | HTTP, SSH |
| AdGuard Home | 53, 3080 | 53, 80 | DNS, Web UI |
| Portainer Agent | 9002 | 9001 | - |

### Linux (192.168.0.34)

| Service | Host Port | Container Port | 비고 |
|---------|-----------|----------------|------|
| Traefik | 80, 8080 | 80, 8080 | - |
| Portainer Agent | 9001 | 9001 | - |

## Tailscale IP

| Device | Tailscale IP | 비고 |
|--------|-------------|------|
| Mac Mini | 100.108.195.20 | Split DNS 진입점 (외부+내부 통합) |
| NAS | 100.125.241.80 | Chain Node 2 |
| Linux | 100.111.155.113 | Chain Node 3 |
