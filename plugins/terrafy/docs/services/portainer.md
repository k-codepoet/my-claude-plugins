# Portainer

> Docker 관리 UI. Server + Agent 구조로 전체 머신 관리.

## 구성

| 역할 | 머신 | 포트 | 이미지 |
|------|------|------|--------|
| **Server** | Mac Mini 1 (.48) | 29000 (HTTP), 29443 (HTTPS) | portainer/portainer-ce:2.33.6 |
| **Agent** | NAS (.14) | 9002 | portainer/agent:2.33.6 |
| **Agent** | Linux (.34) | 9001 | portainer/agent:latest |
| **Agent** | Mac Mini 2 (.37) | 9001 | portainer/agent:latest |

## Server (Mac Mini 1)

- 접속: http://192.168.0.48:29000 또는 https://portainer.home.codepoet.site
- 데이터: `/Volumes/mac-ext-storage/.portainer/data`
- Traefik 연동 (HTTP + HTTPS)

## Agent 연결

Portainer Server → Environments → Add environment → Agent:

| Agent | URL |
|-------|-----|
| NAS | `192.168.0.14:9002` |
| Linux | `192.168.0.34:9001` |
| Mac Mini 2 | `192.168.0.37:9001` |

Tailscale 사용 시 호스트명으로도 접근 가능.

## 볼륨 매핑 차이

### NAS Agent

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
  - /volume1/@docker/volumes:/var/lib/docker/volumes  # NAS Docker 볼륨 경로
  - /:/host                                            # 전체 호스트 파일시스템
```

### Linux / Mac Mini 2 Agent

```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
  - /var/lib/docker/volumes:/var/lib/docker/volumes    # 표준 Docker 경로
```

## Agent 이미지 특이사항

Portainer Agent 이미지는 매우 경량화되어 쉘이 포함되지 않음:

```bash
# 모두 작동하지 않음
docker compose exec portainer-agent /bin/bash
docker compose exec portainer-agent /bin/sh
docker compose exec portainer-agent whoami
```

### 디버그 방법

1. **로그 확인** (권장): `docker compose logs -f portainer-agent`
2. **호스트에서 직접 접근**: NAS Agent는 `/:/host` 마운트 있음
3. **임시 컨테이너**: `docker run -it --rm --network container:portainer_agent --volumes-from portainer_agent busybox sh`

## 환경 변수

- **AGENT_SECRET** (NAS): Portainer Server-Agent 간 인증 시크릿 (선택)
- **AGENT_CLUSTER_ADDR** (Linux/Mac Mini 2): `tasks.portainer-agent`

## 관련 문서

- [codepoet-mac-mini-1](../machines/codepoet-mac-mini-1.md) — Server
- [codepoet-nas](../machines/codepoet-nas.md) — NAS Agent
- [codepoet-linux-1](../machines/codepoet-linux-1.md) — Linux Agent
