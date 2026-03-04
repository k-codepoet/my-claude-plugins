---
description: "Forking Workflow 브랜치 관리 정책. 새 브랜치 생성, 머지, 작업 시작 시 자동 참조."
---

# 브랜치 관리 정책

> Forking Workflow 전략. 개인 fork에서 작업하고 PR로 기여한다.

---

## 저장소 구조

```
upstream (중앙 저장소)
  └── main ← 배포/통합 브랜치

origin (개인 fork)
  └── main ← upstream/main 동기화
        │
        ├── feat/xxx ← 개별 기능 브랜치
        ├── fix/xxx
        └── chore/xxx
```

### 역할 정의

| 저장소/브랜치 | 역할 | 직접 커밋 |
|--------------|------|----------|
| `upstream/main` | 중앙 저장소 메인 브랜치 | 메인테이너만 (머지) |
| `origin/main` | 개인 fork의 메인 브랜치 | 금지 (동기화만) |
| `feat/*`, `fix/*`, `chore/*` | 작업 브랜치 (origin) | 허용 |

---

## 작업 흐름

### 1. upstream 동기화

```bash
# 작업 시작 전 항상 최신 상태로 동기화
git checkout main
git fetch upstream
git merge upstream/main
git push origin main
```

### 2. 작업 브랜치 생성 및 작업

```bash
# main에서 작업 브랜치 생성
git checkout main
git checkout -b feat/my-contribution

# 작업 후 커밋
git add .
git commit -m "feat: add my contribution"
```

### 3. Push 및 Pull Request

```bash
# 개인 fork에 push
git push origin feat/my-contribution

# GitHub/GitLab에서 Pull Request 생성
# base: upstream/main ← head: origin/feat/my-contribution
```

### 4. 머지 후 정리

```bash
# PR이 머지된 후
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# 작업 브랜치 삭제
git branch -d feat/my-contribution
git push origin --delete feat/my-contribution
```

---

## 브랜치 네이밍 컨벤션

```
feat/간단한-설명     # 새 기능
fix/간단한-설명      # 버그 수정
chore/간단한-설명    # 설정, 문서, 리팩토링
docs/간단한-설명     # 문서 수정
```

영문 kebab-case 권장. 한글도 허용하되 짧게.

---

## 규칙 요약

1. **origin/main에 직접 커밋하지 않는다** — upstream 동기화 전용
2. **작업 브랜치는 main에서 파생한다** — 항상 최신 main 기준
3. **모든 기여는 Pull Request로 한다** — 직접 push 금지
4. **push 전 upstream/main으로 rebase 권장** — 충돌 미리 해결
5. **작업 브랜치는 머지 후 삭제한다**
