#!/bin/bash
# scan-host.sh - 현재 머신 정보 수집
# Usage: ./scan-host.sh [--json]

set -e

JSON_OUTPUT=false
[[ "$1" == "--json" ]] && JSON_OUTPUT=true

# OS 정보
get_os_info() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$NAME $VERSION_ID"
    elif command -v sw_vers &>/dev/null; then
        echo "macOS $(sw_vers -productVersion)"
    else
        uname -s
    fi
}

# 호스트명
get_hostname() {
    hostname 2>/dev/null || echo "unknown"
}

# IP 주소 (내부)
get_ip() {
    if command -v ip &>/dev/null; then
        ip route get 1 2>/dev/null | awk '{print $7; exit}'
    elif command -v ipconfig &>/dev/null; then
        ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null
    else
        hostname -I 2>/dev/null | awk '{print $1}'
    fi
}

# 서브넷 대역
get_subnet() {
    local ip=$(get_ip)
    if [[ -n "$ip" ]]; then
        echo "${ip%.*}.0/24"
    fi
}

# 아키텍처
get_arch() {
    uname -m
}

# 메모리 (GB)
get_memory_gb() {
    if [[ -f /proc/meminfo ]]; then
        awk '/MemTotal/ {printf "%.1f", $2/1024/1024}' /proc/meminfo
    elif command -v sysctl &>/dev/null; then
        sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.1f", $1/1024/1024/1024}'
    else
        echo "unknown"
    fi
}

# 디스크 (루트 파티션)
get_disk_info() {
    df -h / 2>/dev/null | awk 'NR==2 {print $2 " total, " $4 " available"}'
}

# 결과 출력
OS=$(get_os_info)
HOSTNAME=$(get_hostname)
IP=$(get_ip)
SUBNET=$(get_subnet)
ARCH=$(get_arch)
MEMORY=$(get_memory_gb)
DISK=$(get_disk_info)

if $JSON_OUTPUT; then
    cat <<EOF
{
  "hostname": "$HOSTNAME",
  "os": "$OS",
  "arch": "$ARCH",
  "ip": "$IP",
  "subnet": "$SUBNET",
  "memory_gb": "$MEMORY",
  "disk": "$DISK"
}
EOF
else
    echo "=== Host Info ==="
    echo "Hostname: $HOSTNAME"
    echo "OS: $OS"
    echo "Arch: $ARCH"
    echo "IP: $IP"
    echo "Subnet: $SUBNET"
    echo "Memory: ${MEMORY}GB"
    echo "Disk: $DISK"
fi
