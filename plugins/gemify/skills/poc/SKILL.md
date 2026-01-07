---
name: poc
description: PoC 개발 문서 생성. Craftify 또는 Forgeify에게 위임할 POC.md를 만듭니다. "PoC 만들자", "앱 시작", "프로젝트 시작", "플러그인 만들자" 등 요청 시 활성화.
---

# PoC Skill

PoC 개발 **문서를 생성**합니다. 실제 구현은 타입에 따라 craftify 또는 forgeify가 담당합니다.

## 사전 확인 (필수)

**스킬 실행 전 반드시 확인:**

```
~/.gemify/ 존재?
├── 예 → 스킬 실행 계속
└── 아니오 → setup 안내 후 중단
```

Setup 안내:
```
~/.gemify/가 설정되지 않았습니다.

설정하기:
  /gemify:setup              # 새로 시작
  /gemify:setup --clone URL  # 기존 repo 가져오기
```

## 프로젝트 타입 판단

사용자 입력을 분석하여 타입 결정:

```
입력 분석
├── "앱", "웹", "서비스", "사이트" 등 → webapp
├── "플러그인", "커맨드", "스킬", "에이전트" 등 → plugin
└── 판단 불가 → 사용자에게 질문
```

판단 불가 시 질문:
```
어떤 타입의 프로젝트인가요?

1. webapp - 웹 앱/서비스 (craftify로 구현)
2. plugin - Claude Code 플러그인 (forgeify로 구현)
```

## 단방향 흐름 원칙

```
gemify (지식 생산)
    │
    └── POC.md 생성 ─────────┬──▶ craftify (webapp 구현)
        (Why/What)           │
                             └──▶ forgeify (plugin 구현)
```

- **gemify:poc**: 대화를 통해 요구사항을 정제하고 POC.md 생성
- **craftify**: webapp POC.md를 읽고 기술 스택/구현 방법을 스스로 판단
- **forgeify**: plugin POC.md를 읽고 플러그인 구조/구현 방법을 스스로 판단
- 역방향 없음: gemify는 How를 지정하지 않음

## 워크플로우 (6단계)

| 단계 | 설명 |
|------|------|
| 1. triage | 관련 inbox 자료 수집 (클러스터 기반) |
| 2. draft | facet 모드로 Why/Hypothesis/What/AC 구체화 |
| 3. namify:name | 제품명 결정 (자동 호출) |
| 4. view | views/by-poc/{product}.md 저장 + 스냅샷 |
| 5. setup | 프로젝트 폴더 생성, POC.md 복사, git init |
| 6. library | 필요한 재료들 저장 (선택) |

## 동작

### 1. 입력 분석 (triage 연동)

- 따옴표 문자열 → 새 아이디어로 triage 검색
- inbox 파일 경로 → 해당 파일 기반으로 triage 확장
- 없음 → "어떤 PoC를 만들까요?" 후 triage 모드

### 2. 요구사항 구체화 (draft facet 모드)

대화를 통해 파악:
- **Why**: 배경, 해결할 문제
- **Hypothesis**: 검증하려는 가설
- **What**: 핵심 기능, MVP 범위
- **Acceptance Criteria**: 가설 검증 기준

### 3. 제품명 결정

`/namify:name` 자동 호출 → 메타포 탐색 → 후보 생성 → 사용자 선택

### 4. view 생성

- views/by-poc/{product}.md 파일 생성
- .history/poc/{product}/01-YYYY-MM-DD.md 스냅샷
- 템플릿: `references/view-template.md` 참조

### 5. 프로젝트 설정 (setup)

```
프로젝트를 어디에 생성할까요?
```

| 생성 파일 | 역할 |
|----------|------|
| POC.md | views/by-poc/{product}.md 복사본 |
| CONTEXT.md | 프로젝트 서사/맥락 |

views/by-poc/{product}.md의 `artifact` 필드 업데이트

### 6. library 저장 (선택)

specs, workflows 등 필요한 재료를 library/{type}/에 저장

## 완료 안내

타입에 따라 분기:

**webapp인 경우:**
```
POC.md가 생성되었습니다: {project-path}/POC.md

craftify로 구현을 시작하려면:
cd {project-path} && claude
/craftify:poc
```

**plugin인 경우:**
```
POC.md가 생성되었습니다: {project-path}/POC.md

forgeify로 구현을 시작하려면:
cd {project-path} && claude
/forgeify:poc
```

## 규칙

- **How 지정 금지**: gemify는 Why/What만 담당
- namify:name은 워크플로우 내에서 자동 호출
- 프로젝트 경로는 매번 사용자 확인
- **views/by-poc/에 원본 저장**, 프로젝트에는 복사
- **업데이트 시 .history/ 스냅샷 생성**
