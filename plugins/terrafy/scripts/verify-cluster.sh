#!/bin/bash
# verify-cluster.sh - 클러스터 검증
# Phase 6: 검증 - 전체 시스템 작동 확인

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

JSON_OUTPUT=false
DOMAIN=""
NODES=""  # 쉼표로 구분된 노드 이름 목록 (예: nas,mac,linux)

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --json) JSON_OUTPUT=true; shift ;;
        --domain) DOMAIN="$2"; shift 2 ;;
        --nodes) NODES="$2"; shift 2 ;;
        *) shift ;;
    esac
done

log() {
    [[ "$JSON_OUTPUT" == "false" ]] && echo -e "$1"
}

# 상태 저장
declare -A CHECK_RESULTS
OVERALL_STATUS="pass"

check() {
    local name=$1
    local result=$2
    local detail=$3

    CHECK_RESULTS["$name"]="$result:$detail"

    if [[ "$result" == "fail" ]]; then
        OVERALL_STATUS="fail"
    elif [[ "$result" == "warn" && "$OVERALL_STATUS" == "pass" ]]; then
        OVERALL_STATUS="warn"
    fi
}

# 대화형 모드
if [[ -z "$DOMAIN" ]]; then
    log ""
    read -p "  도메인 (예: codepoet.site): " DOMAIN
fi

if [[ -z "$NODES" ]]; then
    log ""
    log "${BLUE}[?]${NC} 검증할 노드 목록"
    log "  쉼표로 구분하여 입력하세요 (예: nas,mac,linux)"
    log ""
    read -p "  노드 목록: " NODES
fi

log ""
log "${BLUE}═══════════════════════════════════════════════════════════${NC}"
log "  Terrafy 클러스터 검증"
log "${BLUE}═══════════════════════════════════════════════════════════${NC}"
log ""

# 1. 로컬 Docker 상태 확인
log "${BLUE}[1/4]${NC} Docker 상태 확인"
log ""

if command -v docker &>/dev/null && docker info &>/dev/null; then
    log "  ${GREEN}[✓]${NC} Docker 실행 중"
    check "docker" "pass" "running"
else
    log "  ${RED}[✗]${NC} Docker 실행 안됨"
    check "docker" "fail" "not_running"
fi

# 2. Portainer 확인
log ""
log "${BLUE}[2/4]${NC} Portainer 상태 확인"
log ""

# Portainer Server
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^portainer$'; then
    log "  ${GREEN}[✓]${NC} Portainer Server 실행 중"
    check "portainer_server" "pass" "running"

    # 접근 테스트
    if curl -sk --max-time 5 https://localhost:9443 >/dev/null 2>&1; then
        log "  ${GREEN}[✓]${NC} Portainer UI 접근 가능"
        check "portainer_ui" "pass" "accessible"
    else
        log "  ${YELLOW}[~]${NC} Portainer UI 접근 확인 필요"
        check "portainer_ui" "warn" "check_manually"
    fi
else
    log "  ${YELLOW}[~]${NC} Portainer Server 없음 (다른 노드에 있을 수 있음)"
    check "portainer_server" "warn" "not_on_this_node"
fi

# Portainer Agent
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^portainer_agent$'; then
    log "  ${GREEN}[✓]${NC} Portainer Agent 실행 중"
    check "portainer_agent" "pass" "running"
else
    # Server가 있으면 Agent는 필요 없을 수 있음
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^portainer$'; then
        log "  ${YELLOW}[-]${NC} Portainer Agent 없음 (Server가 있어 불필요)"
        check "portainer_agent" "pass" "not_needed"
    else
        log "  ${RED}[✗]${NC} Portainer Agent 없음"
        check "portainer_agent" "fail" "not_running"
    fi
fi

# 3. Gateway 확인
log ""
log "${BLUE}[3/4]${NC} Gateway 상태 확인"
log ""

# cloudflared
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^cloudflared$'; then
    log "  ${GREEN}[✓]${NC} cloudflared 실행 중"
    check "cloudflared" "pass" "running"
else
    log "  ${YELLOW}[~]${NC} cloudflared 없음 (다른 노드에 있을 수 있음)"
    check "cloudflared" "warn" "not_on_this_node"
fi

# Traefik
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q '^traefik$'; then
    log "  ${GREEN}[✓]${NC} Traefik 실행 중"
    check "traefik" "pass" "running"

    # Dashboard 접근
    if curl -s --max-time 5 http://localhost:8080/api/overview >/dev/null 2>&1; then
        log "  ${GREEN}[✓]${NC} Traefik Dashboard 접근 가능"
        check "traefik_dashboard" "pass" "accessible"
    else
        log "  ${YELLOW}[~]${NC} Traefik Dashboard 접근 확인 필요"
        check "traefik_dashboard" "warn" "check_manually"
    fi
