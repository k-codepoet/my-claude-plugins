# Terrafy

> 물리 자원을 배포 가능한 API로 변환

홈서버나 소규모 인프라를 구축할 때, 물리적인 서버들을 GitOps로 배포 가능한 환경으로 만들어줍니다.

## 지원 환경

- **Linux** (Ubuntu, Debian, etc.)
- **macOS**
- ~~Windows~~ (TODO - 홈서버 사용 사례 드묾)

## 핵심 아이디어

```
[물리 자원]                    [API 레벨]
┌─────────────────┐           ┌─────────────────┐
│ 공유기 뒤 NAS    │           │ https://nas.my  │
│ Mac Mini        │    →      │ Portainer API   │
│ USB 외장하드     │           │ /volumes/data   │
│ 192.168.0.x     │           │ GitOps endpoint │
└─────────────────┘           └─────────────────┘
```

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/terrafy:status` | 환경 스캔 + 현재 상태 |
| `/terrafy:setup` | 대화형 인프라 구성 |
| `/terrafy:help` | 도움말 |

## 역할

| 역할 | 쉬운 이름 | 기술 스택 |
|------|----------|----------|
| Gateway | 관문 | Traefik + Ingress |
| Orchestrator | 관제탑 | Portainer Server |
| Worker | 일꾼 | Docker + Agent |

## 시작하기

```
/terrafy:status   # 환경 확인
/terrafy:setup    # 구성 시작
```

## -fy Trilogy

| Plugin | Role | Question |
|--------|------|----------|
| Gemify | 지식/설계 | WHAT - 뭘 만들지 |
| **Terrafy** | 인프라 | WHERE - 어디서 돌릴지 |
| Craftify | 개발 | HOW - 어떻게 만들지 |
