---
description: "GitHub Flow 패턴 레퍼런스. PR 기반 단순 브랜치 전략 상세."
---

# GitHub Flow 브랜치 전략

> main 브랜치 하나와 feature 브랜치만으로 운용하는 가장 단순한 브랜치 전략. PR(Pull Request) 리뷰를 통해 품질을 관리한다.

---

## 언제 사용하는가

- 지속적 배포(CD)를 사용하는 웹 서비스
- 소규모 팀 또는 빠른 반복 개발이 필요한 프로젝트
- 명시적 릴리스 주기가 필요 없는 경우
- SaaS, 웹앱 등 항상 최신 버전이 배포되는 서비스

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

### 3. Pull Request 생성

```bash
# PR 생성 (GitHub CLI 사용)
gh pr create --title "feat: add new feature" --body "설명"

# 또는 GitHub 웹에서 PR 생성
```

- PR 설명에 변경 사항과 테스트 결과를 기술
- 리뷰어를 지정하여 코드 리뷰 요청
- CI가 통과하는지 확인

### 4. 리뷰 & 머지

```bash
# 리뷰 완료 후 머지 (GitHub 웹 또는 CLI)
gh pr merge --squash

# 로컬 정리
git checkout main
git pull origin main
git branch -d feature/my-feature
```

### 5. 배포

main에 머지되면 자동 배포 (CD 파이프라인).
수동 배포인 경우 main에서 배포 실행.

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
