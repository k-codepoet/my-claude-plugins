---
name: status
description: 현재 인프라 상태를 스캔하고 보여줌. "상태 확인", "인프라 상태", "terrafy status" 등 요청 시 활성화. 상황별 다른 출력 제공.
allowed-tools: Bash, Read
---

# Status Skill

현재 환경을 파악하고 **상황에 맞는 정보**를 보여줍니다.

## 참조 문서 (필수)

**스킬 실행 전 반드시 읽기:**
- `$CLAUDE_PLUGIN_ROOT/docs/principles.md` - 역할 판단 기준, 상태 표시 규칙

## 동작 방식

Status는 **라우터**입니다. 상황을 판단해서 적절한 정보를 보여줍니다.

```
/terrafy:status
    ↓
┌─────────────────────────────────────┐
│  1. 스크립트로 환경 수집             │
│  2. 상황 판단                        │
│  3. 상황별 출력                      │
└─────────────────────────────────────┘
```

## 1단계: 환경 수집

스크립트를 실행해서 정보를 모읍니다:

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/scan-host.sh"      # 이 머신 정보
bash "$CLAUDE_PLUGIN_ROOT/scripts/check-docker.sh"   # Docker 상태
bash "$CLAUDE_PLUGIN_ROOT/scripts/check-services.sh" # 서비스/역할 상태
```

## 2단계: 상황 판단

수집한 정보로 현재 상황을 판단합니다:

| 상황 | 조건 |
|------|------|
| **처음** | Docker 없음 or 서비스 없음 |
| **설정 중** | 일부 서비스만 구성됨 |
| **구성 완료** | 모든 역할 구성됨 |
| **문제 있음** | 서비스 중단 등 |

## 3단계: 상황별 출력

### 처음인 경우

```
=== Terrafy Status ===

[이 머신]
OS: Ubuntu 22.04
IP: 192.168.0.10
Docker: 설치됨, 실행 중

[인프라 상태]
관문 (Gateway):     [ ] 미구성
관제탑 (Portainer): [ ] 미구성
일꾼 (Worker):      [~] Docker 준비됨

아직 인프라가 구성되지 않았습니다.

→ /terrafy:setup 으로 시작하세요
```

### 설정 중인 경우

```
=== Terrafy Status ===

[이 머신]
OS: Ubuntu 22.04
IP: 192.168.0.10

[인프라 상태]
관문 (Gateway):     [x] Traefik 실행 중
관제탑 (Portainer): [ ] 미구성
일꾼 (Worker):      [~] Docker 준비됨

설정이 완료되지 않았습니다.

다음 단계: Portainer 설치
→ /terrafy:setup 으로 이어서 진행하세요
```

### 구성 완료된 경우

```
=== Terrafy Status ===

[이 머신]
OS: Ubuntu 22.04
IP: 192.168.0.10

[인프라 상태]
관문 (Gateway):     [x] Traefik 실행 중 (Up 3 days)
관제탑 (Portainer): [x] 실행 중 (Up 3 days)
일꾼 (Worker):      [x] Agent 연결됨

[서비스]
• Traefik: Up 3 days
• Portainer: Up 3 days
• cloudflared: Up 3 days

모든 인프라가 정상입니다.
```

### 문제가 있는 경우

```
=== Terrafy Status ===

[이 머신]
OS: Ubuntu 22.04
IP: 192.168.0.10

[인프라 상태]
관문 (Gateway):     [!] Traefik 중단됨
관제탑 (Portainer): [x] 실행 중
일꾼 (Worker):      [x] Agent 연결됨

[문제]
• Traefik 컨테이너가 중단되었습니다

→ docker start traefik 으로 재시작하세요
```

## 클러스터 상태 (선택)

`~/.terrafy/nodes/`에 노드 정보가 있으면 클러스터 전체 상태도 표시:

```
[클러스터]
• 192.168.0.14 (NAS) - Gateway [x]
• 192.168.0.34 (마스터) - Orchestrator [x]
• 192.168.0.27 (서버) - Worker [x]
```

## 상태 표시 규칙

| 표시 | 의미 |
|------|------|
| `[x]` | 완전 구성, 정상 작동 |
| `[~]` | 준비됨 (Docker 있음 등) |
| `[ ]` | 미구성 |
| `[?]` | 확인 필요 (우리 방식과 다름) |
| `[!]` | 문제 있음 |

## 역할 판단 기준

### Gateway
- `[x]` cloudflared + Traefik 둘 다 실행 중
- `[?]` 하나만 있음 → "다른 방식 사용 중?" 확인
- `[ ]` 둘 다 없음

### Orchestrator
- `[x]` Portainer Server 실행 중
- `[~]` Docker만 있음
- `[ ]` Docker 없음

### Worker
- `[x]` Portainer Agent 실행 중
- `[~]` Docker만 있음
- `[ ]` Docker 없음

## 규칙

- **스캔 결과 기반** - 추측하지 않고 스크립트 결과로 판단
- **상황별 다음 액션 제시** - 무엇을 해야 하는지 안내
- **문제 발견 시 해결책 제시** - 명령어까지 제공
