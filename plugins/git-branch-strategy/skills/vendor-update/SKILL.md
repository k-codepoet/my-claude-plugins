---
description: "vendor 브랜치 업데이트 절차 (Vendor Branch). 'vendor update', 'vendor 업데이트' 요청 시 활성화."
---

# vendor 브랜치 업데이트 절차

> 외부 라이브러리의 새 버전을 vendor 브랜치에 반영하고 main에 머지하는 절차.

---

## 사전 조건

- `.git-branch-strategy.json`이 존재해야 함
- `strategy`가 `vendor-branch`여야 함
- vendor 브랜치(`vendor/{라이브러리명}`)가 이미 존재해야 함

---

## 업데이트 절차

### 1. vendor 브랜치 체크아웃

```bash
LIB_NAME="라이브러리명"
git checkout vendor/$LIB_NAME
```

### 2. vendor 코드 교체

기존 vendor 코드를 새 버전으로 교체한다:

```bash
# 기존 코드 삭제 (vendor 디렉토리 내용)
rm -rf vendor/$LIB_NAME/*

# 새 버전 코드 복사
# (다운로드, 압축 해제 등 라이브러리에 맞는 방법 사용)
cp -r /path/to/new-version/* vendor/$LIB_NAME/
```

### 3. vendor 브랜치에 커밋

```bash
git add -A
git commit -m "vendor($LIB_NAME): update to v{새버전}"
```

### 4. main에 subtree 머지

```bash
git checkout main
git merge vendor/$LIB_NAME
```

### 5. 충돌 해결

vendor 코드와 main의 커스텀 수정 사이에 충돌이 발생할 수 있다.

| 충돌 유형 | 해결 방법 |
|----------|----------|
| vendor 원본 파일 변경 | 새 vendor 코드 수용 후 커스텀 수정 재적용 |
| 커스텀 설정 파일 | 커스텀 값 유지, 새 옵션 추가 |
| 삭제된 파일 | vendor에서 삭제했으면 삭제 수용 |

### 6. 빌드 확인

프로젝트의 빌드/테스트 명령어를 실행하여 정상 동작 확인.

### 7. push

```bash
git push origin main
```

---

## vendor 브랜치 초기 설정

새 라이브러리를 vendor로 추가할 때:

```bash
# orphan 브랜치 생성 (히스토리 없이)
git checkout --orphan vendor/$LIB_NAME
git rm -rf .

# vendor 코드 추가
cp -r /path/to/library/* .
git add -A
git commit -m "vendor($LIB_NAME): initial import v{버전}"

# main에 subtree 머지
git checkout main
git merge vendor/$LIB_NAME --allow-unrelated-histories -s subtree
git push origin main vendor/$LIB_NAME
```

---

## 업데이트 흐름 요약

```
vendor/{라이브러리}  (새 버전 코드 교체 + 커밋)
  │
  └──(subtree merge)──→ main ──(push)──→ origin/main
```

---

## 주의사항

- vendor 브랜치에는 vendor 코드만 존재해야 함 (커스텀 수정 금지)
- 커스텀 수정은 항상 main에서 수행
- subtree 머지 시 `--squash` 옵션 사용 여부는 프로젝트 정책에 따라 결정
- vendor 브랜치 이름은 `vendor/` 접두사 필수
