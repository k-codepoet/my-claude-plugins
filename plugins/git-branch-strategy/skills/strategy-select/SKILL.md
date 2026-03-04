---
description: "Git 브랜치 전략 추천 및 선택. '브랜치 전략', 'branch strategy', 'git strategy' 요청 시 활성화."
---

# Git 브랜치 전략 선택

> 프로젝트 상황에 맞는 브랜치 전략을 추천하고 설정을 안내한다.

---

## 진단 질문

사용자에게 다음을 확인한다:

### 1. 오픈소스 fork인가?

- upstream 레포를 fork해서 커스텀 변경을 유지하는 구조인가?
- upstream의 업데이트를 지속적으로 받아야 하는가?

→ **Yes**: [Downstream Fork 패턴](#downstream-fork-패턴) 추천

### 2. 서드파티 코드를 단일 레포에 임베드하는가?

- 외부 라이브러리/프레임워크 소스를 직접 레포에 포함하는가?
- vendor 디렉토리로 서드파티 코드를 관리하는가?

→ **Yes**: [Vendor Branch 패턴](#vendor-branch-패턴) 추천

### 3. 둘 다 해당하는가?

- fork이면서 추가로 서드파티 코드도 임베드하는 경우

→ **두 패턴 병행 가능**. Downstream Fork로 전체 fork 구조를 잡고, 개별 vendor 코드는 Vendor Branch로 관리한다.

---

## 패턴 요약

### Downstream Fork 패턴

오픈소스 프로젝트를 fork해서 자체 커스텀을 유지하면서 upstream 변경을 지속 수신하는 구조.

- **브랜치 구조**: `upstream/main → main → 통합 브랜치 → feat/*`
- **핵심**: upstream 동기화와 자체 변경의 분리
- **상세**: `downstream-fork` 스킬 참조

### Vendor Branch 패턴

서드파티 소스 코드를 orphan 브랜치로 관리하고 subtree merge로 메인에 통합하는 구조.

- **브랜치 구조**: `vendor/{lib} (orphan) → main → feat/*`
- **핵심**: 서드파티 원본과 자체 수정의 이력 분리
- **상세**: `vendor-branch` 스킬 참조

---

## 선택 후 다음 단계

패턴을 선택한 후 `setup` 스킬을 실행하여 프로젝트에 자동 적용한다:

1. **`setup` 스킬 실행** — pre-commit hook, CLAUDE.md 정책, branching 스킬, 설정 파일을 자동 생성
2. 생성된 파일을 커밋한다
3. 팀원에게 `git config core.hooksPath .githooks` 실행을 안내한다

수동으로 진행하려면 해당 패턴 스킬(downstream-fork 또는 vendor-branch)의 상세 문서를 참조한다.
