---
description: library 지식을 목적별로 조합하여 views/에 저장 (subject, talk, curriculum, portfolio, essay)
allowed-tools: Read, Write, Edit, Glob, Grep
argument-hint: [type] [title]
---

# /gemify:view - Views 관리 커맨드

view 스킬을 사용하여 library 지식을 목적별로 조합합니다.

## 사용법

```
/gemify:view                      # 타입 선택 → 목록 또는 새로 만들기
/gemify:view subject gemify       # gemify subject view 생성/업데이트
/gemify:view talk ai-for-devs     # talk view 생성
/gemify:view curriculum plugin-101 # curriculum view 생성
/gemify:view portfolio developer   # portfolio view 생성
/gemify:view essay why-i-write    # essay view 생성

# 하위 호환 (type 생략 시 subject)
/gemify:view gemify               # = /gemify:view subject gemify
```

## View 타입

| 타입 | 목적 | 서사의 핵심 질문 |
|------|------|-----------------|
| subject | 문제 → 해결책 | 어떤 문제를 어떻게 풀었는가? |
| talk | 메시지 전달 | 청중이 무엇을 깨닫고 가는가? |
| curriculum | 가르침 | 학습자가 무엇을 할 수 있게 되는가? |
| portfolio | 셀프 브랜딩 | 나는 어떤 사람인가? (증명과 함께) |
| essay | 자기 성찰 | 나는 무엇을 믿고/느끼는가? |

## 파이프라인 위치

```
library/ → [/gemify:view] → views/by-{type}/
(모델)                       (렌더링 레이어)
```

## 동작

view 스킬(`skills/view/SKILL.md`)의 지시사항을 따라 처리한다.

### $ARGUMENTS 없이 실행

1. "어떤 타입의 view를 만들까요?" 질문
   - subject, talk, curriculum, portfolio, essay 선택
2. 선택한 타입의 views/by-{type}/ 폴더 확인
3. 기존 view 목록 표시
4. "새로 만들까요, 아니면 기존 것을 업데이트할까요?" 질문

### $ARGUMENTS로 타입만 지정

```
/gemify:view talk
```

1. views/by-talk/ 폴더 확인
2. 기존 view 목록 표시
3. "새로 만들까요, 아니면 기존 것을 업데이트할까요?" 질문

### $ARGUMENTS로 타입+제목 지정

```
/gemify:view talk ai-for-devs
```

1. views/by-talk/ai-for-devs.md 존재 여부 확인
2. **존재하면**: 스냅샷 생성 → views 태그 기반 자동 수집 → 업데이트
3. **없으면**: 타입별 렌즈 질문으로 정보 수집 → 신규 생성

### 하위 호환 (단일 인자)

```
/gemify:view gemify
```

첫 번째 인자가 타입(subject, talk, curriculum, portfolio, essay)이 아니면:
- `subject`로 간주: `/gemify:view subject gemify`와 동일

## 타입별 생성 흐름

### subject (기본)
1. 어떤 subject인가요?
2. artifact 경로는?
3. 어떤 domain들과 관련있나요?
4. 참조할 library 문서들은?

### talk
1. 발표 제목은?
2. 청중은 누구인가요?
3. 청중이 얻어갈 것(takeaway)은?
4. 발표 시간은?
5. 참조할 library 문서들은?

### curriculum
1. 커리큘럼 제목은?
2. 대상자는 누구인가요?
3. 대상자 수준은? (beginner/intermediate/advanced)
4. 학습 목표는?
5. 모듈 구성은?
6. 참조할 library 문서들은?

### portfolio
1. 포트폴리오 제목은?
2. 어떤 역할로 셀링하나요?
3. 강조할 강점은?
4. 증명할 수 있는 evidence는?
5. 참조할 library 문서들은?

### essay
1. 에세이 제목은?
2. 어떤 질문에 대한 답인가요?
3. 어떤 톤/감정인가요?
4. 참조할 library 문서들은?

## View 업데이트 흐름 (기존)

**중요: 업데이트 전 반드시 히스토리 스냅샷 생성**

1. 기존 view 파일을 `views/.history/{type}/{slug}/`에 스냅샷으로 저장
2. library에서 `views: [{slug}]` 태그된 문서 자동 수집
3. 새로 추가된 문서가 있으면 스토리 업데이트 제안
4. 변경사항 컨펌 후 저장 (revision 증가)

## 폴더 구조

```
views/
├── by-subject/       # 문제 해결
│   ├── gemify.md
│   └── forgeify.md
├── by-talk/          # 발표
├── by-curriculum/    # 교육
├── by-portfolio/     # 포트폴리오
├── by-essay/         # 에세이
└── .history/
    ├── subject/
    │   └── gemify/
    │       └── 01-2024-12-31.md
    ├── talk/
    ├── curriculum/
    ├── portfolio/
    └── essay/
```

## 파일 위치

```
ground-truth/
├── library/        # 원천 (모델)
└── views/
    ├── by-subject/
    ├── by-talk/
    ├── by-curriculum/
    ├── by-portfolio/
    ├── by-essay/
    └── .history/
```
