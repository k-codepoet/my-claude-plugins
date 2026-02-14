#!/bin/bash
# Docker Cleanup Script
# 정기적으로 실행하여 dangling 이미지/볼륨/빌드 캐시 정리
#
# 사용법:
#   ./docker-cleanup.sh          # 로컬 실행
#   ./docker-cleanup.sh all      # 모든 디바이스에서 실행 (SSH)
#
# cron 예시 (매일 새벽 3시):
#   0 3 * * * /path/to/docker-cleanup.sh >> /var/log/docker-cleanup.log 2>&1

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

cleanup_local() {
    log_info "Starting Docker cleanup..."

    echo ""
    log_info "=== Before cleanup ==="
    docker system df

    echo ""
    log_info "Removing dangling images..."
    docker image prune -f

    echo ""
    log_info "Removing unused volumes..."
    docker volume prune -f

    echo ""
    log_info "Removing build cache..."
    docker builder prune -f

    echo ""
    log_info "=== After cleanup ==="
    docker system df

    echo ""
    log_info "Cleanup complete!"
}

cleanup_remote() {
    local host="$1"
    local docker_path="$2"

    log_info "Cleaning up $host..."
    ssh "$host" "$docker_path image prune -f && $docker_path volume prune -f && $docker_path builder prune -f" 2>/dev/null || {
        log_warn "Failed to cleanup $host (may be offline)"
    }
}

cleanup_all() {
    log_info "=== Cleaning all devices ==="

    # Mac Mini
    log_info "Mac Mini (codepoet-mac-mini-1)..."
    cleanup_remote "codepoet-mac-mini-1" "/usr/local/bin/docker"

    # NAS
    log_info "NAS (codepoet-nas)..."
    cleanup_remote "codepoet-nas" "/usr/local/bin/docker"

    # Linux
    log_info "Linux (codepoet-linux-1)..."
    cleanup_remote "codepoet-linux-1" "docker"

    log_info "=== All devices cleaned ==="
}

# Main
case "${1:-}" in
    all)
        cleanup_all
        ;;
    *)
        cleanup_local
        ;;
esac
