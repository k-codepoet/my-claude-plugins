# codepoet-nas (Synology DS220+)

> NAS 환경 스펙, Docker 특이사항, 운영 노트.

## 하드웨어/OS

| 항목 | 값 |
|------|-----|
| 모델 | Synology DS220+ |
| CPU | Intel Celeron J4025 (2-core, 2.0GHz) |
| RAM | 10GB (2GB + 8GB 확장) |
| 스토리지 | 8TB RAID |
| OS | DSM 7.x |
| LAN IP | 192.168.0.14 |
| Tailscale | codepoet-nas / 100.125.241.80 |

## Docker 환경

| 항목 | 값 |
|------|-----|
| Engine | 24.0.2 (가장 낮음) |
| API | 1.43 |
| Compose | v2.20.1 (다른 머신은 v5.x) |
| Platform | Synology Container Manager |

> 전체 디바이스 비교: [docker-versions.md](../docker-versions.md)

compose 작성 시 API 1.43 호환성 확인 필요.

## Synology 특이사항

### 명령어 제한

표준 Linux 배포판과 달리 다음 명령어가 없거나 제한적:

- `groupadd`, `addgroup` — `/etc/group` 직접 편집 필요
- `newgrp` — SSH 재접속으로 그룹 변경사항 적용
- `systemctl` — DSM 서비스 관리 시스템 사용

### DSM 포트 충돌

DSM이 기본적으로 80, 443 포트를 점유. Docker 서비스는 다른 포트 사용해야 함.
- Traefik: 8880 포트 (80 대신)

### 파일 권한

- Synology 파일시스템 권한 시스템으로 `chmod` 필요한 경우 있음
- 특히 Docker 컨테이너에서 마운트하는 설정 파일
- DSM 업데이트 시 일부 설정(Docker 그룹, 파일 권한 등) 초기화될 수 있음

### Docker 소켓 권한 설정

sudo 없이 docker 명령어를 사용하려면 사용자를 docker 그룹에 추가해야 함:

1. 사용 가능한 GID 확인 (`/etc/group` 마지막 GID + 1)
2. `/etc/group` 직접 편집하여 docker 그룹 생성 및 사용자 추가
3. `sudo chown root:docker /var/run/docker.sock && sudo chmod 660 /var/run/docker.sock`
4. SSH 재접속으로 그룹 변경 적용 (`newgrp` 없으므로)
5. `docker ps`로 확인

> DSM 업데이트 후 재설정 필요할 수 있음.

## 볼륨 가이드라인

| 데이터 성격 | 볼륨 타입 | 예시 |
|------------|----------|------|
| **영속** (DB, 설정, 인증서) | 절대경로 호스트 마운트 | gitlab-ce data, adguard-home conf |
| **런타임** (매 시작 시 재생성) | named volume OK | Vault Agent secrets, traefik init config |

### 왜 절대경로인가?

Portainer GitOps는 Git repo를 NAS의 `/data/compose/{stack-id}/`에 clone. 상대경로(`./data/`)는 clone 경로 기준으로 해석되어 실제 데이터 위치와 불일치.

### 왜 named volume이 아닌가? (영속 데이터)

1. **접근성**: `/volume1/@docker/volumes/`에 root 소유로 저장 — NAS 사용자가 직접 접근/백업 불가
2. **가시성**: 데이터 위치를 compose 파일만 보고 파악 불가
3. **권한 충돌**: 컨테이너가 root로 생성한 파일에 호스트 도구가 접근 시 Permission denied

### 런타임 볼륨은 왜 OK?

- Vault Agent/init 컨테이너가 매 시작 시 새로 생성
- 보존 불필요 (재시작 시 재렌더링)
- 호스트에서 접근할 일 없음

> 상세: [stack-notes.md](../stack-notes.md#nas-볼륨-가이드라인)

### 현황

| NAS 서비스 | 영속 볼륨 | 런타임 볼륨 |
|-----------|----------|------------|
| gitlab-ce | 절대경로 호스트 마운트 | - |
| adguard-home | 절대경로 호스트 마운트 | - |
| cloudflared | - | named (secrets-vol, cloudflared_config) |
| traefik-nas | - | named (traefik_config, welcome_html) |
| portainer-agent | - | - (Docker socket만) |

## 네트워크

- Docker 네트워크 이름: **`gateway`** (다른 머신은 `traefik`)
- DSM 환경 분리를 위해 별도 네트워크명 사용

## 포트 사용 현황

| 포트 | 서비스 | 용도 |
|------|--------|------|
| 80, 443 | DSM | Web UI (Docker 사용 불가) |
| 8880 | Traefik | HTTP (Cloudflare Tunnel 수신) |
| 8080 | Traefik | Dashboard (LAN only) |
| 9002 | Portainer Agent | Agent API |
| 20080 | GitLab CE | HTTP |
| 20022 | GitLab CE | SSH |
| 53 | AdGuard Home | DNS |
| 3080 | AdGuard Home | Web UI |
| 22 | SSH | SSH 접근 |

> 전체 포트 할당표: [ports.md](../ports.md)

## 작업 경로

```
/volume1/workspaces/k-codepoet/my-devops/
```

## 보안

- Tailscale VPN 접근 권장
- Cloudflare Tunnel을 통한 HTTPS만 외부 노출
- 내부 서비스는 LAN/Tailscale에서만 접근

## 관련 문서

- [Docker 버전 현황](../docker-versions.md)
- [스택별 운영 노트](../stack-notes.md)
- [포트 할당표](../ports.md)
