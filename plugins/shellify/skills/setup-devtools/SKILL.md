---
description: Cross-platform DevOps CLI tools installation (kubectl, k9s, helm, argocd, gh, glab, git-lfs). "devops tools", "kubectl install", "k9s install", "helm install", "argocd cli", "github cli", "gitlab cli", "DevOps 도구 설치", "인프라 도구".
allowed-tools: Bash, Read
---

# Setup DevTools

Kubernetes, GitOps, Git 관련 DevOps CLI 도구를 설치합니다.

## Supported Platforms

- **Linux**: Ubuntu/Debian (apt + binary)
- **macOS**: Homebrew

## Tools

| Tool | Purpose |
|------|---------|
| git + git-lfs | Version control |
| kubectl | Kubernetes CLI |
| k9s | Kubernetes TUI dashboard |
| helm | Kubernetes package manager |
| argocd | ArgoCD CLI for GitOps |
| gh | GitHub CLI |
| glab | GitLab CLI |

## Workflow

### 1. 상태 확인

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/detect-platform.sh"
```

### 2. 설치 실행

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-devtools.sh"
```

모든 도구는 멱등성 보장 (이미 설치된 항목은 건너뜀).

## Notes

- Linux: `sudo` 권한 필요 (apt repo 등록 및 바이너리 설치)
- macOS: Homebrew 필요
- kubectl 버전은 v1.31 stable 기준 (필요 시 스크립트에서 변경 가능)
