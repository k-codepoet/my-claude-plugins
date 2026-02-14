# codepoet-linux-1 (Ubuntu 24.04)

> Traefik Chain 최종 노드 (404 fallback), GitLab Runner (amd64 native).

## 하드웨어/OS

| 항목 | 값 |
|------|-----|
| 모델 | MS-A2 |
| OS | Ubuntu 24.04 |
| Arch | AMD64 |
| LAN IP | 192.168.0.34 |
| Tailscale | codepoet-linux-1 / 100.111.155.113 |

## 역할

- **Traefik Chain Node 3 (404 fallback)**: 체인의 마지막 노드, 매칭되지 않는 모든 트래픽에 404 반환
- **GitLab Runner (amd64 native)**: Docker-in-Docker 모드, amd64 네이티브 빌드

## Docker 환경

| 항목 | 값 |
|------|-----|
| Engine | 29.1.3 |
| API | 1.52 |
| Compose | v5.0.0 |
| Platform | Docker CE |

> 전체 디바이스 비교: [docker-versions.md](../docker-versions.md)

Docker CE 환경으로, Docker Desktop의 PATH 이슈 없음.

## 네트워크

- Docker 네트워크 이름: **`traefik`**

## 포트 사용 현황

| 포트 | 서비스 | 용도 |
|------|--------|------|
| 80 | Traefik | HTTP (Chain Node 3) |
| 8080 | Traefik | Dashboard |
| 8081 | Welcome | Welcome 페이지 |
| 8082 | Fallback 404 | 404 페이지 |
| 9001 | Portainer Agent | Agent API |

> 전체 포트 할당표: [ports.md](../ports.md)

## 작업 경로

```
/home/choigawoon/k-codepoet/my-devops/
```

## 관련 문서

- [Docker 버전 현황](../docker-versions.md)
- [Traefik Chain 아키텍처](../../architecture/traefik-chain.md)
- [포트 할당표](../ports.md)
