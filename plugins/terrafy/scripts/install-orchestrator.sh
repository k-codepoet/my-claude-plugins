#!/bin/bash
# install-orchestrator.sh - Portainer Server 설치
# Phase 4: Portainer 설치 - Orchestrator 역할

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

JSON_OUTPUT=false
[[ "$1" == "--json" ]] && JSON_OUTPUT=true

log() {
    [[ "$JSON_OUTPUT" == "false" ]] && echo -e "$1"
}

error() {
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        echo "{\"success\":false,\"error\":\"$1\"}"
    else
        echo -e "${RED}[ERROR]${NC} $1" >&2
    fi
    exit 1
}

# Docker 확인
if ! command -v docker &>/dev/null; then
    error "Docker가 설치되어 있지 않습니다"
fi

if ! docker info &>/dev/null; then
    error "Docker 데몬이 실행 중이 아닙니다"
fi

# 이미 설치되어 있는지 확인
if docker ps -a --format '{{.Names}}' | grep -q '^portainer$'; then
    RUNNING=$(docker inspect -f '{{.State.Running}}' portainer 2>/dev/null || echo "false")
    if [[ "$RUNNING" == "true" ]]; then
        if [[ "$JSON_OUTPUT" == "true" ]]; then
            PORT=$(docker inspect -f '{{range $p, $conf := .NetworkSettings.Ports}}{{if eq $p "9443/tcp"}}{{(index $conf 0).HostPort}}{{end}}{{end}}' portainer 2>/dev/null || echo "9443")
            echo "{\"success\":true,\"status\":\"already_running\",\"port\":\"$PORT\",\"url\":\"https://localhost:$PORT\"}"
        else
            log "${GREEN}[✓]${NC} Portainer Server가 이미 실행 중입니다"
        fi
        exit 0
    else
        log "${YELLOW}[!]${NC} 기존 Portainer 컨테이너 발견 - 재시작합니다"
        docker start portainer
        if [[ "$JSON_OUTPUT" == "true" ]]; then
            echo "{\"success\":true,\"status\":\"restarted\",\"port\":\"9443\",\"url\":\"https://localhost:9443\"}"
        else
            log "${GREEN}[✓]${NC} Portainer Server 재시작 완료"
        fi
        exit 0
    fi
fi

log "${GREEN}[*]${NC} Portainer Server 설치 시작..."

# Volume 생성
log "  - 데이터 볼륨 생성..."
docker volume create portainer_data >/dev/null 2>&1 || true

# Portainer Server 실행
log "  - Portainer Server 컨테이너 실행..."
docker run -d \
    --name portainer \
    -p 9443:9443 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    --restart always \
    portainer/portainer-ce:latest >/dev/null

# 시작 대기
log "  - 서비스 시작 대기..."
sleep 5

# 확인
if docker ps --format '{{.Names}}' | grep -q '^portainer$'; then
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        echo "{\"success\":true,\"status\":\"installed\",\"port\":\"9443\",\"url\":\"https://localhost:9443\"}"
    else
        log ""
        log "${GREEN}[✓]${NC} Portainer Server 설치 완료!"
        log ""
        log "  접속 URL: https://localhost:9443"
        log "  (첫 접속 시 관리자 계정 생성 필요)"
        log ""
        log "${YELLOW}[!]${NC} 다음 단계:"
        log "  1. 브라우저에서 https://localhost:9443 접속"
        log "  2. 관리자 계정 생성"
        log "  3. 'Get Started' 클릭하여 Local 환경 추가"
        log "  4. Worker 노드들의 Agent 연결 (Environment → Add environment)"
    fi
else
    error "Portainer Server 시작 실패"
fi
