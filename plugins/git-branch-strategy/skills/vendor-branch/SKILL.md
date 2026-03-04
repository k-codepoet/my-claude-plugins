---
description: "Vendor Branch 패턴 레퍼런스. 서드파티 코드 관리 브랜치 전략 상세."
---

# Vendor Branch 브랜치 전략

> 서드파티 소스 코드를 orphan 브랜치로 관리하고 subtree merge로 메인에 통합하는 브랜치 전략.

---

## 언제 사용하는가

- 외부 라이브러리/프레임워크 소스를 레포에 직접 포함해야 할 때
- submodule 대신 소스를 직접 관리하면서 원본 이력을 추적하고 싶을 때
- vendor 코드에 자체 패치를 적용하면서 업데이트도 받아야 할 때

---

## 브랜치 구조

```
vendor/{lib} (orphan) ← 서드파티 원본 코드 전용
  │
  ├── main ← subtree merge로 vendor 코드 통합
  │     │
  │     ├── feat/xxx ← 일반 작업 브랜치
  │     └── fix/xxx
```

여러 서드파티 라이브러리가 있으면 각각 별도의 orphan 브랜치를 만든다:
- `vendor/lib-a`
- `vendor/lib-b`

### 역할 정의

| 브랜치 | 역할 | 직접 커밋 |
|--------|------|----------|
| `vendor/{lib}` | 서드파티 원본 코드 (orphan) | 업데이트 시에만 |
| `main` | 통합 브랜치. vendor + 자체 코드 | 머지만 (또는 일반 커밋) |
| `feat/*`, `fix/*` | 작업 브랜치 | 허용 |

---

## 초기 설정: Orphan 브랜치 생성

```bash
# 1. orphan 브랜치 생성 (이력 없는 빈 브랜치)
git checkout --orphan vendor/my-lib
git rm -rf .

# 2. 서드파티 소스 복사
cp -r /path/to/vendor-source/* .
git add -A
git commit -m "vendor: import my-lib v1.0.0"

# 3. main으로 돌아가기
git checkout main
```

---

## Subtree Merge로 통합

```bash
# vendor 브랜치를 특정 디렉토리에 subtree merge
git read-tree --prefix=vendor/my-lib/ -u vendor/my-lib

# 커밋
git commit -m "vendor: merge my-lib v1.0.0 into vendor/my-lib/"
```

또는 `git subtree` 명령 사용:

```bash
# subtree add (최초)
git subtree add --prefix=vendor/my-lib vendor/my-lib main --squash

# subtree merge (업데이트)
git subtree merge --prefix=vendor/my-lib vendor/my-lib --squash
```

---

## 업데이트 워크플로우

서드파티 라이브러리의 새 버전이 나왔을 때:

```bash
# 1. vendor 브랜치에서 업데이트
git checkout vendor/my-lib
git rm -rf .
cp -r /path/to/vendor-source-v2/* .
git add -A
git commit -m "vendor: update my-lib to v2.0.0"

# 2. main으로 돌아가서 subtree merge
git checkout main
git subtree merge --prefix=vendor/my-lib vendor/my-lib --squash
# 충돌 발생 시: 자체 패치와 새 버전의 변경을 비교하여 해결

# 3. push
git push origin main
git push origin vendor/my-lib
```

---

## 자체 패치 관리

vendor 코드에 패치가 필요한 경우:

- **main 브랜치에서 직접 수정한다** (vendor 브랜치는 원본 유지)
- vendor 업데이트 시 충돌로 패치 지점이 드러나므로 리뷰 가능
- 패치 내역은 커밋 메시지에 `vendor-patch:` 접두사로 기록 권장

```bash
# main에서 vendor 코드 패치
git checkout main
# vendor/my-lib/ 내 파일 수정
git add vendor/my-lib/patched-file.js
git commit -m "vendor-patch: fix compatibility issue in my-lib"
```

---

## 규칙 요약

1. **vendor 브랜치는 서드파티 원본만 담는다** — 자체 패치는 main에서
2. **orphan 브랜치로 생성한다** — 메인 이력과 분리
3. **subtree merge로 통합한다** — 디렉토리 경로를 명확히 지정
4. **업데이트 시 squash merge 권장** — 이력을 깔끔하게 유지
5. **자체 패치는 커밋 메시지로 추적한다** — `vendor-patch:` 접두사 사용
