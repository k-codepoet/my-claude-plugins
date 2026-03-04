---
description: "Trunk-Based Development 패턴 레퍼런스. 단일 메인 브랜치 중심 브랜치 전략 상세."
---

# Trunk-Based Development 브랜치 전략

> 단일 메인 브랜치(trunk)에 자주 통합하고, 짧은 수명의 브랜치만 허용하는 브랜치 전략. Feature Flag로 미완성 기능을 관리.

---

## 언제 사용하는가

- **CI/CD 파이프라인이 잘 갖춰진** 환경에서
- **빠른 배포 주기**(하루 여러 번)를 원할 때
- 팀원들이 **작은 단위로 자주 커밋**하는 문화일 때
- **Feature Flag** 인프라가 있거나 도입 가능할 때

---

## 브랜치 구조

```
main (trunk) ← 유일한 장수 브랜치, 항상 배포 가능
  │
  ├── feat/xxx ← 짧은 수명 브랜치 (1~2일 이내)
  ├── fix/xxx  ← 짧은 수명 브랜치
  │
  └── release/X.Y ← (선택) 릴리스 브랜치, 필요 시에만
```

### 역할 정의

| 브랜치 | 역할 | 직접 커밋 |
|--------|------|----------|
| `main` | 유일한 통합 브랜치 (trunk) | 소규모 팀: 허용 / 대규모 팀: 금지 |
| `feat/*`, `fix/*` | 짧은 수명 작업 브랜치 (1~2일) | 허용 |
| `release/X.Y` | 릴리스 안정화 (선택) | cherry-pick만 |

---

## 작업 흐름

### 1. 작업 시작 (짧은 수명 브랜치)

```bash
# main에서 작업 브랜치 생성
git checkout main
git pull origin main
git checkout -b feat/small-change
```

**핵심 원칙**: 브랜치 수명을 **1~2일 이내**로 유지한다. 큰 기능은 작은 단위로 쪼개서 여러 번 머지.

### 2. 작업 완료 → main에 머지

```bash
# 최신 main을 rebase
git fetch origin
git rebase origin/main

# push 후 PR/MR 생성
git push origin feat/small-change
# 코드 리뷰 → main에 머지

# 작업 브랜치 정리
git branch -d feat/small-change
```

### 3. 직접 커밋 (소규모 팀)

소규모 팀(1~3명)에서는 main에 직접 커밋도 가능:

```bash
git checkout main
git pull origin main
# 작은 수정 → 커밋
git add .
git commit -m "fix: typo in config"
git push origin main
```

### 4. Feature Flag로 미완성 기능 관리

큰 기능을 여러 작은 PR로 나누되, 미완성 기능은 Feature Flag 뒤에 숨긴다:

```javascript
// 미완성 기능은 Feature Flag로 제어
if (featureFlags.isEnabled('new-dashboard')) {
  showNewDashboard();
} else {
  showLegacyDashboard();
}
```

### 5. 릴리스 브랜치 (선택)

특정 버전 릴리스가 필요한 경우에만 사용:

```bash
# main에서 릴리스 브랜치 분기
git checkout main
git checkout -b release/1.0
git push origin release/1.0

# 릴리스 브랜치에 버그 수정 cherry-pick
git checkout release/1.0
git cherry-pick <commit-hash>
git push origin release/1.0
```

---

## 브랜치 네이밍 컨벤션

```
feat/간단한-설명         # 새 기능 (1~2일 수명)
fix/간단한-설명          # 버그 수정
release/X.Y              # 릴리스 안정화 (선택)
```

영문 kebab-case 권장.

---

## 핵심 실천 사항

1. **하루에 최소 한 번 main에 통합한다** — 브랜치가 오래 살면 충돌 증가
2. **PR/MR은 작게 유지한다** — 200줄 이하 권장
3. **main은 항상 배포 가능 상태를 유지한다** — CI가 통과해야 머지
4. **미완성 기능은 Feature Flag로 숨긴다** — 코드는 머지하되 기능은 비활성화
5. **코드 리뷰는 빠르게 한다** — PR이 쌓이면 브랜치 수명이 길어짐

---

## 규칙 요약

1. **장수 브랜치는 main 하나뿐이다** — develop, staging 등 별도 브랜치 없음
2. **작업 브랜치 수명은 1~2일 이내** — 오래된 브랜치는 경고 대상
3. **main은 항상 배포 가능 상태** — 깨진 빌드 즉시 수정
4. **Feature Flag로 기능 릴리스를 제어한다** — 코드 배포와 기능 릴리스 분리
5. **작업 브랜치는 머지 후 삭제한다**
