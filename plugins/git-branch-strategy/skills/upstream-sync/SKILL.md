---
description: "upstream 동기화 절차 (Downstream Fork). 'upstream sync', 'upstream 머지' 요청 시 활성화."
---

# upstream 동기화 절차

> upstream 변경사항을 fork에 반영하는 절차. Downstream Fork 전략 전용.

---

## 사전 조건

- `.git-branch-strategy.json`이 존재해야 함
- `strategy`가 `downstream-fork`여야 함
- `upstream` 리모트가 설정되어 있어야 함

```bash
# 설정 파일에서 통합 브랜치 이름 읽기
INTEGRATION_BRANCH=$(cat .git-branch-strategy.json | jq -r '.integration_branch')
```

---

## 동기화 절차

### 1. upstream 최신 fetch

```bash
git fetch upstream
```

### 2. main 브랜치에서 머지

```bash
git checkout main
git merge upstream/main
```

### 3. 충돌 해결 (있을 경우)

아래 "자주 충돌하는 파일" 섹션 참고.
충돌이 있으면 해결 후 머지 커밋을 완료한다.

### 4. 빌드 확인

프로젝트의 빌드/테스트 명령어를 실행하여 정상 동작 확인.
(프로젝트마다 다르므로 CLAUDE.md 또는 AGENTS.md 참고)

### 5. main push

```bash
git push origin main
```

### 6. main → 통합 브랜치 동기화 (중요!)

```bash
git checkout $INTEGRATION_BRANCH
git merge main
git push origin $INTEGRATION_BRANCH
```

### 7. 태그 생성 (릴리스 시)

```bash
git checkout main
git tag v{버전}
git push origin main --tags
```

---

## 자주 충돌하는 파일

| 파일 | 충돌 원인 | 해결 방법 |
|------|----------|----------|
| `package.json` | name, version 등 fork에서 변경한 필드 | fork 값 유지 |
| `Cargo.toml` | version | fork 값 유지 |
| 빌드 설정 파일 | fork에서 커스텀한 설정 | fork 값 유지 |

> **원칙**: fork에서 의도적으로 변경한 값은 fork 값을 유지한다.
> upstream에서 새로 추가된 내용은 수용한다.

---

## 동기화 흐름 요약

```
upstream/main
  │
  ├──(merge)──→ main ──(push)──→ origin/main
  │                │
  │                └──(merge)──→ {통합 브랜치} ──(push)──→ origin/{통합 브랜치}
```

> **브랜치 정책**: upstream → main → 통합 브랜치 순서로 동기화.
> 상세: branching 스킬 참고

---

## 주의사항

- upstream 머지 후 의존성 설치 명령 실행 필요 (lockfile 변경 가능)
- 타입 생성 등 코드 생성 스크립트 재실행 필요 여부 확인
- CI 파이프라인 설정 변경 여부 확인
