#!/bin/bash
# check-docker.sh - Docker 설치 및 실행 상태 확인
# Usage: ./check-docker.sh [--json]

set -e

JSON_OUTPUT=false
[[ "$1" == "--json" ]] && JSON_OUTPUT=true

INSTALLED=false
RUNNING=false
VERSION=""
COMPOSE_VERSION=""
CONTAINERS=0
NETWORKS=""

# Docker 설치 확인
if command -v docker &>/dev/null; then
    INSTALLED=true
    VERSION=$(docker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

    # Docker 실행 확인
    if docker info &>/dev/null; then
        RUNNING=true
        CONTAINERS=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
        NETWORKS=$(docker network ls --format '{{.Name}}' 2>/dev/null | grep -vE '^(bridge|host|none)$' | tr '\n' ',' | sed 's/,$//')
    fi

    # Docker Compose 확인
    if docker compose version &>/dev/null; then
        COMPOSE_VERSION=$(docker compose version --short 2>/dev/null)
    elif command -v docker-compose &>/dev/null; then
        COMPOSE_VERSION=$(docker-compose --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    fi
fi

if $JSON_OUTPUT; then
    cat <<EOF
{
  "installed": $INSTALLED,
  "running": $RUNNING,
  "version": "$VERSION",
  "compose_version": "$COMPOSE_VERSION",
  "containers_running": $CONTAINERS,
  "custom_networks": "$NETWORKS"
}
EOF
else
    echo "=== Docker Status ==="
    if $INSTALLED; then
        echo "Installed: yes (v$VERSION)"
        if [[ -n "$COMPOSE_VERSION" ]]; then
            echo "Compose: v$COMPOSE_VERSION"
        else
            echo "Compose: not found"
        fi

        if $RUNNING; then
            echo "Running: yes"
            echo "Containers: $CONTAINERS running"
            if [[ -n "$NETWORKS" ]]; then
                echo "Networks: $NETWORKS"
            fi
        else
            echo "Running: no (daemon not running)"
        fi
    else
        echo "Installed: no"
    fi
fi
