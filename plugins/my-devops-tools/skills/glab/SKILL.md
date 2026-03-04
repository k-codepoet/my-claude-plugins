---
description: glab CLI 설치, GitLab CLI 사용법, MR 생성, 파이프라인 확인, 이슈 관리 관련 작업
allowed-tools: Bash, Read, Write
---

# GitLab CLI (glab) - 설치 및 사용법 가이드

## 설치

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/install-glab.sh
```

## 환경 설정

```bash
# 인증 (최초 1회)
glab auth login

# Self-hosted GitLab 인스턴스 추가
glab auth login --hostname gitlab.mycompany.com

# 인증 상태 확인
glab auth status
```

## 내 커스텀 사용법

### Merge Request (MR)

```bash
# MR 생성 (현재 브랜치 → default branch)
glab mr create --fill

# MR 생성 (타겟 브랜치 지정 + 제목)
glab mr create --target-branch main --title "feat: add feature"

# MR 목록
glab mr list
glab mr list --state=opened

# MR 조회
glab mr view <mr-number>
glab mr view <mr-number> --web  # 브라우저에서 열기

# MR 머지
glab mr merge <mr-number>
glab mr merge <mr-number> --squash

# MR 체크아웃 (리뷰용)
glab mr checkout <mr-number>
```

### CI/CD 파이프라인

```bash
# 현재 브랜치 파이프라인 상태
glab ci status

# 파이프라인 목록
glab ci list

# 파이프라인 조회 (job별 상태)
glab ci view <pipeline-id>

# Job 로그 보기
glab ci trace <job-id>

# 파이프라인 재실행
glab ci retry <pipeline-id>

# 수동 파이프라인 트리거
glab ci run --branch main
```

### 이슈

```bash
# 이슈 생성
glab issue create --title "Bug: something broken" --label bug

# 이슈 목록
glab issue list
glab issue list --label "priority::high"

# 이슈 조회 / 닫기
glab issue view <issue-number>
glab issue close <issue-number>
```

### 레포지토리

```bash
# 클론
glab repo clone group/project

# 레포 정보
glab repo view

# 브라우저에서 열기
glab repo view --web
```

### Registry (Container Registry)

```bash
# 레지스트리 이미지 목록
glab registry list

# Docker login (GitLab registry)
glab auth login --hostname gitlab.mycompany.com
docker login registry.gitlab.mycompany.com
```

## 자주 쓰는 조합

```bash
# 브랜치 생성 → 작업 → MR 생성 (한 흐름)
git checkout -b feat/my-feature
# ... 작업 + 커밋 ...
git push -u origin feat/my-feature
glab mr create --fill --squash-message-on-merge

# 파이프라인 실패 시 빠른 디버깅
glab ci status                    # 실패 job 확인
glab ci trace <failed-job-id>     # 로그 확인

# MR 리뷰 + 머지 흐름
glab mr list --reviewer=@me       # 내가 리뷰어인 MR
glab mr checkout <mr-number>      # 로컬 체크아웃
glab mr merge <mr-number> --squash
```

## 설정 팁

```bash
# 기본 에디터 변경
glab config set editor vim

# 기본 remote 변경 (fork 환경)
glab config set remote_alias upstream

# 현재 설정 확인
glab config list
```
