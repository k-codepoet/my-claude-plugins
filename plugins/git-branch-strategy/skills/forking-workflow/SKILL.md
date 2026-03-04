---
description: "Forking Workflow 패턴 레퍼런스. 포크 기반 오픈소스 기여 브랜치 전략 상세."
---

# Forking Workflow 브랜치 전략

> 각 개발자가 중앙 저장소를 fork하여 자신의 원격 저장소에서 작업하고, Pull Request로 기여하는 브랜치 전략. 오픈소스 기여의 표준 방식.

---

## 언제 사용하는가

- 오픈소스 프로젝트에 기여할 때
- 중앙 저장소에 직접 쓰기 권한이 없을 때
- 다수의 외부 기여자를 받아야 하는 프로젝트를 운영할 때
- 코드 리뷰를 PR 기반으로 강제하고 싶을 때

---

## 저장소 구조

```
upstream (중앙 저장소, 원본)
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

## 초기 설정

```bash
# 1. 중앙 저장소를 fork (GitHub/GitLab UI에서)

# 2. fork를 클론
git clone git@github.com:MY-USERNAME/project.git
cd project

# 3. upstream 리모트 추가
git remote add upstream git@github.com:ORIGINAL-OWNER/project.git
git remote -v
# origin    → 내 fork
# upstream  → 중앙 저장소
```

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

### 2. 작업 브랜치 생성

```bash
# main에서 작업 브랜치 생성
git checkout main
git checkout -b feat/my-contribution
```

### 3. 작업 및 커밋

```bash
# 작업 후 커밋
git add .
git commit -m "feat: add my contribution"

# 작업 중 upstream 변경이 있으면 rebase
git fetch upstream
git rebase upstream/main
```

### 4. Push 및 Pull Request

```bash
# 개인 fork에 push
git push origin feat/my-contribution

# GitHub/GitLab에서 Pull Request 생성
# base: upstream/main ← head: origin/feat/my-contribution
```

### 5. PR 리뷰 대응

```bash
# 리뷰어 피드백 반영 후 추가 커밋
git add .
git commit -m "fix: address review feedback"
git push origin feat/my-contribution

# 또는 기존 커밋에 fixup (선택)
git commit --fixup HEAD~1
git rebase -i upstream/main --autosquash
git push origin feat/my-contribution --force-with-lease
```

### 6. 머지 후 정리

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

영문 kebab-case 권장.

---

## 규칙 요약

1. **origin/main에 직접 커밋하지 않는다** — upstream 동기화 전용
2. **작업 브랜치는 main에서 파생한다** — 항상 최신 main 기준
3. **모든 기여는 Pull Request로 한다** — 직접 push 금지
4. **push 전 upstream/main으로 rebase 권장** — 충돌 미리 해결
5. **작업 브랜치는 머지 후 삭제한다** — fork과 로컬 모두
