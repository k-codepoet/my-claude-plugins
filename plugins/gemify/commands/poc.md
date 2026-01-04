---
description: PoC 앱 개발 문서 생성 - Craftify에게 위임할 WORK.md를 만듭니다. Why/What만 전달하고 How는 craftify가 판단.
allowed-tools: Read, Write, Glob, Grep, Bash, Skill
argument-hint: ["아이디어 설명" | inbox 파일 경로]
---

# /gemify:poc - PoC 앱 개발 문서 생성

PoC 앱 개발 **문서를 생성**합니다. 실제 구현은 craftify가 담당합니다.

## 단방향 흐름

```
gemify (지식 생산)        craftify (실행)
    │                         │
    └── WORK.md 생성 ────────▶ 프로젝트 구현
        (Why/What)            (How 판단)
```

## 사용법

```
/gemify:poc "초등학교 시간표 앱"
/gemify:poc inbox/thoughts/session-report-viewer-idea.md
/gemify:poc                    # 아이디어 입력 요청
```

## 동작

### 1. 입력 분석

```
$ARGUMENTS 있음?
├── 따옴표로 감싼 문자열 → 새 아이디어로 시작
└── 파일 경로 → 해당 파일 읽고 시작

$ARGUMENTS 없음? → "어떤 PoC를 만들까요?" 질문
```

### 2. 관련 자료 수집

inbox에서 관련 thoughts/materials 탐색:
- 키워드로 Grep 검색
- 발견되면 참조 여부 확인

### 3. 요구사항 구체화 (대화)

대화를 통해 파악:
- **Why**: 배경, 해결할 문제
- **What**: 핵심 기능, 사용자 기대 결과
- **Acceptance Criteria**: 완료 조건

### 4. 제품명 결정

```
/namify:name 호출 (자동)
```

- 사용자 최종 선택 후 확정

### 5. 프로젝트 경로 확인

```
프로젝트를 어디에 생성할까요?
예: /home/choigawoon/k-codepoet/my-domains/products/{product-name}
```

### 6. 결과물 생성

**모든 결과물을 프로젝트 경로에 생성** (craftify가 바로 참조 가능):

```bash
mkdir -p {project-path}
# WORK.md + CONTEXT.md 생성
git init && git add . && git commit -m "Initial: WORK.md + CONTEXT.md"
```

| 파일 | 역할 |
|------|------|
| `{project-path}/WORK.md` | Craftify 작업 지시서 (Why/What) |
| `{project-path}/CONTEXT.md` | 프로젝트 서사/맥락 |

### 7. 완료 안내

```
WORK.md가 생성되었습니다:
{프로젝트 경로}/WORK.md

craftify로 구현을 시작하려면:
cd {프로젝트 경로} && claude
```

## WORK.md 템플릿

```markdown
# {product-name} WORK.md

## Why - 왜 만드는가
- 배경/맥락
- 해결하려는 문제

## What - 무엇을 만드는가
- 핵심 기능 목록
- 사용자 기대 결과

## Context - 참조
- ground-truth 문서 링크
- 관련 대화/세션 기록

## Acceptance Criteria - 완료 조건
- [ ] 체크리스트 형태
```

## 규칙

- **How 지정 금지**: gemify는 Why/What만 담당
- namify:name은 워크플로우 내에서 자동 호출
- 프로젝트 경로는 매번 사용자 확인
- git init으로 바로 작업 시작 가능한 상태로 생성
