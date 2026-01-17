#!/bin/bash
# scan-network.sh - 같은 네트워크의 호스트 탐색
# Usage: ./scan-network.sh [--json] [--all]
#   --all: 모든 네트워크 표시 (기본: 물리 네트워크만)

set -e

JSON_OUTPUT=false
SHOW_ALL=false

for arg in "$@"; do
    case $arg in
        --json) JSON_OUTPUT=true ;;
        --all) SHOW_ALL=true ;;
    esac
done

# 내 IP 가져오기
get_my_ip() {
    if command -v ip &>/dev/null; then
        ip route get 1 2>/dev/null | awk '{print $7; exit}'
    elif command -v ipconfig &>/dev/null; then
        ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null
    else
        hostname -I 2>/dev/null | awk '{print $1}'
    fi
}

# 물리 네트워크 대역인지 확인 (Docker/K8s 내부 네트워크 제외)
is_physical_network() {
    local ip=$1
    local my_subnet=$(get_my_ip | sed 's/\.[0-9]*$/./')

    # 내 서브넷과 같은 대역만 물리 네트워크로 간주
    if [[ "$ip" =~ ^${my_subnet} ]]; then
        return 0
    fi
    return 1
}

# ARP 테이블에서 호스트 목록
get_arp_hosts() {
    local all_hosts
    if command -v arp &>/dev/null; then
        all_hosts=$(arp -a 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -u)
    elif command -v ip &>/dev/null; then
        all_hosts=$(ip neigh 2>/dev/null | awk '{print $1}' | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort -u)
    fi

    if $SHOW_ALL; then
        echo "$all_hosts"
    else
        # 물리 네트워크만 필터링
        for ip in $all_hosts; do
            is_physical_network "$ip" && echo "$ip"
        done
    fi
}

# 호스트 타입 추측 (포트 기반)
guess_host_type() {
    local ip=$1
    local type="unknown"

    # 빠른 포트 체크 (timeout 1초)
    if timeout 1 bash -c "echo >/dev/tcp/$ip/5000" 2>/dev/null; then
        type="nas"  # Synology DSM
    elif timeout 1 bash -c "echo >/dev/tcp/$ip/8080" 2>/dev/null; then
        type="server"
    elif timeout 1 bash -c "echo >/dev/tcp/$ip/22" 2>/dev/null; then
        type="ssh-host"
    elif timeout 1 bash -c "echo >/dev/tcp/$ip/80" 2>/dev/null; then
        type="web"
    fi

    echo "$type"
}

# 게이트웨이 IP
get_gateway() {
    if command -v ip &>/dev/null; then
        ip route | awk '/default/ {print $3; exit}'
    elif command -v netstat &>/dev/null; then
        netstat -rn | awk '/default|0.0.0.0/ {print $2; exit}'
    fi
}

MY_IP=$(get_my_ip)
GATEWAY=$(get_gateway)
HOSTS=$(get_arp_hosts)

if $JSON_OUTPUT; then
    echo "{"
    echo "  \"my_ip\": \"$MY_IP\","
    echo "  \"gateway\": \"$GATEWAY\","
    echo "  \"hosts\": ["

    first=true
    for ip in $HOSTS; do
        [[ "$ip" == "$MY_IP" ]] && continue

        type=$(guess_host_type "$ip")
        is_gateway="false"
        [[ "$ip" == "$GATEWAY" ]] && is_gateway="true"

        if $first; then
            first=false
        else
            echo ","
        fi
        echo -n "    {\"ip\": \"$ip\", \"type\": \"$type\", \"is_gateway\": $is_gateway}"
    done

    echo ""
    echo "  ]"
    echo "}"
else
    echo "=== Network Scan ==="
    echo "My IP: $MY_IP"
    echo "Gateway: $GATEWAY"
    echo ""
    echo "Discovered hosts:"

    for ip in $HOSTS; do
        [[ "$ip" == "$MY_IP" ]] && continue

        type=$(guess_host_type "$ip")
        marker=""
        [[ "$ip" == "$GATEWAY" ]] && marker=" (gateway)"

        echo "  • $ip [$type]$marker"
    done
fi
