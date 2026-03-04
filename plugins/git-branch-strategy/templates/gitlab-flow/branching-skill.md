---
description: "GitLab Flow 브랜치 관리 정책. 새 브랜치 생성, 머지, 작업 시작 시 자동 참조."
---

# 브랜치 관리 정책

> GitLab Flow 전략. 환경별 브랜치로 배포 단계를 관리한다.

---

## 브랜치 구조

```
main ← 개발 통합 브랜치
  │
  ├── feat/xxx ← 개별 기능 브랜치
  ├── fix/xxx
  │
  ├──→ pre-production ← main에서 머지 (스테이징 배포)
  │         │
  │         └──→ production ← pre-production에서 머지 (프로덕션 배포)
```

### 역할 정의

| 브랜치 | 역할 | 직접 커밋 |
|--------|------|----------|
| `main` | 개발 통합 브랜치 | 금지 (머지만) |
| `pre-production` | 스테이징 환경 배포 | 금지 (main에서 머지만) |
| `production` | 프로덕션 환경 배포 | 금지 (pre-production에서 머지만) |
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
# MR(Merge Request)을 통해 main에 머지
git push origin feat/my-feature
# GitLab에서 MR 생성 → 코드 리뷰 → main에 머지

# 작업 브랜치 정리
git branch -d feat/my-feature
```

### 3. 스테이징 배포 (main → pre-production)

```bash
git checkout pre-production
git merge main
git push origin pre-production
```

### 4. 프로덕션 배포 (pre-production → production)

```bash
git checkout production
git merge pre-production
git push origin production
```

### 5. 핫픽스

```bash
# main에서 먼저 수정 후 downstream 전파
git checkout main
git checkout -b fix/critical-bug
# 수정 → main 머지 → pre-production → production 순서로 전파
```

---

## 브랜치 네이밍 컨벤션

```
feat/간단한-설명         # 새 기능
fix/간단한-설명          # 버그 수정
chore/간단한-설명        # 설정, 문서, 리팩토링
```

영문 kebab-case 권장. 한글도 허용하되 짧게.

---

## 규칙 요약

1. **main, pre-production, production에 직접 커밋하지 않는다** — 항상 작업 브랜치에서 머지
2. **코드 흐름은 단방향이다** — main → pre-production → production
3. **main에서 먼저 수정하고 downstream으로 전파한다** — 역방향 머지 금지
4. **작업 브랜치는 main에서 파생한다**
5. **작업 브랜치는 머지 후 삭제한다**
