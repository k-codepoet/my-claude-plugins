# Docker Maintenance Guide

> Docker 용량 관리 및 유지보수 가이드

## 문제 상황

Docker Desktop의 `Docker.raw` 파일이 비정상적으로 증가할 수 있음:
- `:latest` 태그 사용 시 업스트림 업데이트마다 dangling 이미지 발생
- AutoUpdate 간격이 짧으면 불필요한 이미지 풀 증가
- 정기 정리가 없으면 누적

## 예방 조치

### 1. 고정 버전 사용

`:latest` 대신 구체적인 버전 태그 사용:

```yaml
# Bad
image: grafana/grafana-oss:latest

# Good
image: grafana/grafana-oss:11.4.0
```

현재 고정된 이미지:
- `grafana/grafana-oss:11.4.0`
- `vaultwarden/server:1.32.5`
- `portainer/portainer-ce:2.21.4`

### 2. AutoUpdate 간격

`scripts/portainer-gitops.sh`에서 설정:
```bash
AUTO_UPDATE_INTERVAL="${AUTO_UPDATE_INTERVAL:-24h}"
```

기존 스택은 Portainer UI에서 수정하거나 재생성 필요.

### AutoUpdate 사용 기준

| 서비스 유형 | 추천 방식 | 이유 |
|------------|----------|------|
| **인프라/플랫폼** (traefik, vault, grafana 등) | AutoUpdate 24h + 고정 버전 | 안정성 중요, 빈번한 배포 불필요 |
| **앱 개발** (빠른 피드백 필요) | AutoUpdate 끄고 Webhook 또는 수동 | push 후 즉시 배포 가능 |

**개발자가 tag push 후 바로 결과를 보고 싶다면:**

1. **Webhook 방식** (권장)
   - Portainer에서 스택별 Webhook URL 생성
   - GitHub Actions에서 push 시 Webhook 호출
   - 필요할 때만 즉시 배포

2. **수동 배포**
   ```bash
   ./scripts/portainer-gitops.sh redeploy my-app
   ```

3. **짧은 AutoUpdate 간격** (비권장)
   - 고정 버전 사용 시 용량 문제는 적음
   - 하지만 불필요한 체크로 리소스 낭비

**이 repo (my-devops)는 인프라용**이므로 24h AutoUpdate가 적절합니다.
앱 서비스 repo는 별도로 Webhook 방식을 권장합니다.

### 3. Docker Desktop 디스크 제한 (Mac)

Settings → Resources → Advanced:
- **Virtual disk limit**: 64GB 권장
- **Memory**: 4-6GB
- **CPUs**: 2-4

## 정리 스크립트

### 수동 실행

```bash
# 로컬 정리
./scripts/docker-cleanup.sh

# 모든 디바이스 정리 (SSH)
./scripts/docker-cleanup.sh all
```

### cron 설정 (자동화)

```bash
# crontab -e
# 매일 새벽 3시 실행
0 3 * * * /path/to/my-devops/scripts/docker-cleanup.sh >> /var/log/docker-cleanup.log 2>&1
```

### 직접 명령어

```bash
# Dangling 이미지 정리
docker image prune -f

# 사용하지 않는 볼륨 정리
docker volume prune -f

# 빌드 캐시 정리
docker builder prune -f

# 전체 정리 (주의: 사용하지 않는 모든 리소스 삭제)
docker system prune -a --volumes -f
```

## 용량 확인

```bash
# Docker 디스크 사용량
docker system df

# 상세 정보
docker system df -v

# Mac Docker.raw 파일 크기
du -h ~/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw
```

## 트러블슈팅

### Docker Desktop 먹통

1. Docker Desktop 완전 종료:
   ```bash
   killall "Docker Desktop"
   killall com.docker.backend
   ```

2. 30초 대기 후 재시작

3. 여전히 문제 시 → Factory Reset (Settings → Troubleshoot)

### Docker.raw 파일 축소

Docker Desktop이 정상 작동할 때:
1. `docker system prune -a --volumes -f` 실행
2. Docker Desktop 재시작
3. 파일이 자동으로 축소되지 않으면 → Factory Reset 필요

## 모니터링

정기적으로 확인:
```bash
# 디스크 사용량
docker system df

# Dangling 이미지 수
docker images -f "dangling=true" -q | wc -l
```

권장: 주 1회 `docker-cleanup.sh` 실행
