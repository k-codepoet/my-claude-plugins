---
name: init
description: 인프라 환경 초기화 (IaC 저장소 생성)
allowed-tools: ["Read", "Bash"]
---

인프라 환경을 초기화합니다. IaC 저장소를 생성하고 기본 구조를 설정합니다.

## 실행 단계

1. **플랫폼 확인**
   ```bash
   uname -s
   ```

2. **IaC 저장소 초기화**
   ```bash
   bash "$CLAUDE_PLUGIN_ROOT/skills/k3s/scripts/init-iac.sh"
   ```

3. **생성 결과 확인**
   - `~/my-iac/` 디렉토리 구조 표시
   - Git 초기화 상태 확인

## 생성되는 구조

```
~/my-iac/
├── k3s/
│   ├── manifest/
│   └── helm/
├── {hostname}/       # Docker Compose (Portainer GitOps)
├── terraform/
└── argocd/
```

## 옵션

- `-d, --directory DIR`: 대상 디렉토리 지정 (기본: ~/my-iac)

## 다음 단계 안내

초기화 완료 후 사용자에게 안내:
- k3s 설치: "쿠버네티스 환경 구축해줘"
- portainer 설치: "Portainer 설치해줘"
- Git remote 추가: `git remote add origin <url>`
