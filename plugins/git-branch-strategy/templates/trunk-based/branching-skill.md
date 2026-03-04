---
description: "Trunk-Based 브랜치 관리 정책. 새 브랜치 생성, 머지, 작업 시작 시 자동 참조."
---

# 브랜치 관리 정책

> Trunk-Based Development 전략. 단일 메인 브랜치에 자주 통합한다.

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

**핵심**: 브랜치 수명 **1~2일 이내**. 큰 기능은 작은 단위로 쪼갠다.

### 2. 작업 완료 → main에 머지

```bash
# 최신 main을 rebase
git fetch origin
git rebase origin/main

# push 후 PR 생성 → 코드 리뷰 → main에 머지
git push origin feat/small-change

# 작업 브랜치 정리
git branch -d feat/small-change
```

### 3. 직접 커밋 (소규모 팀)

소규모 팀(1~3명)에서는 main에 직접 커밋 가능:

```bash
git checkout main
git pull origin main
# 작은 수정 → 커밋
git add .
git commit -m "fix: typo in config"
git push origin main
```

### 4. Feature Flag로 미완성 기능 관리

미완성 기능은 Feature Flag 뒤에 숨긴다:

```
if (featureFlags.isEnabled('new-feature')) {
  // 새 기능
} else {
  // 기존 기능
}
```

---

## 브랜치 네이밍 컨벤션

```
feat/간단한-설명         # 새 기능 (1~2일 수명)
fix/간단한-설명          # 버그 수정
release/X.Y              # 릴리스 안정화 (선택)
```

영문 kebab-case 권장. 한글도 허용하되 짧게.

---

## 규칙 요약

1. **장수 브랜치는 main 하나뿐이다** — develop, staging 등 별도 브랜치 없음
2. **작업 브랜치 수명은 1~2일 이내** — 오래된 브랜치는 경고 대상
3. **main은 항상 배포 가능 상태** — 깨진 빌드 즉시 수정
4. **Feature Flag로 기능 릴리스를 제어한다** — 코드 배포와 기능 릴리스 분리
5. **작업 브랜치는 머지 후 삭제한다**
