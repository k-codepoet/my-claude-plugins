---
name: help
description: git-branch-strategy 플러그인 도움말
---

# git-branch-strategy 플러그인

Git 브랜치 전략을 선택하고 보호 브랜치 직접 커밋을 방지하는 플러그인입니다.

## 스킬

| 스킬 | 설명 |
|------|------|
| `branching-guide` | 브랜치 전략 가이드 (Downstream Fork, Vendor Branch) |

## 훅

- **PreToolUse (Bash)** — `git commit` 감지 시 보호 브랜치 경고

## 설정

프로젝트 루트에 `.git-branch-strategy.json`을 생성하세요:

```json
{
  "strategy": "downstream-fork",
  "protected_branches": ["main", "my-work"],
  "integration_branch": "my-work",
  "branch_prefixes": ["feat/", "fix/", "chore/"]
}
```

### 필드 설명

- `strategy` — 브랜치 전략 이름 (`downstream-fork` | `vendor-branch`)
- `protected_branches` — 직접 커밋이 금지된 브랜치 목록
- `integration_branch` — 통합 브랜치 (feat 브랜치의 머지 대상)
- `branch_prefixes` — 허용되는 작업 브랜치 접두사
