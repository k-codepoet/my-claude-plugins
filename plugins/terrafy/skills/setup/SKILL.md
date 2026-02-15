---
description: 홈서버 인프라를 대화형으로 구성. "인프라 설정", "홈서버 만들어", "클러스터 구성", "terrafy setup" 등 요청 시 활성화. 6 Phase 부트스트랩.
allowed-tools: Bash, Read, Write
---

# Setup Skill

대화형으로 홈서버 인프라를 **6 Phase**로 구성합니다.

## 참조 문서 (필수)

**스킬 실행 전 반드시 읽기:**
- `$CLAUDE_PLUGIN_ROOT/docs/phases.md` - 6 Phase 상세
- `$CLAUDE_PLUGIN_ROOT/docs/principles.md` - 설계 원칙

## 6 Phase 개요

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

## Phase 1: 탐색

### 스크립트 실행

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/scan-host.sh"      # 이 머신 정보
bash "$CLAUDE_PLUGIN_ROOT/scripts/check-docker.sh"   # Docker 상태
bash "$CLAUDE_PLUGIN_ROOT/scripts/check-services.sh" # 서비스/역할 판단
bash "$CLAUDE_PLUGIN_ROOT/scripts/scan-network.sh"   # 네트워크 탐색
```

### 결과 보여주기

```
=== 발견된 머신들 ===
• 이 머신 (192.168.0.34, Linux) - Docker 실행 중
• 192.168.0.14 - NAS로 보임 (SSH 미확인)
• 192.168.0.27 - 서버로 보임 (SSH 미확인)

어떻게 구성할까요?

1. 싱글노드 - 이 머신만으로 진행 (올인원)
2. 클러스터 - 여러 머신을 묶어서 구성

(기본: 1) →
```

### 싱글노드 선택 시
→ Phase 2 스킵, Phase 3으로 이동

### 클러스터 선택 시
→ Phase 2 진행

## Phase 2: 연결 (클러스터만)

### 마스터 초기화

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/init-master.sh"
```

### 노드 추가 (각 머신마다)

```
192.168.0.14 (NAS) 추가할까요? (Y/n) →
  사용자명 (기본: admin): →
```

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/add-node.sh" 192.168.0.14 admin
```

### 연결 실패 시

```
[!] 192.168.0.14 연결 실패: Permission denied

어떻게 할까요?
1. 다시 시도 (비밀번호 재입력)
2. 해당 머신에서 /terrafy:init-ssh 실행 필요
3. 이 머신 건너뛰기
```

### 원격 스캔

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/remote-exec.sh" 192.168.0.14 \
  "$CLAUDE_PLUGIN_ROOT/scripts/scan-host.sh"
```

## Phase 3: 배정

### 역할 제안

| 사용자 용어 | 기술 용어 | 배정 기준 |
|------------|----------|----------|
| 관문 | Gateway | NAS 우선, 상시 가동 |
| 관제탑 | Orchestrator | 마스터 머신 |
| 일꾼 | Worker | 나머지 모든 머신 |

### 사용자 확인

```
=== 추천 구성 ===

[NAS] 관문 (Gateway) - cloudflared + Traefik
    ↓
[마스터] 관제탑 (Orchestrator) - Portainer Server
    ↓
[서버] 일꾼 (Worker) - Portainer Agent

이대로 진행할까요? (Y/n)
```

## Phase 4: Portainer 설치

> ★ 핵심 분기점: 이 Phase 완료 = 모든 머신에 뭐든 배포 가능

### Orchestrator에 설치

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-orchestrator.sh"
```

### Worker에 설치 (원격)

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/remote-exec.sh" <worker-ip> \
  "$CLAUDE_PLUGIN_ROOT/scripts/install-worker.sh"
```

## Phase 5: Gateway 설치

### 외부 접근 방식 선택

```
외부 접근 방식을 선택해주세요:

1. Cloudflare Tunnel (추천)
   - 공인 IP 필요 없음, 자동 HTTPS

2. 포트포워딩
   - 공유기에서 설정 필요

3. 내부망만
   - 외부 접근 없음

(기본: 1) →
```

### Cloudflare Tunnel 선택 시

Tunnel 토큰 입력 받기:
```
Cloudflare Tunnel 토큰을 입력하세요:
(dash.cloudflare.com → Zero Trust → Tunnels에서 생성)
→
```

### Gateway 설치 (Chain Node 1)

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-gateway.sh" --token <TUNNEL_TOKEN>
```

### Chain Node 설치 (Node 2, 3...)

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/remote-exec.sh" <node-ip> \
  "$CLAUDE_PLUGIN_ROOT/scripts/install-traefik-chain.sh" --next <next-node-ip>
```

## Phase 6: 검증

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/verify-cluster.sh" --domain <domain>
```

### 성공 시

```
=== 설치 완료 ===

[x] Gateway (192.168.0.14)
    cloudflared: 실행 중
    Traefik: 실행 중

[x] Orchestrator (192.168.0.34)
    Portainer: https://portainer.example.com

[x] Worker (192.168.0.27)
    Agent: 연결됨

=== 다음 단계 ===
1. Portainer에서 GitOps 저장소 연결
2. docker-compose.yml로 서비스 배포
3. /craftify:deploy로 앱 배포
```

## 상태 저장

진행 상태는 `~/.terrafy/`에 저장:
- `config.json` - 클러스터 설정
- `nodes/` - 노드별 상태
- `current-phase` - 현재 Phase (1-6)

중단 후 재개 시 마지막 Phase부터 계속.

## 규칙

- **스캔 먼저, 질문은 나중에** - 환경 파악 후 제안
- **기본값 제안, 선택은 사용자** - Sensible defaults
- **반복 작업은 스크립트로** - Claude는 판단, 스크립트는 실행
