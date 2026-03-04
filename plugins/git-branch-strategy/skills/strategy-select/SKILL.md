---
description: "Git 브랜치 전략 추천 및 선택. '브랜치 전략', 'branch strategy', 'git strategy' 요청 시 활성화."
---

# Git 브랜치 전략 선택

> 프로젝트 상황에 맞는 브랜치 전략을 추천하고 설정을 안내한다.

---

## 진단 질문

사용자에게 다음을 순서대로 확인한다. 먼저 해당하는 항목이 있으면 바로 추천한다.

### 1. 오픈소스 fork인가?

- upstream 레포를 fork해서 커스텀 변경을 유지하는 구조인가?
- upstream의 업데이트를 지속적으로 받아야 하는가?

→ **Yes**: **Downstream Fork** 추천

### 2. 서드파티 코드를 단일 레포에 임베드하는가?

- 외부 라이브러리/프레임워크 소스를 직접 레포에 포함하는가?
- vendor 디렉토리로 서드파티 코드를 관리하는가?

→ **Yes**: **Vendor Branch** 추천

### 3. 오픈소스에 기여하는 구조인가?

- 원본 레포의 쓰기 권한 없이 fork해서 PR을 보내는 방식인가?

→ **Yes**: **Forking Workflow** 추천

### 4. 여러 버전을 동시에 유지보수해야 하는가?

- 라이브러리/프레임워크처럼 v1.x, v2.x를 동시에 지원하는가?
- 릴리스 후 장기간 패치를 제공하는가?

→ **Yes**: **Release Branch** 추천

### 5. 릴리스 주기가 길고 여러 기능을 동시에 개발하는가?

- 명확한 릴리스 일정이 있는가? (2주 이상 주기)
- develop 브랜치에서 기능을 모아 릴리스하는 방식이 필요한가?

→ **Yes**: **Git Flow** 추천

### 6. 여러 배포 환경(staging, production)이 있는가?

- main 외에 staging, production 등 환경별 브랜치가 필요한가?
- 또는 릴리스 브랜치(X.Y-stable)로 안정 버전을 관리하는가?

→ **Yes**: **GitLab Flow** 추천

### 7. 빠른 배포 주기로 main에 자주 머지하는가?

- CI/CD가 잘 갖춰져 있고 하루에도 여러 번 배포하는가?
- feature flag로 미완성 기능을 숨기는가?

→ **Yes**: **Trunk-Based Development** 추천

### 8. 단순한 PR 기반 워크플로우가 필요한가?

- main + feature branch → PR → merge → 배포?
- 별도의 develop/staging 브랜치 없이 단순하게 운영하고 싶은가?

→ **Yes**: **GitHub Flow** 추천

### 9. 둘 이상 해당하는가?

- 전략은 병행할 수 있다. 예: Downstream Fork + Vendor Branch, GitHub Flow + Release Branch 등
- 프로젝트의 주요 워크플로우에 맞는 전략을 기본으로 선택하고, 필요 시 보조 전략을 추가한다.

---

## 전략 요약

| 전략 | 핵심 | 브랜치 구조 | 적합한 경우 |
|------|------|------------|------------|
| **Git Flow** | 릴리스 주기 관리 | main, develop, feature/*, release/*, hotfix/* | 긴 릴리스 주기, 동시 개발 |
| **GitHub Flow** | 단순 PR 기반 | main + feature branches | CI/CD 배포, 단순한 워크플로우 |
| **GitLab Flow** | 환경별 배포 | main → staging → production | 다중 배포 환경 |
| **Trunk-Based** | 빠른 통합 | main + 짧은 수명 브랜치 | 빈번한 배포, feature flag |
| **Release Branch** | 다중 버전 유지 | main → release/x.y | 라이브러리, 장기 지원 |
| **Forking Workflow** | fork + PR | 개인 fork → upstream PR | 오픈소스 기여 |
| **Downstream Fork** | fork 커스텀 유지 | upstream/main → main → 통합 브랜치 | fork 프로젝트 |
| **Vendor Branch** | 서드파티 임베드 | vendor/{lib} (orphan) → main | 서드파티 소스 관리 |

각 전략의 상세는 해당 스킬을 참조한다:
- `git-flow`, `github-flow`, `gitlab-flow`, `trunk-based`
- `release-branch`, `forking-workflow`
- `downstream-fork`, `vendor-branch`

---

## 선택 후 다음 단계

패턴을 선택한 후 `setup` 스킬을 실행하여 프로젝트에 자동 적용한다:

1. **`setup` 스킬 실행** — pre-commit hook, CLAUDE.md 정책, branching 스킬, 설정 파일을 자동 생성
2. 생성된 파일을 커밋한다
3. 팀원에게 `git config core.hooksPath .githooks` 실행을 안내한다

수동으로 진행하려면 해당 전략 스킬의 상세 문서를 참조한다.
