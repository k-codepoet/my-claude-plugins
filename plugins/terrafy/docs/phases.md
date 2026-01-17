# Terrafy 작업 단계

Terrafy는 단계별로 진행됩니다. 각 단계가 완료되어야 다음 단계로 넘어갑니다.

## 전체 플로우

```
Phase 1: 탐색 (Discovery)
    ↓
Phase 2: 연결 (Connection) - 클러스터만
    ↓
Phase 3: 배정 (Assignment)
    ↓
Phase 4: Portainer 설치 ← 핵심 분기점
    ↓
    ★ 이 시점에서 모든 머신에 뭐든 배포 가능
    ↓
Phase 5: Gateway 설치 (cloudflared + Traefik Chain)
    ↓
Phase 6: 검증 (homelab-*.domain 접근 테스트)
    ↓
    ★ 완료 = craftify로 앱 배포 가능
```

---

## Phase 1: 탐색 (Discovery)

**목표**: 현재 환경 파악

### 수행 작업
1. 이 머신 스캔 (`scan-host.sh`)
   - OS, IP, 메모리, 디스크
2. Docker 상태 확인 (`check-docker.sh`)
   - 설치 여부, 실행 여부, 버전
3. 네트워크 스캔 (`scan-network.sh`)
   - 같은 서브넷 호스트 탐색
   - 타입 추측 (NAS, 서버 등)
4. 서비스 상태 확인 (`check-services.sh`)
   - Traefik, cloudflared, Portainer 상태
   - 역할 판단

### 완료 조건
- 이 머신 정보 수집됨
- 네트워크 호스트 목록 확보됨 (0개 이상)

### 결과물
- 현황 리포트 (사용자에게 표시)
- 싱글노드/클러스터 선택지 제공

---

## Phase 2: 연결 (Connection)

**목표**: 클러스터 머신들 SSH 연결

> 싱글노드 선택 시 이 단계 스킵

### 수행 작업
1. 마스터 초기화 (`init-master.sh`)
   - SSH 키 생성 (`~/.ssh/terrafy_ed25519`)
   - SSH config 설정
2. 노드 추가 (`add-node.sh`)
   - 각 머신에 ssh-copy-id
   - 연결 테스트
3. 원격 스캔 (`remote-exec.sh` + 스캔 스크립트들)
   - 각 노드의 Docker, 서비스 상태 확인

### 완료 조건
- 마스터에서 모든 노드에 SSH 접근 가능
- 각 노드의 상태 파악됨

### 실패 시
- `Permission denied` → 비밀번호 재입력 또는 `/terrafy:init-ssh` 안내
- `Connection refused` → 해당 머신에서 SSH 서버 설정 필요

---

## Phase 3: 배정 (Assignment)

**목표**: 각 머신에 역할 배정

### 역할 정의

| 역할 | 설명 | 필수 조건 |
|------|------|----------|
| **Gateway** | 외부 진입점 | cloudflared + Traefik |
| **Orchestrator** | 서비스 관리 | Portainer Server |
| **Worker** | 서비스 실행 | Docker + Portainer Agent |

### 역할 배정 기준

1. **Gateway**
   - 가장 안정적인 머신 (NAS 우선)
   - 24시간 상시 가동
   - 외부 접근 가능해야 함

2. **Orchestrator**
   - 마스터 머신 권장
   - 충분한 리소스 (관리 UI 실행)

3. **Worker**
   - 나머지 모든 머신
   - 리소스에 따라 서비스 분배

### 싱글노드인 경우
- 한 머신이 Gateway + Orchestrator + Worker 모두 수행

### 완료 조건
- 모든 머신에 역할 배정됨
- 사용자 확인 완료

---

## Phase 4: Portainer 설치

**목표**: 모든 머신을 원격 제어 가능하게 만들기

> ★ 이 Phase 완료 = 모든 머신에 뭐든 배포 가능

### Orchestrator 설치 (`install-orchestrator.sh`)
```bash
# Portainer Server 설치
docker volume create portainer_data
docker run -d --name portainer \
  -p 9443:9443 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  --restart always \
  portainer/portainer-ce
```

### Worker 설치 (`install-worker.sh`)
```bash
# Portainer Agent 설치
docker run -d --name portainer_agent \
  -p 9001:9001 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  --restart always \
  portainer/agent
```

### 완료 조건
- Portainer Server 실행 중
- 모든 Agent 연결됨 (Portainer UI에서 확인)

---

## Phase 5: Gateway 설치

**목표**: 외부에서 접근 가능하게 만들기

### 아키텍처 (Traefik Chain)

```
외부 → *.domain.com → Cloudflare Tunnel
                            ↓
                      [NAS] cloudflared + Traefik (Chain Node 1)
                            ↓ fallback
                      [Mac] Traefik (Chain Node 2)
                            ↓ fallback
                      [Linux] Traefik + 404 (Chain Node 3)
```

### Gateway (Chain Node 1) 설치 (`install-gateway.sh`)

1. Docker network 생성
```bash
docker network create gateway
```

2. cloudflared 설치
```bash
# Cloudflare Tunnel 토큰 필요 (사용자 입력)
docker run -d --name cloudflared \
  --network gateway \
  --restart always \
  cloudflare/cloudflared:latest \
  tunnel --no-autoupdate run --token <TUNNEL_TOKEN>
```

3. Traefik 설치 (Chain 구성)
```bash
# docker-compose.yml로 배포 (init-config 포함)
# - routes.yml: 서비스 라우팅 + 다음 노드로 fallback
# - welcome page: homelab-{node}.domain.com
```

### 다른 노드 Traefik 설치 (`install-traefik-chain.sh`)

각 노드에 Traefik 설치:
- 자기 노드 서비스 라우팅
- 다음 노드로 fallback
- 마지막 노드는 404

### 완료 조건
- cloudflared 실행 중
- 모든 노드 Traefik 실행 중
- Traefik Chain 연결 확인

---

## Phase 6: 검증

**목표**: 전체 시스템 작동 확인

### 검증 항목

1. **Portainer 검증**
   - Web UI 접근 가능
   - 모든 Agent 연결됨

2. **Gateway 검증**
   - cloudflared 실행 중
   - Traefik 실행 중 (각 노드)

3. **외부 접근 검증**
```bash
# 각 노드별 welcome 페이지 테스트
curl https://homelab-nas.domain.com    # NAS
curl https://homelab-mac.domain.com    # Mac
curl https://homelab-linux.domain.com  # Linux
curl https://test.domain.com           # 기본 테스트
```

4. **Traefik Chain 검증**
   - 각 노드 Dashboard 접근
   - fallback 동작 확인

### 완료 조건
- 모든 homelab-*.domain.com 접근 가능
- GitOps 배포 준비 완료

---

## 상태 저장

각 Phase 진행 상태는 마스터 머신에 저장:

```
~/.terrafy/
├── config.json          # 클러스터 설정
├── nodes/               # 노드별 상태
│   ├── 192.168.0.14.json
│   ├── 192.168.0.27.json
│   └── ...
└── current-phase        # 현재 Phase (1-6)
```

`/terrafy:status`는 이 파일들을 읽어서 현재 상태 표시.
`/terrafy:setup`은 중단된 Phase부터 재개.

---

## 다음 단계

Phase 6 완료 후:
- `/craftify:deploy`로 앱 배포
- Portainer GitOps로 docker-compose.yml 배포
- 새 서비스는 Traefik labels로 자동 라우팅
