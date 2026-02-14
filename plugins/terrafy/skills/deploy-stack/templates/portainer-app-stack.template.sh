#!/usr/bin/env bash
# =============================================================================
# Portainer App Stack 등록 템플릿
# =============================================================================
# 앱 서비스(별도 repo)를 Portainer API로 스택 등록하는 예시.
# my-devops의 portainer-gitops.sh 는 인프라/서비스용이므로,
# 별도 app repo 스택은 이 패턴으로 직접 API 호출.
#
# 플레이스홀더:
#   {PORTAINER_URL}  — Portainer 접근 URL (예: https://host:29443)
#   {ENDPOINT_ID}    — Portainer Endpoint ID (정수)
#   {STACK_NAME}     — 스택 이름
#   {REPO_URL}       — Git repo URL
#   {COMPOSE_PATH}   — repo 내 compose 파일 경로
#   {BRANCH}         — Git branch (예: main)
#   {GIT_USERNAME}   — Git 사용자명 (private repo인 경우)
#   {GIT_PAT}        — Git Personal Access Token (private repo인 경우)
# =============================================================================
set -euo pipefail

PORTAINER_URL="{PORTAINER_URL}"
ENDPOINT_ID="{ENDPOINT_ID}"
STACK_NAME="{STACK_NAME}"
REPO_URL="{REPO_URL}"
COMPOSE_PATH="{COMPOSE_PATH}"
BRANCH="{BRANCH}"

# --- Portainer API Token (환경변수 또는 Vault에서 주입) ---
: "${PORTAINER_API_TOKEN:?PORTAINER_API_TOKEN 환경변수를 설정하세요}"

# --- Stack 생성 (GitOps) ---
curl -s -X POST "${PORTAINER_URL}/api/stacks/create/standalone/repository?endpointId=${ENDPOINT_ID}" \
  -H "X-API-Key: ${PORTAINER_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "name": "${STACK_NAME}",
  "repositoryURL": "${REPO_URL}",
  "repositoryReferenceName": "refs/heads/${BRANCH}",
  "composeFile": "${COMPOSE_PATH}",
  "repositoryAuthentication": true,
  "repositoryUsername": "{GIT_USERNAME}",
  "repositoryPassword": "{GIT_PAT}",
  "autoUpdate": {
    "interval": "5m",
    "webhook": ""
  }
}
EOF

echo "Stack '${STACK_NAME}' 생성 완료"
