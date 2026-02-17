---
description: repo 초기화, git 설정, dual push, GitLab push mirror, GitHub mirror, git remote, 미러링, repo 만들기, init-repo
allowed-tools: Bash, Read, Write
---

# Git Repo 초기화 + Mirror 설정

새 프로젝트의 Git repo를 GitHub + Self-hosted GitLab CE 양쪽에 생성하고, dual push 또는 GitLab Push Mirror로 동기화를 설정한다.

## Git Hosting Backends

| Backend | 상태 | 설명 |
|---------|------|------|
| **GitHub + Self-hosted GitLab CE** | 현재 사용 | GitLab이 SSOT, GitHub는 mirror/backup |
| GitHub + GitLab SaaS | 확장 가능 | SaaS 전환 시 |

## Core Process (범용)

Git hosting backend에 무관하게 적용되는 repo 초기화 + mirror 설정 흐름:

```
1. GitHub Repo    → GitHub에 repo 확인/생성
2. GitLab Repo    → GitLab에 repo 생성
3. Remote 설정    → origin fetch=GitLab, push=GitLab+GitHub dual push
4. Initial Push   → git push -u origin main
5. Push Mirror    → GitLab Push Mirror 설정 (GitLab → GitHub 자동 동기화)
6. Verify         → git remote -v + mirror 상태 확인
```

## Current Implementation: GitHub + Self-hosted GitLab CE

### Step 1: GitHub repo 확인/생성

```bash
gh repo create {GROUP}/{PROJECT} --public
```

- 이미 존재하면 skip
- `--private` 사용 가능 (mirror 시 PAT에 private repo 접근 권한 필요)

### Step 2: GitLab repo 생성

```bash
glab repo create {GROUP}/{PROJECT} --description "{DESCRIPTION}" --public
```

또는 API Helper:

```bash
$CLAUDE_PLUGIN_ROOT/scripts/gitlab-api.sh projects create --name {PROJECT} --namespace {GROUP}
```

**주의**: `glab repo create`는 현재 디렉토리에 빈 repo를 clone한다 → 즉시 삭제:

```bash
rm -rf ./{PROJECT}
```

### Step 3: Git remote 재설정

GitLab을 fetch origin으로, GitLab + GitHub 양쪽을 push origin으로 설정:

```bash
# fetch URL → GitLab
git remote set-url origin ssh://git@{GITLAB_HOST}:{SSH_PORT}/{GROUP}/{PROJECT}.git

# push URL → GitLab (첫 번째)
git remote set-url --add --push origin ssh://git@{GITLAB_HOST}:{SSH_PORT}/{GROUP}/{PROJECT}.git

# push URL → GitHub (두 번째, dual push)
git remote set-url --add --push origin git@github.com:{GROUP}/{PROJECT}.git
```

### Step 4: Initial push

```bash
git push -u origin main
```

- dual push이므로 GitLab + GitHub 양쪽에 push됨

### Step 5: GitLab Push Mirror 설정

GitLab API로 Push Mirror를 설정하여 GitLab → GitHub 자동 동기화:

```bash
GITHUB_TOKEN=$(gh auth token)
glab api --method POST projects/{GROUP}%2F{PROJECT}/remote_mirrors \
  -f "url=https://{GITHUB_USER}:${GITHUB_TOKEN}@github.com/{GROUP}/{PROJECT}.git" \
  -f "enabled=true" \
  -f "only_protected_branches=false"
```

### Step 6: Verify

```bash
# remote 확인
git remote -v

# mirror 상태 확인
glab api projects/{GROUP}%2F{PROJECT}/remote_mirrors
```

기대 결과:

```
origin  ssh://git@{GITLAB_HOST}:{SSH_PORT}/{GROUP}/{PROJECT}.git (fetch)
origin  ssh://git@{GITLAB_HOST}:{SSH_PORT}/{GROUP}/{PROJECT}.git (push)
origin  git@github.com:{GROUP}/{PROJECT}.git (push)
```

## Guard Rails

- **GitLab이 SSOT (Single Source of Truth)** — fetch는 항상 GitLab
- **GitHub에 직접 push 금지** (Push Mirror 사용 시) — mirror와 수동 push 충돌 방지
- `glab repo create`가 현재 디렉토리에 빈 repo를 clone함 → **반드시 삭제** (`rm -rf ./{PROJECT}`)
- `gh auth token`의 OAuth 토큰(`gho_`)은 만료될 수 있음 → **classic PAT(`ghp_`) 권장**
- **Phase 1(dual push)과 Phase 2(mirror) 동시 사용 금지** — 아래 전환 가이드 참조

## Phase 전환 가이드

### Phase 1: Dual Push (초기 안정화)

양쪽에 동시 push. mirror 설정 전 또는 테스트 기간에 사용:

```
origin → GitLab (fetch)
origin → GitLab + GitHub (push, dual)
```

- 장점: 즉시 양쪽 반영, 간단
- 단점: push 실패 시 한쪽만 업데이트될 수 있음

### Phase 2: GitLab Push Mirror (안정화 후)

GitLab이 자동으로 GitHub에 mirror. 수동 dual push 불필요:

```
origin → GitLab (fetch)
origin → GitLab (push, 단일)
GitLab Push Mirror → GitHub (자동)
```

- 장점: 원자적 동기화, GitHub push 실패 무관
- 단점: mirror 주기에 따른 지연 (보통 수 분)

### Phase 1 → Phase 2 전환

Push Mirror 설정 후 GitHub push URL 제거:

```bash
# 현재 dual push 확인
git remote -v

# GitHub push URL 제거 → GitLab만 남김
git remote set-url --delete --push origin git@github.com:{GROUP}/{PROJECT}.git
```

### Phase 2 → Phase 1 복원

Mirror 비활성화 후 dual push 복원:

```bash
# mirror 비활성화
glab api --method PUT projects/{GROUP}%2F{PROJECT}/remote_mirrors/{MIRROR_ID} \
  -f "enabled=false"

# GitHub push URL 재추가
git remote set-url --add --push origin git@github.com:{GROUP}/{PROJECT}.git
```

## Domain Data References

- `docs/guides/hybrid-gitops.md` (in my-devops) — GitLab+GitHub Hybrid GitOps 운영 가이드
