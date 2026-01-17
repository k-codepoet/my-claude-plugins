#!/bin/bash
# check-services.sh - Terrafy 핵심 서비스 상태 확인
# Usage: ./check-services.sh [--json]

set -e

JSON_OUTPUT=false
[[ "$1" == "--json" ]] && JSON_OUTPUT=true

# 서비스 상태 확인 함수
check_container() {
    local name=$1
    local status=""
    local running=false

    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${name}$"; then
        running=true
        status=$(docker ps --filter "name=^${name}$" --format '{{.Status}}' 2>/dev/null | head -1)
    elif docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${name}$"; then
        status="stopped"
    else
        status="not found"
    fi

    echo "$running|$status"
}

# Traefik
TRAEFIK_RESULT=$(check_container "traefik")
TRAEFIK_RUNNING=$(echo "$TRAEFIK_RESULT" | cut -d'|' -f1)
TRAEFIK_STATUS=$(echo "$TRAEFIK_RESULT" | cut -d'|' -f2)

# Portainer (Server)
PORTAINER_RESULT=$(check_container "portainer")
PORTAINER_RUNNING=$(echo "$PORTAINER_RESULT" | cut -d'|' -f1)
PORTAINER_STATUS=$(echo "$PORTAINER_RESULT" | cut -d'|' -f2)

# Portainer Agent
AGENT_RESULT=$(check_container "portainer_agent")
AGENT_RUNNING=$(echo "$AGENT_RESULT" | cut -d'|' -f1)
AGENT_STATUS=$(echo "$AGENT_RESULT" | cut -d'|' -f2)

# cloudflared
CLOUDFLARED_RESULT=$(check_container "cloudflared")
CLOUDFLARED_RUNNING=$(echo "$CLOUDFLARED_RESULT" | cut -d'|' -f1)
CLOUDFLARED_STATUS=$(echo "$CLOUDFLARED_RESULT" | cut -d'|' -f2)

# Gateway network
GATEWAY_NETWORK=false
if docker network ls --format '{{.Name}}' 2>/dev/null | grep -q "^gateway$"; then
    GATEWAY_NETWORK=true
fi

# 역할 판단
ROLE_GATEWAY="none"        # none | partial | configured
ROLE_ORCHESTRATOR=false
ROLE_WORKER=false

# Gateway = cloudflared + Traefik (둘 다 있어야 완전)
if [[ "$CLOUDFLARED_RUNNING" == "true" && "$TRAEFIK_RUNNING" == "true" ]]; then
    ROLE_GATEWAY="configured"
elif [[ "$CLOUDFLARED_RUNNING" == "true" || "$TRAEFIK_RUNNING" == "true" ]]; then
    ROLE_GATEWAY="partial"
fi

[[ "$PORTAINER_RUNNING" == "true" ]] && ROLE_ORCHESTRATOR=true
[[ "$AGENT_RUNNING" == "true" ]] && ROLE_WORKER=true

# Docker만 있으면 Worker 준비됨
if command -v docker &>/dev/null && docker info &>/dev/null; then
    DOCKER_READY=true
else
    DOCKER_READY=false
fi

if $JSON_OUTPUT; then
    cat <<EOF
{
  "services": {
    "traefik": {"running": $TRAEFIK_RUNNING, "status": "$TRAEFIK_STATUS"},
    "portainer": {"running": $PORTAINER_RUNNING, "status": "$PORTAINER_STATUS"},
    "portainer_agent": {"running": $AGENT_RUNNING, "status": "$AGENT_STATUS"},
    "cloudflared": {"running": $CLOUDFLARED_RUNNING, "status": "$CLOUDFLARED_STATUS"}
  },
  "gateway_network": $GATEWAY_NETWORK,
  "docker_ready": $DOCKER_READY,
  "roles": {
    "gateway": "$ROLE_GATEWAY",
    "orchestrator": $ROLE_ORCHESTRATOR,
    "worker": $ROLE_WORKER
  }
}
EOF
else
    echo "=== Services Status ==="
    echo ""
    echo "[Gateway]"
    echo "  Traefik: $TRAEFIK_STATUS"
    echo "  cloudflared: $CLOUDFLARED_STATUS"
    echo "  gateway network: $( $GATEWAY_NETWORK && echo 'exists' || echo 'not found' )"
    echo ""
    echo "[Orchestrator]"
    echo "  Portainer: $PORTAINER_STATUS"
    echo ""
    echo "[Worker]"
    echo "  Portainer Agent: $AGENT_STATUS"
    echo "  Docker: $( $DOCKER_READY && echo 'ready' || echo 'not ready' )"
    echo ""
    echo "=== Roles ==="
    case "$ROLE_GATEWAY" in
        "configured") echo "  [x] Gateway (cloudflared + Traefik)" ;;
        "partial")
            if [[ "$TRAEFIK_RUNNING" == "true" ]]; then
                echo "  [?] Gateway: Traefik만 있음 (cloudflared 없음 - 다른 방식?)"
            else
                echo "  [?] Gateway: cloudflared만 있음 (Traefik 없음)"
            fi
            ;;
        *) echo "  [ ] Gateway" ;;
    esac
    $ROLE_ORCHESTRATOR && echo "  [x] Orchestrator" || echo "  [ ] Orchestrator"
    $ROLE_WORKER && echo "  [x] Worker" || ( $DOCKER_READY && echo "  [~] Worker (ready)" || echo "  [ ] Worker" )
fi
