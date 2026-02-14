---
description: terrafy 플러그인 도움말을 표시합니다
---

# Terrafy 도움말

> Lay the groundwork for your digital city.

물리 자원을 배포 가능한 API로 변환하는 홈서버 인프라 자동화 도구입니다.

## 개념

```
[물리 자원]              →        [API 레벨]
공유기 뒤 NAS                   https://nas.my
Mac Mini             Terrafy    Portainer API
USB 외장하드           →         /volumes/data
192.168.0.x                     GitOps endpoint
```

## 사용 가능한 기능

### 가이드
| 기능 | 설명 |
|------|------|
| `/terrafy:help` | 이 도움말 표시 |
| `/terrafy:howto [topic]` | 사용 가이드 (주제별 사용법과 예시) |

### 인프라 관리
| 기능 | 설명 |
|------|------|
| `/terrafy:status` | 현재 환경 스캔 및 인프라 상태 표시 |
| `/terrafy:setup` | 대화형 인프라 구성 |
| `/terrafy:init-ssh` | SSH 서버 설정 |

## 역할 구조

| 역할 | 설명 | 기술 |
|------|------|------|
| 관문 (Gateway) | 외부 트래픽 라우팅 | Traefik + Ingress |
| 관제탑 (Orchestrator) | 서비스 배포/관리 | Portainer Server |
| 일꾼 (Worker) | 서비스 실행 | Docker + Portainer Agent |

## 더 알아보기

`/terrafy:howto`로 각 기능의 상세 사용법과 예시를 확인하세요.
