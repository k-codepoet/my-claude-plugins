---
description: "Vendor Branch 브랜치 관리 정책. 새 브랜치 생성, 머지, 작업 시작 시 자동 참조."
---

# 브랜치 관리 정책

> Vendor Branch 전략. 외부 라이브러리를 vendor 브랜치로 관리한다.

---

## 브랜치 구조

```
vendor/lib-a  (외부 라이브러리 A 원본)
vendor/lib-b  (외부 라이브러리 B 원본)
  │
  ├──(subtree merge)──→ main ← 배포 브랜치
  │                       │
  │                       ├── feat/xxx ← 개별 기능 브랜치
  │                       ├── fix/xxx
  │                       └── chore/xxx
```

### 역할 정의

| 브랜치 | 역할 | 직접 커밋 |
|--------|------|----------|
| `main` | 배포 브랜치. vendor + 커스텀 통합 | 금지 (머지만) |
| `vendor/*` | 외부 라이브러리 원본 브랜치 | vendor 코드 교체 시만 허용 |
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

### 3. vendor 업데이트

vendor 라이브러리의 새 버전을 반영할 때:

```bash
# vendor 브랜치에서 코드 교체
git checkout vendor/lib-name
# (새 버전 코드로 교체)
git add -A
git commit -m "vendor(lib-name): update to v{버전}"

# main에 subtree 머지
git checkout main
git merge vendor/lib-name
# 충돌 해결 (vendor-update 스킬 참고)
git push origin main
```

### 4. 새 vendor 라이브러리 추가

```bash
# orphan 브랜치 생성
git checkout --orphan vendor/new-lib
git rm -rf .

# vendor 코드 추가
cp -r /path/to/library/* .
git add -A
git commit -m "vendor(new-lib): initial import v{버전}"

# main에 subtree 머지
git checkout main
git merge vendor/new-lib --allow-unrelated-histories -s subtree
git push origin main vendor/new-lib
```

---

## 브랜치 네이밍 컨벤션

```
feat/간단한-설명        # 새 기능
fix/간단한-설명         # 버그 수정
chore/간단한-설명       # 설정, 문서, 리팩토링
vendor/라이브러리명     # 외부 라이브러리 원본
```

영문 kebab-case 권장. 한글도 허용하되 짧게.

---

## 규칙 요약

1. **main에 직접 커밋하지 않는다** — 항상 작업 브랜치 또는 vendor 브랜치에서 머지
2. **vendor 브랜치에는 원본 코드만** — 커스텀 수정은 main에서 수행
3. **vendor 업데이트는 vendor/* → main 순서로 머지**
4. **작업 브랜치는 main에서 파생한다**
5. **작업 브랜치는 머지 후 삭제한다**
