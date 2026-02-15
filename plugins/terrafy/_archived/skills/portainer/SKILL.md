---
description: Portainer 기반 컨테이너 관리 환경 구축. Docker 컨테이너 관리, 스택 배포, GitOps 연동이 필요할 때 사용합니다.
---

# Portainer Setup Skill

## Overview

Portainer를 통한 Docker 컨테이너 관리 환경을 구축합니다. 웹 UI로 컨테이너, 스택, 이미지를 관리하고 GitOps를 연동할 수 있습니다.

## Platform Support

| Platform | Support |
|----------|---------|
| Linux Ubuntu | Full |
| macOS | Docker Desktop 필요 |
| Windows | Docker Desktop 필요 |

## Trigger Context

사용자가 다음과 같은 맥락일 때 이 스킬 활성화:
- "컨테이너 관리 환경 만들어줘"
- "Portainer 설치해줘"
- "Docker 스택 배포하고 싶어"
- "docker-compose를 웹에서 관리하고 싶어"
- "GitOps로 Docker 관리하고 싶어"

## Core Workflows

### 1. Prerequisites Check

```bash
# Docker 설치 확인
docker --version
docker compose version

# Docker 데몬 실행 확인
docker info
```

Docker 미설치 시:
```bash
# Ubuntu
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

### 2. Portainer Installation

#### Option A: Standalone (권장)

```bash
# Portainer 볼륨 생성
docker volume create portainer_data

# Portainer CE 실행
docker run -d \
  -p 8000:8000 \
  -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```

접속: `https://localhost:9443`

#### Option B: Docker Compose

```yaml
# docker-compose.yml
version: '3'
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: always
    ports:
      - "8000:8000"
      - "9443:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data

volumes:
  portainer_data:
```

### 3. Initial Setup

1. 브라우저에서 `https://<server-ip>:9443` 접속
2. 관리자 계정 생성
3. Environment 선택: "Get Started" (로컬 Docker)

### 4. GitOps Integration

Portainer에서 Git 저장소 기반 스택 배포:

#### 디렉토리 구조
```
~/my-iac/{hostname}/
├── traefik/
│   └── docker-compose.yml
├── monitoring/
│   └── docker-compose.yml
└── app/
    └── docker-compose.yml
```

#### Portainer 설정
1. **Stacks** → **Add Stack**
2. **Repository** 선택
3. 설정:
   - Repository URL: Git 저장소 URL
   - Compose path: `{hostname}/{service}/docker-compose.yml`
   - Authentication: 필요시 토큰 설정
4. **GitOps updates** 활성화
   - Polling interval: 5m (권장)
   - Re-pull image: 활성화

### 5. Stack Management

#### 스택 생성 (Web Editor)
1. Stacks → Add Stack
2. Web editor에 docker-compose 붙여넣기
3. Deploy

#### 스택 업데이트
- GitOps: Git push → 자동 반영
- Manual: Stacks → 스택 선택 → Editor → Update

### 6. Backup & Restore

#### Portainer 백업
```bash
# 볼륨 백업
docker run --rm \
  -v portainer_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/portainer-backup.tar.gz -C /data .
```

#### Portainer 복원
```bash
# 볼륨 복원
docker run --rm \
  -v portainer_data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/portainer-backup.tar.gz -C /data
```

## Common Stack Examples

### Traefik (Reverse Proxy)

```yaml
version: '3'
services:
  traefik:
    image: traefik:v2.10
    container_name: traefik
    restart: always
    ports:
      - "80:80"
      - "443:443"
    command:
      - "--api.dashboard=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_certs:/certs

volumes:
  traefik_certs:
```

### Monitoring (Prometheus + Grafana)

```yaml
version: '3'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"

volumes:
  prometheus_data:
  grafana_data:
```

## Error Handling

| Issue | Solution |
|-------|----------|
| Docker socket permission | `sudo usermod -aG docker $USER` 후 재로그인 |
| Port 9443 in use | 다른 포트로 변경: `-p 9444:9443` |
| Cannot connect | 방화벽 확인: `sudo ufw allow 9443` |
| GitOps not updating | Polling interval 확인, Git URL/인증 확인 |

## Security Considerations

- HTTPS 기본 (self-signed cert)
- 프로덕션에서는 Let's Encrypt 또는 자체 인증서 사용
- 외부 노출 시 방화벽/VPN 고려
- Edge Agent 사용 시 Tunnel 암호화

## Additional Resources

- [Portainer Documentation](https://docs.portainer.io/)
- [Portainer GitOps Guide](https://docs.portainer.io/user/docker/stacks/add#option-2-git-repository)
