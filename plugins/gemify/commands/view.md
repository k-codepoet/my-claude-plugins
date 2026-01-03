---
description: library 지식을 주제별로 조합하여 views/by-subject/에 저장
allowed-tools: Read, Write, Edit, Glob, Grep
argument-hint: [subject]
---

# /gemify:view - Views 관리 커맨드

view 스킬을 사용하여 library 지식을 주제별로 조합합니다.

## 사용법

```
/gemify:view              # views 목록 보여주고 선택 또는 새로 만들기
/gemify:view gemify       # gemify view 생성/업데이트
```

## 파이프라인 위치

```
library/ → [/gemify:view] → views/by-subject/
(원천)                       (조합 레이어)
```

## 동작

view 스킬(`skills/view/SKILL.md`)의 지시사항을 따라 처리한다.

### $ARGUMENTS 없이 실행

1. views/by-subject/ 폴더 확인
2. 기존 view 목록 표시
3. "새로 만들까요, 아니면 기존 것을 업데이트할까요?" 질문

### $ARGUMENTS로 subject 지정

1. views/by-subject/{subject}.md 존재 여부 확인
2. **존재하면**: 스냅샷 생성 → views 태그 기반 자동 수집 → 업데이트
3. **없으면**: 대화로 관련 문서 수집 → 신규 생성

## View 생성 흐름 (신규)

1. "어떤 주제의 view를 만들까요?" (subject 미지정시)
2. "관련 문서가 뭐야?"
3. 사용자가 알려주면 해당 library 문서에 `views: [subject]` 추가 제안
4. views/by-subject/{subject}.md 생성
   - 구조 (도식)
   - 스토리 (왜 → 뭘 → 어디까지)
   - 관련 문서 목록

## View 업데이트 흐름 (기존)

**중요: 업데이트 전 반드시 히스토리 스냅샷 생성**

1. 기존 view 파일을 `views/.history/{subject}/`에 스냅샷으로 저장
2. library에서 `views: [{subject}]` 태그된 문서 자동 수집
3. 새로 추가된 문서가 있으면 스토리 업데이트 제안
4. 변경사항 컨펌 후 저장 (revision 증가)

## 히스토리 구조

```
views/
├── by-subject/
│   ├── gemify.md           # 현재 상태
│   └── forgeify.md
└── .history/
    ├── gemify/
    │   ├── 01-2024-12-31.md # 첫 버전 스냅샷
    │   └── 02-2025-01-15.md # 두 번째 버전 스냅샷
    └── forgeify/
        └── 01-2024-12-31.md
```

## 파일 위치

```
ground-truth/
├── library/        # 원천
└── views/
    ├── by-subject/ # 현재 views
    │   ├── gemify.md
    │   ├── forgeify.md
    │   └── gitops.md
    └── .history/   # 변경 히스토리
        └── {subject}/
            └── {rev:02d}-{YYYY-MM-DD}.md
```
