#!/usr/bin/env bash
# my-devops 내 설치/관리 스크립트를 MinIO 버킷에 동기화.
# 로컬에서 실행: ./scripts/sync-scripts-to-minio.sh
# 각 머신에서는 mc cat으로 받아서 실행.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVOPS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$DEVOPS_ROOT"

MC_ALIAS="${MC_ALIAS:-nas-minio}"
BUCKET="${BUCKET:-devops-scripts}"
DRY_RUN="${DRY_RUN:-}"

if ! command -v mc &>/dev/null; then
  echo "mc (MinIO Client) 필요. 설치: brew install minio/stable/mc"
  exit 1
fi

if ! mc ls "$MC_ALIAS/$BUCKET" &>/dev/null; then
  echo "버킷 생성: $MC_ALIAS/$BUCKET"
  mc mb "$MC_ALIAS/$BUCKET" --ignore-existing
fi

echo "==> 동기화 대상: $DEVOPS_ROOT -> $MC_ALIAS/$BUCKET/"
index=""

while IFS= read -r -d '' f; do
  rel="${f#$DEVOPS_ROOT/}"
  rel="${rel#/}"
  rel="${rel#./}"
  if [[ -n "$DRY_RUN" ]]; then
    echo "  [dry-run] $rel"
  else
    mc cp "$f" "$MC_ALIAS/$BUCKET/$rel"
    echo "  $rel"
  fi
  index="$index$rel"$'\n'
done < <(find . -type f -name "*.sh" ! -path "./.git/*" | sort | tr '\n' '\0')

# 인덱스 파일: 머신에서 mc cat nas-minio/devops-scripts/scripts-index.txt 로 목록 확인
if [[ -z "$DRY_RUN" ]]; then
  echo "$index" | mc pipe "$MC_ALIAS/$BUCKET/scripts-index.txt"
  echo "  scripts-index.txt (목록)"
fi

echo "==> 완료."
echo ""
echo "각 머신에서 실행 예:"
echo "  mc cat $MC_ALIAS/$BUCKET/scripts-index.txt                    # 목록"
echo "  mc cat $MC_ALIAS/$BUCKET/services/codepoet-mac-mini-2/gitlab-runner-shell/install.sh | bash"
