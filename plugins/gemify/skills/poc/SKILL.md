---
name: poc
description: PoC 앱 개발 문서 생성. Craftify에게 위임할 WORK.md를 만듭니다. "PoC 만들자", "앱 시작", "프로젝트 시작" 등 요청 시 활성화.
---

# PoC Skill

PoC 앱 개발 **문서를 생성**합니다. 실제 구현은 craftify가 담당합니다.

## 단방향 흐름 원칙

```
gemify (지식 생산)        craftify (실행)
    │                         │
    └── WORK.md 생성 ────────▶ 프로젝트 구현
        (Why/What)            (How 판단)
```

- **gemify:poc**: 대화를 통해 요구사항을 정제하고 WORK.md 생성
- **craftify**: WORK.md를 읽고 기술 스택/구현 방법을 스스로 판단
- 역방향 없음: gemify는 How를 지정하지 않음

## 워크플로우 (6단계)

```
1. triage      - 관련 inbox 자료 수집
2. draft       - facet 모드로 요구사항 구체화
3. namify:name - 제품명 결정 (자동 호출)
4. view        - 서사 구조 생성
5. setup       - 프로젝트 폴더 + WORK.md + git init
6. library     - specs에 영구 저장
```

## 동작

### 1. 입력 분석

```
$ARGUMENTS 있음? → 아이디어/inbox 파일 경로로 사용
$ARGUMENTS 없음? → "어떤 PoC를 만들까요?" 질문
```

### 2. 관련 자료 수집 (triage 연동)

inbox에서 관련 thoughts/materials 탐색:
- 키워드 매칭
- 기존 draft가 있으면 이어가기 제안

### 3. 요구사항 구체화 (draft facet 모드)

대화를 통해 파악:
- **Why**: 배경, 해결할 문제
- **What**: 핵심 기능, 사용자 기대 결과
- **Acceptance Criteria**: 완료 조건

### 4. 제품명 결정 (namify:name 자동 호출)

```
/namify:name "{아이디어 한 줄 설명}"
```

- 메타포 탐색 → 후보 생성 → 검증 → 확정
- 사용자 최종 선택

### 5. 프로젝트 경로 확인

```
프로젝트를 어디에 생성할까요?
예: /home/choigawoon/k-codepoet/my-domains/products/{product-name}
```

- 기본값 없음, 매번 확인
- 예시는 사용자의 일반적인 작업 구조

### 6. 결과물 생성

**모든 결과물을 프로젝트 경로에 생성** (craftify가 바로 참조 가능):

| 파일 | 역할 |
|------|------|
| `{project-path}/WORK.md` | Craftify 작업 지시서 (Why/What) |
| `{project-path}/CONTEXT.md` | 프로젝트 서사/맥락 |

## WORK.md 템플릿

**원칙**: Why/What만 전달, How는 craftify가 판단

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

**craftify 판단 영역** (전달하지 않음):
- 기술 스택 (boilerplates에서 선택)
- 구체적 구현 방법
- 파일 구조

## 실행 연계

문서 생성 완료 후 안내:

```
WORK.md가 생성되었습니다:
{프로젝트 경로}/WORK.md

craftify로 구현을 시작하려면:
cd {프로젝트 경로} && claude
```

## 규칙

- **How 지정 금지**: gemify는 Why/What만 담당
- ground-truth 경로 필요 시 사용자에게 요청
- namify:name은 워크플로우 내에서 자동 호출
- 프로젝트 경로는 매번 사용자 확인