else
    log "  ${YELLOW}[~]${NC} Traefik 없음 (다른 노드에 있을 수 있음)"
    check "traefik" "warn" "not_on_this_node"
fi

# 4. 외부 접근 테스트
log ""
log "${BLUE}[4/4]${NC} 외부 접근 테스트"
log ""

# test.domain 테스트
log "  테스트 URL: https://test.${DOMAIN}"
if curl -sk --max-time 10 "https://test.${DOMAIN}" 2>/dev/null | grep -q "homelab"; then
    log "  ${GREEN}[✓]${NC} test.${DOMAIN} 접근 성공"
    check "test_domain" "pass" "accessible"
else
    log "  ${RED}[✗]${NC} test.${DOMAIN} 접근 실패"
    check "test_domain" "fail" "not_accessible"
fi

# 각 노드별 homelab-*.domain 테스트
IFS=',' read -ra NODE_ARRAY <<< "$NODES"
for node in "${NODE_ARRAY[@]}"; do
    node=$(echo "$node" | tr -d ' ')
    URL="https://homelab-${node}.${DOMAIN}"
    log ""
    log "  테스트 URL: ${URL}"

    if curl -sk --max-time 10 "$URL" 2>/dev/null | grep -q "homelab-${node}"; then
        log "  ${GREEN}[✓]${NC} homelab-${node}.${DOMAIN} 접근 성공"
        check "homelab_${node}" "pass" "accessible"
    else
        log "  ${RED}[✗]${NC} homelab-${node}.${DOMAIN} 접근 실패"
        check "homelab_${node}" "fail" "not_accessible"
    fi
done

# 결과 요약
log ""
log "${BLUE}═══════════════════════════════════════════════════════════${NC}"
log "  검증 결과"
log "${BLUE}═══════════════════════════════════════════════════════════${NC}"
log ""

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

for key in "${!CHECK_RESULTS[@]}"; do
    IFS=':' read -r result detail <<< "${CHECK_RESULTS[$key]}"
    case $result in
        pass) ((PASS_COUNT++)) ;;
        warn) ((WARN_COUNT++)) ;;
        fail) ((FAIL_COUNT++)) ;;
    esac
done

if [[ "$OVERALL_STATUS" == "pass" ]]; then
    log "  ${GREEN}[✓]${NC} 모든 검증 통과!"
    log ""
    log "  통과: ${PASS_COUNT}개"
    [[ $WARN_COUNT -gt 0 ]] && log "  경고: ${WARN_COUNT}개"
elif [[ "$OVERALL_STATUS" == "warn" ]]; then
    log "  ${YELLOW}[~]${NC} 일부 항목 확인 필요"
    log ""
    log "  통과: ${PASS_COUNT}개"
    log "  경고: ${WARN_COUNT}개"
else
    log "  ${RED}[✗]${NC} 일부 검증 실패"
    log ""
    log "  통과: ${PASS_COUNT}개"
    [[ $WARN_COUNT -gt 0 ]] && log "  경고: ${WARN_COUNT}개"
    log "  실패: ${FAIL_COUNT}개"
fi

log ""

# JSON 출력
if [[ "$JSON_OUTPUT" == "true" ]]; then
    RESULTS_JSON="{"
    for key in "${!CHECK_RESULTS[@]}"; do
        IFS=':' read -r result detail <<< "${CHECK_RESULTS[$key]}"
        RESULTS_JSON+="\"$key\":{\"status\":\"$result\",\"detail\":\"$detail\"},"
    done
    RESULTS_JSON="${RESULTS_JSON%,}}"

    echo "{\"success\":true,\"overall\":\"$OVERALL_STATUS\",\"pass\":$PASS_COUNT,\"warn\":$WARN_COUNT,\"fail\":$FAIL_COUNT,\"checks\":$RESULTS_JSON}"
fi

# 다음 단계 안내
if [[ "$OVERALL_STATUS" == "pass" ]]; then
    log "${GREEN}[✓]${NC} Terrafy 설정 완료!"
    log ""
    log "다음 단계:"
    log "  - /craftify:deploy 로 앱 배포"
    log "  - Portainer GitOps로 docker-compose.yml 자동 배포"
    log "  - 새 서비스는 Traefik labels로 자동 라우팅"
fi
