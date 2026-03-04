# git-branch-strategy

Git 브랜치 전략을 선택하고 강제하는 Claude Code 플러그인.

## 지원 패턴

1. **Downstream Fork** — `main ← integration ← feat/*` 구조. upstream fork 프로젝트에 적합.
2. **Vendor Branch** — `main ← vendor ← feat/*` 구조. 외부 라이브러리를 vendor 브랜치로 관리.

## 사용법

1. 프로젝트 루트에 `.git-branch-strategy.json` 설정 파일 생성
2. 플러그인이 자동으로 보호 브랜치 직접 커밋을 감지하여 경고

## 설정 예시

```json
{
  "strategy": "downstream-fork",
  "protected_branches": ["main", "my-work"],
  "integration_branch": "my-work",
  "branch_prefixes": ["feat/", "fix/", "chore/"]
}
```

## 훅

- **PreToolUse (Bash)** — `git commit` 명령 실행 시 보호 브랜치 여부를 확인하고 경고
