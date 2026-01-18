#!/usr/bin/env bash
set -euo pipefail

# 세션 파일 마이그레이션 스크립트
# YYYY-MM-DD-{slug}.md -> YYYYMMDD-HHMMSS-{slug}.md
# frontmatter에 created_at 추가
#
# 사용법:
#   migrate-sessions.sh [--dry-run] [sessions_dir]
#
# 예시:
#   migrate-sessions.sh --dry-run          # dry run (기본: ~/.gemify/sessions)
#   migrate-sessions.sh                    # 실제 마이그레이션
#   migrate-sessions.sh /path/to/sessions  # 커스텀 경로

SESSIONS_DIR="${HOME}/.gemify/sessions"
DRY_RUN=false

# 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            SESSIONS_DIR="$1"
            shift
            ;;
    esac
done

if [[ ! -d "$SESSIONS_DIR" ]]; then
    echo "Error: Directory not found: $SESSIONS_DIR"
    exit 1
fi

if [[ "$DRY_RUN" == "true" ]]; then
    echo "=== DRY RUN MODE ==="
fi

cd "$SESSIONS_DIR"

migrated=0
skipped=0

for file in *.md; do
    [[ "$file" == "*.md" ]] && break  # no matches
    [[ "$file" == "_template.md" ]] && continue

    # 이미 새 포맷인지 확인 (YYYYMMDD-HHMMSS-*.md)
    if [[ "$file" =~ ^[0-9]{8}-[0-9]{6}- ]]; then
        ((skipped++))
        continue
    fi

    # 파일명에서 날짜와 slug 추출
    if [[ "$file" =~ ^([0-9]{4})-([0-9]{2})-([0-9]{2})-(.+)\.md$ ]]; then
        orig_year="${BASH_REMATCH[1]}"
        orig_month="${BASH_REMATCH[2]}"
        orig_day="${BASH_REMATCH[3]}"
        slug="${BASH_REMATCH[4]}"
        date_part="${orig_year}${orig_month}${orig_day}"
        date_only="${orig_year}-${orig_month}-${orig_day}"
    else
        echo "[SKIP] Unknown format: $file"
        ((skipped++))
        continue
    fi

    # Birth time에서 시간만 추출
    birth_time=$(stat --format='%W' "$file" 2>/dev/null || echo "0")
    if [[ "$birth_time" == "0" || -z "$birth_time" ]]; then
        birth_time=$(stat --format='%Y' "$file")
    fi
    time_part=$(date -d "@$birth_time" '+%H%M%S')
    time_colon=$(date -d "@$birth_time" '+%H:%M:%S')

    # ISO 8601 형식 (원본 날짜 + Birth 시간)
    iso_time="${date_only}T${time_colon}+09:00"

    # 새 파일명
    new_file="${date_part}-${time_part}-${slug}.md"

    echo "$file -> $new_file"

    if [[ "$DRY_RUN" == "false" ]]; then
        # frontmatter에 created_at 추가
        if grep -q "^created_at:" "$file"; then
            sed -i "s/^created_at:.*$/created_at: \"$iso_time\"/" "$file"
        else
            sed -i "/^date:/a created_at: \"$iso_time\"" "$file"
        fi

        mv "$file" "$new_file"
        ((migrated++))
    fi
done

echo "========================================"
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry run complete. Run without --dry-run to apply."
else
    echo "Migration complete: $migrated migrated, $skipped skipped"
fi
