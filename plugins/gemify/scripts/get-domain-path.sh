#!/bin/bash
# gemify get-domain-path - 현재 활성 도메인의 경로를 반환
#
# Usage:
#   get-domain-path.sh              # 현재 도메인 경로 반환
#   get-domain-path.sh --name       # 현재 도메인 이름만 반환
#   get-domain-path.sh --json       # config.json 전체 반환
#   get-domain-path.sh --list       # 도메인 목록 반환
#
# Exit codes:
#   0: 성공
#   1: config.json 없음 또는 파싱 오류
#   2: 도메인 경로가 존재하지 않음

set -e

GEMIFY_ROOT="${HOME}/.gemify"
CONFIG_FILE="${GEMIFY_ROOT}/config.json"

# config.json 존재 확인
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: ${CONFIG_FILE} not found" >&2
    exit 1
fi

# jq 존재 확인
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is required but not installed" >&2
    exit 1
fi

# 옵션 파싱
case "${1:-}" in
    --name)
        # 도메인 이름만 반환
        # 우선순위: 환경변수 > cwd 기반 > config current
        if [[ -n "${GEMIFY_DOMAIN:-}" ]]; then
            echo "$GEMIFY_DOMAIN"
        elif [[ "$PWD" == "$GEMIFY_ROOT"/* ]]; then
            # cwd가 ~/.gemify/{domain}/ 하위인지 체크
            RELATIVE_PATH="${PWD#$GEMIFY_ROOT/}"
            DOMAIN_FROM_CWD="${RELATIVE_PATH%%/*}"
            if jq -e ".domains[\"$DOMAIN_FROM_CWD\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
                echo "$DOMAIN_FROM_CWD"
            else
                jq -r '.current' "$CONFIG_FILE"
            fi
        else
            jq -r '.current' "$CONFIG_FILE"
        fi
        ;;
    --json)
        # config.json 전체 반환
        cat "$CONFIG_FILE"
        ;;
    --list)
        # 도메인 목록 반환 (name path description)
        CURRENT=$(jq -r '.current' "$CONFIG_FILE")
        jq -r --arg current "$CURRENT" '.domains | to_entries[] |
            (if .key == $current then "* " else "  " end) +
            .key + "\t" + .value.path + "\t" + .value.description' "$CONFIG_FILE"
        ;;
    --help|-h)
        echo "Usage: get-domain-path.sh [--name|--json|--list|--help]"
        echo ""
        echo "Options:"
        echo "  (none)    Return current domain path"
        echo "  --name    Return current domain name only"
        echo "  --json    Return full config.json"
        echo "  --list    Return domain list"
        echo ""
        echo "Priority: GEMIFY_DOMAIN env > cwd-based > config.json current"
        ;;
    *)
        # 기본: 도메인 경로 반환
        # 우선순위: 환경변수 > cwd 기반 > config current
        if [[ -n "${GEMIFY_DOMAIN:-}" ]]; then
            DOMAIN="$GEMIFY_DOMAIN"
        elif [[ "$PWD" == "$GEMIFY_ROOT"/* ]]; then
            RELATIVE_PATH="${PWD#$GEMIFY_ROOT/}"
            DOMAIN_FROM_CWD="${RELATIVE_PATH%%/*}"
            if jq -e ".domains[\"$DOMAIN_FROM_CWD\"]" "$CONFIG_FILE" > /dev/null 2>&1; then
                DOMAIN="$DOMAIN_FROM_CWD"
            else
                DOMAIN=$(jq -r '.current' "$CONFIG_FILE")
            fi
        else
            DOMAIN=$(jq -r '.current' "$CONFIG_FILE")
        fi

        # 경로 가져오기 (~ 확장)
        RAW_PATH=$(jq -r --arg d "$DOMAIN" '.domains[$d].path' "$CONFIG_FILE")
        DOMAIN_PATH="${RAW_PATH/#\~/$HOME}"

        # 경로 존재 확인
        if [[ ! -d "$DOMAIN_PATH" ]]; then
            echo "ERROR: Domain path does not exist: $DOMAIN_PATH" >&2
            exit 2
        fi

        echo "$DOMAIN_PATH"
        ;;
esac
