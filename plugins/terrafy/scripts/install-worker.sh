#!/bin/bash
# install-worker.sh - Portainer Agent 설치
# Phase 4: Portainer 설치 - Worker 역할

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
if docker ps -a --format '{{.Names}}' | grep -q '^portainer_agent$'; then
    RUNNING=$(docker inspect -f '{{.State.Running}}' portainer_agent 2>/dev/null || echo "false")
    if [[ "$RUNNING" == "true" ]]; then
        if [[ "$JSON_OUTPUT" == "true" ]]; then
            echo "{\"success\":true,\"status\":\"already_running\",\"port\":\"9001\"}"
        else
            log "${GREEN}[✓]${NC} Portainer Agent가 이미 실행 중입니다"
        fi
        exit 0
    else
        log "${YELLOW}[!]${NC} 기존 Portainer Agent 컨테이너 발견 - 재시작합니다"
        docker start portainer_agent
        if [[ "$JSON_OUTPUT" == "true" ]]; then
            echo "{\"success\":true,\"status\":\"restarted\",\"port\":\"9001\"}"
        else
            log "${GREEN}[✓]${NC} Portainer Agent 재시작 완료"
        fi
        exit 0
    fi
fi

log "${GREEN}[*]${NC} Portainer Agent 설치 시작..."

# Portainer Agent 실행
log "  - Portainer Agent 컨테이너 실행..."
docker run -d \
    --name portainer_agent \
    -p 9001:9001 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    --restart always \
    portainer/agent:latest >/dev/null

# 시작 대기
log "  - 서비스 시작 대기..."
sleep 3

# 확인
if docker ps --format '{{.Names}}' | grep -q '^portainer_agent$'; then
    # 이 머신의 IP 가져오기
    MY_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || ip route get 1 2>/dev/null | awk '{print $7; exit}' || echo "localhost")

    if [[ "$JSON_OUTPUT" == "true" ]]; then
        echo "{\"success\":true,\"status\":\"installed\",\"port\":\"9001\",\"ip\":\"$MY_IP\"}"
    else
        log ""
        log "${GREEN}[✓]${NC} Portainer Agent 설치 완료!"
        log ""
        log "  Agent 주소: ${MY_IP}:9001"
        log ""
        log "${YELLOW}[!]${NC} 다음 단계:"
        log "  Portainer Server UI에서 이 Agent를 등록하세요:"
        log "  1. Environment → Add environment"
        log "  2. Docker Standalone → Start Wizard"
        log "  3. Agent 선택"
        log "  4. 환경 이름 입력 (예: worker-1)"
        log "  5. Agent URL: ${MY_IP}:9001"
    fi
else
    error "Portainer Agent 시작 실패"
fi
