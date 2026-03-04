---
description: "GitLab Flow 패턴 레퍼런스. 환경 브랜치 기반 브랜치 전략 상세."
---

# GitLab Flow 브랜치 전략

> 환경별 브랜치(main → pre-production → production)로 배포 단계를 관리하는 브랜치 전략. 또는 릴리스 브랜치(X.Y-stable) 방식도 지원.

---

## 언제 사용하는가

- 스테이징/프로덕션 등 **여러 배포 환경**이 있을 때
- Git Flow보다 단순하지만 **환경별 배포 제어**가 필요할 때
- 릴리스 브랜치로 **여러 버전을 동시 유지보수**해야 할 때

---

## 브랜치 구조: 환경 브랜치 모델

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

## 브랜치 구조: 릴리스 브랜치 모델

```
main ← 개발 통합 브랜치
  │
  ├── feat/xxx ← 개별 기능 브랜치
  ├── fix/xxx
  │
  ├──→ X.Y-stable ← 릴리스 브랜치 (main에서 분기)
  └──→ X.Z-stable ← 다른 릴리스 브랜치
```

### 역할 정의

| 브랜치 | 역할 | 직접 커밋 |
|--------|------|----------|
| `main` | 개발 통합 브랜치 | 금지 (머지만) |
| `X.Y-stable` | 릴리스 유지보수 브랜치 | cherry-pick만 |
| `feat/*`, `fix/*`, `chore/*` | 작업 브랜치 | 허용 |

---

## 작업 흐름 (환경 브랜치 모델)

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
# CI/CD가 스테이징 환경에 자동 배포
```

### 4. 프로덕션 배포 (pre-production → production)

```bash
git checkout production
git merge pre-production
git push origin production
# CI/CD가 프로덕션 환경에 자동 배포
```

### 5. 핫픽스

```bash
# main에서 핫픽스 브랜치 생성
git checkout main
git checkout -b fix/critical-bug

# 수정 후 main에 머지
git push origin fix/critical-bug
# MR → main 머지

# main → pre-production → production 순서로 전파
git checkout pre-production
git merge main
git push origin pre-production

git checkout production
git merge pre-production
git push origin production
```

---

## 작업 흐름 (릴리스 브랜치 모델)

### 릴리스 브랜치 생성

```bash
# main에서 릴리스 브랜치 분기
git checkout main
git checkout -b 1.0-stable
git push origin 1.0-stable
```

### 릴리스 브랜치에 버그 수정 반영

```bash
# main에서 먼저 수정 후 cherry-pick
git checkout main
git checkout -b fix/release-bug
# 수정 → 커밋 → main에 머지

# stable 브랜치에 cherry-pick
git checkout 1.0-stable
git cherry-pick <commit-hash>
git push origin 1.0-stable
```

---

## 브랜치 네이밍 컨벤션

```
feat/간단한-설명         # 새 기능
fix/간단한-설명          # 버그 수정
chore/간단한-설명        # 설정, 문서, 리팩토링
pre-production           # 스테이징 환경 브랜치
production               # 프로덕션 환경 브랜치
X.Y-stable               # 릴리스 유지보수 브랜치
```

영문 kebab-case 권장.

---

## 규칙 요약

1. **main, pre-production, production에 직접 커밋하지 않는다** — 항상 머지만
2. **코드 흐름은 단방향이다** — main → pre-production → production (환경 모델)
3. **main에서 먼저 수정하고 downstream으로 전파한다** — 역방향 머지 금지
4. **릴리스 브랜치에는 cherry-pick만 한다** — 직접 기능 개발 금지
5. **작업 브랜치는 머지 후 삭제한다**
