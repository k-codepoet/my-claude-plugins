---
description: PoC 앱 개발 문서 생성 - Craftify에게 위임할 POC.md를 만듭니다. Why/What만 전달하고 How는 craftify가 판단.
allowed-tools: Read, Write, Glob, Grep, Bash, Skill
argument-hint: ["아이디어 설명" | inbox 파일 경로]
---

# /gemify:poc - PoC 앱 개발 문서 생성

PoC 앱 개발 **문서를 생성**합니다. 실제 구현은 craftify가 담당합니다.

## 단방향 흐름

```
gemify (지식 생산)        craftify (실행)
    │                         │
    └── POC.md 생성 ─────────▶ 프로젝트 구현
        (Why/What)            (How 판단)
```

## 사용법

```
/gemify:poc "초등학교 시간표 앱"
/gemify:poc inbox/thoughts/session-report-viewer-idea.md
/gemify:poc                    # 아이디어 입력 요청
```

## 워크플로우 (6단계)

```
1. triage      - 관련 inbox 자료 수집 (클러스터 기반)
2. draft       - facet 모드로 Why/Hypothesis/What/AC 구체화
3. namify:name - 제품명 결정 (자동 호출)
4. view        - views/by-poc/{product}.md 저장
5. setup       - 프로젝트 폴더 생성 + POC.md 복사
6. library     - 필요한 재료들 저장 (선택)
```

## 동작

### 1. 입력 분석 (triage 연동)

```
$ARGUMENTS 분석
├─ 따옴표 문자열 → 새 아이디어
│   └─ triage: 관련 inbox 자료 검색
├─ inbox 파일 경로 → 해당 파일 기반
│   └─ triage: 추가 관련 자료 검색
└─ 없음 → "어떤 PoC를 만들까요?"
    └─ triage 모드: 클러스터 기반 선택
```

**triage 연동:**
- inbox에서 관련 thoughts/materials 탐색
- 키워드로 Grep 검색
- 발견되면 참조 여부 확인
- 기존 draft가 있으면 이어가기 제안

### 2. 요구사항 구체화 (draft facet 모드)

대화를 통해 파악:
- **Why**: 배경, 해결할 문제
- **Hypothesis**: 검증하려는 가설 (이것이 가능하다면 ~)
- **What**: 핵심 기능, MVP 범위
- **Acceptance Criteria**: 가설 검증 기준

### 3. 제품명 결정

```
/namify:name 호출 (자동)
```

- 메타포 탐색 → 후보 생성 → 검증
- 사용자 최종 선택 후 확정

### 4. view 생성

views/by-poc/{product}.md 파일 생성:
- frontmatter: product, hypothesis, artifact=null, sources
- 본문: Why/Hypothesis/What/AC (draft 결과)

**스냅샷 생성:**
- .history/poc/{product}/01-YYYY-MM-DD.md

**사용자 확인:**
```
views/by-poc/{product}.md 저장할까요? [Y/n]
```

### 5. 프로젝트 설정 (setup)

```
프로젝트를 어디에 생성할까요?
예: /home/choigawoon/k-codepoet/my-domains/products/{product-name}
```

**결과물 생성:**

```bash
mkdir -p {project-path}
# POC.md = views/by-poc/{product}.md 복사
# CONTEXT.md 생성
git init && git add . && git commit -m "Initial: POC.md + CONTEXT.md"
```

| 파일 | 역할 |
|------|------|
| `{project-path}/POC.md` | views/by-poc/{product}.md 복사본 |
| `{project-path}/CONTEXT.md` | 프로젝트 서사/맥락 |

**views/by-poc/{product}.md artifact 업데이트:**
```yaml
artifact: {project-path}
```

### 6. library 저장 (선택)

결과물 달성에 필요한 재료들 저장:

```
library에 저장할 문서가 있나요? [Y/n]
├─ Y → 문서 유형 선택 (spec, workflow 등)
│      → library/{type}/{product}-{slug}.md 저장
└─ n → 스킵
```

### 7. 완료 안내

```
POC.md가 생성되었습니다:
{프로젝트 경로}/POC.md

craftify로 구현을 시작하려면:
cd {프로젝트 경로} && claude
```

## views/by-poc/ 템플릿

```yaml
---
title: "{Product Name} PoC"
product: {product-name}
hypothesis: "{검증하려는 가설}"
artifact: {프로젝트 경로 | null}
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
revision: 1
sources: []
history:
  - rev: 1
    date: YYYY-MM-DD
    summary: "초기 생성"
---
```

**본문 구조:**
```markdown
## Why - 왜 만드는가
## Hypothesis - 검증하려는 가설
## What - 무엇을 만드는가
## Acceptance Criteria - 가설 검증 기준
## Context - 참조
```

**상태 파악 (artifact 기반):**
- `artifact: null` → 아이디어 단계
- `artifact: {path}` → 프로젝트 생성됨

## 규칙

- **How 지정 금지**: gemify는 Why/What만 담당
- namify:name은 워크플로우 내에서 자동 호출
- 프로젝트 경로는 매번 사용자 확인
- **views/by-poc/에 원본 저장**, 프로젝트에는 복사
- **업데이트 시 .history/ 스냅샷 생성**
- git init으로 바로 작업 시작 가능한 상태로 생성
