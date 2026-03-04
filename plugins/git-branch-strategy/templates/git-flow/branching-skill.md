---
description: "Git Flow 브랜치 관리 정책. 새 브랜치 생성, 머지, 작업 시작 시 자동 참조."
---

# 브랜치 관리 정책

> Git Flow 전략. 릴리스 주기가 있는 프로젝트의 브랜치 정책.

---

## 브랜치 구조

```
main ← 프로덕션 배포 (태그로 버전 관리)
  │
  ├── hotfix/xxx ← 긴급 프로덕션 버그 수정
  │
  └── develop ← 개발 통합 브랜치
        │
        ├── feature/xxx ← 개별 기능 개발
        │
        └── release/x.y.z ← 릴리스 준비
```

### 역할 정의

| 브랜치 | 역할 | 직접 커밋 |
|--------|------|----------|
| `main` | 프로덕션 배포. 태그로 버전 관리 | 금지 (머지만) |
| `develop` | 개발 통합 브랜치 | 금지 (머지만) |
| `feature/*` | 개별 기능 개발 | 허용 |
| `release/*` | 릴리스 준비 | 허용 (릴리스 관련만) |
| `hotfix/*` | 긴급 프로덕션 버그 수정 | 허용 |

---

## 작업 흐름

### 1. 새 기능 개발

```bash
# develop에서 feature 브랜치 생성
git checkout develop
git pull origin develop
git checkout -b feature/my-feature
```

### 2. 작업 완료 → develop에 머지

```bash
# 작업 브랜치에서 커밋 완료 후
git checkout develop
git merge feature/my-feature
# 또는 squash merge로 깨끗하게:
# git merge --squash feature/my-feature && git commit

# push
git push origin develop

# 작업 브랜치 정리
git branch -d feature/my-feature
```

### 3. 릴리스 준비

```bash
# develop에서 release 브랜치 생성
git checkout develop
git checkout -b release/1.2.0

# 버전 범프, 최종 QA, 버그 수정 후
# main과 develop 양쪽에 머지
git checkout main
git merge release/1.2.0
git tag -a v1.2.0 -m "Release v1.2.0"

git checkout develop
git merge release/1.2.0

git push origin main develop --tags
git branch -d release/1.2.0
```

### 4. 긴급 수정 (Hotfix)

```bash
# main에서 hotfix 브랜치 생성
git checkout main
git checkout -b hotfix/critical-bug

# 수정 후 main과 develop 양쪽에 머지
git checkout main
git merge hotfix/critical-bug
git tag -a v1.2.1 -m "Hotfix v1.2.1"

git checkout develop
git merge hotfix/critical-bug

git push origin main develop --tags
git branch -d hotfix/critical-bug
```

---

## 브랜치 네이밍 컨벤션

```
feature/간단한-설명     # 새 기능
release/1.2.0          # 릴리스 준비 (시맨틱 버전)
hotfix/간단한-설명      # 긴급 수정
```

영문 kebab-case 권장. release 브랜치는 버전 번호 사용.

---

## 규칙 요약

1. **main, develop에 직접 커밋하지 않는다** — 항상 작업 브랜치에서 머지
2. **feature 브랜치는 develop에서 파생, develop으로 머지한다**
3. **release 브랜치는 develop에서 파생, main과 develop 양쪽에 머지한다**
4. **hotfix 브랜치는 main에서 파생, main과 develop 양쪽에 머지한다**
5. **main에 머지할 때마다 태그를 생성한다**
6. **작업 브랜치는 머지 후 삭제한다**
