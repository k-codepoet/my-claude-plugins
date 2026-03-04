---
description: "GitHub Flow 브랜치 관리 정책. 새 브랜치 생성, 머지, 작업 시작 시 자동 참조."
---

# 브랜치 관리 정책

> GitHub Flow 전략. PR 리뷰 기반의 단순한 브랜치 정책.

---

## 브랜치 구조

```
main ← 항상 배포 가능한 상태 유지
  │
  ├── feature/xxx ← 기능 개발
  ├── fix/xxx     ← 버그 수정
  └── chore/xxx   ← 설정, 문서, 리팩토링
```

### 역할 정의

| 브랜치 | 역할 | 직접 커밋 |
|--------|------|----------|
| `main` | 배포 브랜치. 항상 배포 가능한 상태 | 금지 (PR 머지만) |
| `feature/*`, `fix/*`, `chore/*` | 작업 브랜치 | 허용 |

---

## 작업 흐름

### 1. 새 작업 시작

```bash
# main에서 작업 브랜치 생성
git checkout main
git pull origin main
git checkout -b feature/my-feature
```

### 2. 작업 중 커밋 & 푸시

```bash
# 작업 중 수시로 커밋 & 원격에 푸시
git add .
git commit -m "feat: add new feature"
git push origin feature/my-feature
```

### 3. Pull Request 생성 & 리뷰

```bash
# PR 생성
gh pr create --title "feat: add new feature" --body "설명"

# 리뷰 완료 후 머지
gh pr merge --squash
```

### 4. 로컬 정리

```bash
git checkout main
git pull origin main
git branch -d feature/my-feature
```

---

## 브랜치 네이밍 컨벤션

```
feature/간단한-설명     # 새 기능
fix/간단한-설명         # 버그 수정
chore/간단한-설명       # 설정, 문서, 리팩토링
```

영문 kebab-case 권장.

---

## 규칙 요약

1. **main에 직접 커밋하지 않는다** — 항상 PR을 통해 머지
2. **작업 브랜치는 main에서 파생한다**
3. **PR은 반드시 리뷰를 받는다** — 최소 1명 이상 승인
4. **CI가 통과해야 머지할 수 있다**
5. **main은 항상 배포 가능한 상태를 유지한다**
6. **작업 브랜치는 머지 후 삭제한다**
