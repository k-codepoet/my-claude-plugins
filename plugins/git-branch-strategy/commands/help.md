---
name: help
description: git-branch-strategy 플러그인 도움말
---

# git-branch-strategy 플러그인

Git 브랜치 전략을 선택하고 보호 브랜치 직접 커밋을 방지하는 플러그인입니다.

## 스킬

### 핵심

| 스킬 | 설명 |
|------|------|
| `strategy-select` | 프로젝트 진단 후 브랜치 전략 추천 |
| `setup` | 선택된 전략 스캐폴딩 자동 생성 |

### 범용 전략

| 스킬 | 설명 |
|------|------|
| `git-flow` | Git Flow 패턴 (main/develop/feature/release/hotfix) |
| `github-flow` | GitHub Flow 패턴 (main + feature → PR → merge) |
| `gitlab-flow` | GitLab Flow 패턴 (환경별 브랜치 또는 릴리스 브랜치) |
| `trunk-based` | Trunk-Based Development (main + 짧은 수명 브랜치 + feature flag) |
| `release-branch` | Release Branch 패턴 (main → release/x.y, 다중 버전 유지) |
| `forking-workflow` | Forking Workflow (개인 fork → upstream PR) |

### 특수 전략

| 스킬 | 설명 |
|------|------|
| `downstream-fork` | Downstream Fork 패턴 (upstream fork 커스텀 유지) |
| `upstream-sync` | upstream 동기화 절차 (Downstream Fork 전용) |
| `vendor-branch` | Vendor Branch 패턴 (서드파티 소스 orphan 브랜치 관리) |
| `vendor-update` | vendor 브랜치 업데이트 절차 (Vendor Branch 전용) |

## 훅

- **PreToolUse (Bash)** — `git commit` 감지 시 보호 브랜치 경고

## 설정

프로젝트 루트에 `.git-branch-strategy.json`을 생성하세요:

```json
{
  "strategy": "github-flow",
  "protected_branches": ["main"],
  "branch_prefixes": ["feat/", "fix/", "chore/"]
}
```

### 필드 설명

- `strategy` — 브랜치 전략 이름
- `protected_branches` — 직접 커밋이 금지된 브랜치 목록
- `integration_branch` — 통합 브랜치 (downstream-fork, git-flow에서 사용)
- `branch_prefixes` — 허용되는 작업 브랜치 접두사
