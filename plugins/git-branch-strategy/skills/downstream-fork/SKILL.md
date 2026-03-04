---
description: "Downstream Fork 패턴 레퍼런스. 오픈소스 fork 브랜치 전략 상세."
---

# Downstream Fork 브랜치 전략

> 오픈소스 프로젝트를 fork하여 자체 커스텀을 유지하면서 upstream 변경을 지속 수신하는 브랜치 전략.

---

## 브랜치 구조

```
upstream/main (원본 프로젝트)
  │
  ├── main ← upstream 동기화 + 통합 브랜치 머지 (배포 대상)
  │     │
  │     └── {{INTEGRATION_BRANCH}} ← fork 커스텀 작업의 통합 브랜치
  │           │
  │           ├── feat/xxx ← 개별 기능 브랜치
  │           ├── fix/xxx
  │           └── chore/xxx
```

`{{INTEGRATION_BRANCH}}`는 프로젝트별로 이름을 정한다 (예: `develop`, `my-work`, `custom` 등).

### 역할 정의

| 브랜치 | 역할 | 직접 커밋 |
|--------|------|----------|
| `main` | 배포 브랜치. upstream + fork 통합 | 금지 (머지만) |
| `{{INTEGRATION_BRANCH}}` | fork 커스텀 통합 브랜치 | 금지 (머지만) |
| `feat/*`, `fix/*`, `chore/*` | 작업 브랜치 | 허용 |

---

## 작업 흐름

### 1. 새 기능/수정 작업 시작

```bash
# 통합 브랜치에서 작업 브랜치 생성
git checkout {{INTEGRATION_BRANCH}}
git pull origin {{INTEGRATION_BRANCH}}
git checkout -b feat/my-feature
```

### 2. 작업 완료 → 통합 브랜치에 머지

```bash
# 작업 브랜치에서 커밋 완료 후
git checkout {{INTEGRATION_BRANCH}}
git merge feat/my-feature
# 또는 squash merge로 깨끗하게:
# git merge --squash feat/my-feature && git commit

# push
git push origin {{INTEGRATION_BRANCH}}

# 작업 브랜치 정리
git branch -d feat/my-feature
```

### 3. 통합 브랜치 → main 머지 (릴리스)

```bash
git checkout main
git merge {{INTEGRATION_BRANCH}}
git push origin main
```

### 4. upstream 동기화

upstream 변경사항은 main으로 먼저 받고, 통합 브랜치에 반영한다:

```bash
# upstream → main
git checkout main
git fetch upstream
git merge upstream/main
# 충돌 해결 후
git push origin main

# main → 통합 브랜치 동기화
git checkout {{INTEGRATION_BRANCH}}
git merge main
git push origin {{INTEGRATION_BRANCH}}
```

---

## 브랜치 네이밍 컨벤션

```
feat/간단한-설명     # 새 기능
fix/간단한-설명      # 버그 수정
chore/간단한-설명    # 설정, 문서, 리팩토링
```

영문 kebab-case 권장.

---

## 규칙 요약

1. **main, 통합 브랜치에 직접 커밋하지 않는다** — 항상 작업 브랜치에서 머지
2. **작업 브랜치는 통합 브랜치에서 파생한다** — main에서 파생하지 않음
3. **통합 브랜치 → main 머지는 릴리스 시점에 한다**
4. **upstream 동기화는 main → 통합 브랜치 순서로 흘러간다**
5. **작업 브랜치는 머지 후 삭제한다**
