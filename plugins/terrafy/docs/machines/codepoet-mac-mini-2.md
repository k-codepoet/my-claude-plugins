# codepoet-mac-mini-2 (Mac Mini M4)

> Standalone Traefik 노드. 체인 미참여, Mac Mini 1에서 직접 라우팅.

## 하드웨어/OS

| 항목 | 값 |
|------|-----|
| 모델 | Mac Mini M4 |
| Arch | ARM64 |
| LAN IP | 192.168.0.37 |
| Tailscale | codepoet-mac-mini-2 / 100.120.134.19 |

## 역할

- **Standalone Traefik**: Mac Mini 1/NAS에서 특정 호스트 규칙으로 직접 라우팅
- **체인 미참여**: fallback 체인(Mac Mini 1 → NAS → Linux)에 포함되지 않음
- 자체 서비스 라우팅 + 404 fallback

```
Mac Mini 1 → (host 매칭) → Mac Mini 2:80 → 서비스 or 404
NAS (내부) → (host 매칭) → Mac Mini 2:80 → 서비스 or 404
```

## Docker 환경

| 항목 | 값 |
|------|-----|
| Engine | 28.4.0 |
| API | 1.51 |
| Compose | v5.0.2 |
| Platform | Docker Desktop |

> 전체 디바이스 비교: [docker-versions.md](../docker-versions.md)

### Docker Desktop 특이사항

Mac Mini 1과 동일 — non-interactive SSH에서 `docker` 명령이 PATH에 없음:

```bash
/usr/local/bin/docker ps
# 또는
PATH=/usr/local/bin:$PATH docker compose up -d
```

## 네트워크

- Docker 네트워크 이름: **`traefik`** (Mac Mini 1과 동일)

## 포트 사용 현황

| 포트 | 서비스 | 용도 |
|------|--------|------|
| 80 | Traefik | HTTP 수신 |
| 8080 | Traefik | Dashboard |
| 8082 | Fallback 404 | 404 페이지 |
| 9001 | Portainer Agent | Agent API |

> 전체 포트 할당표: [ports.md](../ports.md)

## 작업 경로

```
/Users/choigawoon/workspace/my-devops/
```

## 관련 문서

- [Docker 버전 현황](../docker-versions.md)
- [Traefik Chain 아키텍처](../../architecture/traefik-chain.md)
- [포트 할당표](../ports.md)
