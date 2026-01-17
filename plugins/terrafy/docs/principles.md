# Terrafy 설계 원칙

## 핵심 철학

> 물리 자원을 배포 가능한 API로 변환

사용자가 가진 물리적 서버들을 GitOps로 서비스 배포 가능한 상태로 만든다.

```
[물리 자원]                    [API 레벨]
┌─────────────────┐           ┌─────────────────┐
│ 공유기 뒤 NAS    │           │ https://app.my  │
│ Mac Mini        │    →      │ Portainer API   │
│ 리눅스 서버      │           │ GitOps endpoint │
└─────────────────┘           └─────────────────┘
```

---

## 원칙

### 1. 스캔 먼저, 질문은 나중에

- 환경을 먼저 파악하고 제안한다
- 사용자에게 묻기 전에 가능한 정보를 수집한다
- "어떤 서버 있어요?" 대신 "이런 서버들이 보이는데요"

### 2. 기본값 제안, 선택은 사용자

- Sensible defaults를 제시한다
- 사용자가 수정할 수 있게 한다
- 전문가는 알아서 override

### 3. 용어는 단계적으로 노출

Progressive Disclosure:
- 처음엔 쉬운 용어 (관문, 관제탑, 일꾼)
- 필요할 때 기술 용어 노출 (Gateway, Orchestrator, Worker)

| 사용자 용어 | 기술 용어 | 구성 요소 |
|------------|----------|----------|
| 관문 | Gateway | cloudflared + Traefik |
| 관제탑 | Orchestrator | Portainer Server |
| 일꾼 | Worker | Docker + Portainer Agent |

### 4. 반복 작업은 스크립트로

- Claude는 판단과 대화 담당
- 반복 실행은 shell script로 (비용 절감)
- 스크립트는 `--json` 출력 지원 (파싱 용이)

### 5. 단계별 진행, 중단 가능

- Phase 1 → 2 → 3 → 4 → 5 순차 진행
- 언제든 중단 가능
- `/terrafy:status`로 현재 상태 확인
- `/terrafy:setup`으로 이어서 진행

---

## 역할 판단 기준

### Gateway 조건

**완전 구성 (`[x]`):**
- cloudflared 실행 중 AND
- Traefik 실행 중

**부분 구성 (`[?]`):**
- 둘 중 하나만 있음
- "다른 방식?" 확인 필요

**미구성 (`[ ]`):**
- 둘 다 없음

### Orchestrator 조건

- Portainer Server 실행 중 → `[x]`
- Docker만 있음 → `[~]` (준비됨)
- Docker 없음 → `[ ]`

### Worker 조건

- Portainer Agent 실행 중 → `[x]`
- Docker만 있음 → `[~]` (준비됨)
- Docker 없음 → `[ ]`

---

## 역할 배정 우선순위

### Gateway 후보 선정
1. NAS (상시 가동, 안정적)
2. 가장 uptime 긴 서버
3. 외부 접근 용이한 위치

### Orchestrator 후보 선정
1. 마스터 머신 (SSH 접근 중심)
2. 리소스 여유 있는 머신
3. 관리 편의성 (모니터/키보드 접근)

### Worker 후보 선정
- 나머지 모든 머신
- 리소스에 따라 서비스 분배

---

## 싱글노드 vs 클러스터

### 싱글노드
```
[이 머신] ─ Gateway + Orchestrator + Worker
```
- 간단, 빠른 시작
- 리소스 한 곳에 집중
- 장애 시 전체 다운

### 클러스터
```
[NAS] Gateway
   ↓
[Mac] Orchestrator
   ↓
[Linux] Worker
```
- 역할 분리
- 장애 격리
- 확장 용이

---

## 네트워크 아키텍처

### 외부 → 내부 흐름
```
인터넷
   ↓
[cloudflared] Tunnel (443)
   ↓
[Traefik] 라우팅
   ↓
[서비스들] Docker containers
```

### 내부 통신
```
[Orchestrator] ─── 9001 ──→ [Worker Agent]
     ↓
 Portainer API
     ↓
 GitOps 배포
```

---

## 상태 표시 규칙

| 표시 | 의미 |
|------|------|
| `[x]` | 완전 구성, 정상 작동 |
| `[~]` | 준비됨 (전제조건 충족) |
| `[ ]` | 미구성 |
| `[?]` | 확인 필요 (우리 방식과 다름) |
| `[!]` | 문제 있음 |
