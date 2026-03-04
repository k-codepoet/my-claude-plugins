---
description: "Release Branch 브랜치 관리 정책. 새 브랜치 생성, 머지, 작업 시작 시 자동 참조."
---

# 브랜치 관리 정책

> Release Branch 전략. 릴리스 안정화 브랜치로 여러 버전을 동시에 유지보수한다.

---

## 브랜치 구조

```
main (개발 브랜치, 최신 코드)
  │
  ├── release/1.0 ← v1.0.x 안정화 및 유지보수
  │     └── v1.0.0, v1.0.1 (태그)
  │
  ├── release/2.0 ← v2.0.x 안정화 및 유지보수
  │     └── v2.0.0 (태그)
  │
  ├── feat/xxx ← 개별 기능 브랜치
  ├── fix/xxx
  └── chore/xxx
```

### 역할 정의

| 브랜치 | 역할 | 직접 커밋 |
|--------|------|----------|
| `main` | 개발 통합 브랜치. 최신 코드 | 금지 (머지만) |
| `release/x.y` | 릴리스 안정화 및 유지보수 | 금지 (머지만) |
| `feat/*`, `fix/*`, `chore/*` | 작업 브랜치 | 허용 |

---

## 작업 흐름

### 1. 새 기능/수정 작업 시작

```bash
# main에서 작업 브랜치 생성
git checkout main
git pull origin main
git checkout -b feat/my-feature
```

### 2. 작업 완료 → main에 머지

```bash
# 작업 브랜치에서 커밋 완료 후
git checkout main
git merge feat/my-feature
# 또는 squash merge로 깨끗하게:
# git merge --squash feat/my-feature && git commit

# push
git push origin main

# 작업 브랜치 정리
git branch -d feat/my-feature
```

### 3. 릴리스 브랜치 생성

```bash
# main에서 릴리스 브랜치 분기
git checkout main
git checkout -b release/1.0

# 안정화 작업 (버그 수정만)
git checkout -b fix/release-1.0-bug
# ... 수정 후
git checkout release/1.0
git merge fix/release-1.0-bug

# 릴리스 확정
git tag v1.0.0
git push origin release/1.0 --tags
```

### 4. 릴리스 수정 → main 역머지

```bash
git checkout main
git merge release/1.0
git push origin main
```

### 5. 핫픽스

```bash
# 릴리스 브랜치에서 수정
git checkout release/1.0
git checkout -b fix/hotfix-description
# ... 수정 후
git checkout release/1.0
git merge fix/hotfix-description

# 패치 태그
git tag v1.0.1
git push origin release/1.0 --tags

# main에도 역머지
git checkout main
git merge release/1.0
git push origin main
```

---

## 브랜치 네이밍 컨벤션

```
feat/간단한-설명        # 새 기능
fix/간단한-설명         # 버그 수정
chore/간단한-설명       # 설정, 문서, 리팩토링
release/x.y            # 릴리스 안정화 브랜치
```

영문 kebab-case 권장. 한글도 허용하되 짧게.

---

## 규칙 요약

1. **main, release/* 에 직접 커밋하지 않는다** — 항상 작업 브랜치에서 머지
2. **릴리스 브랜치에서는 버그 수정만** — 새 기능은 main에서만
3. **릴리스 수정사항은 main에 역머지한다** — 수정 누락 방지
4. **태그로 버전을 확정한다** — vx.y.z 형식
5. **작업 브랜치는 머지 후 삭제한다**
