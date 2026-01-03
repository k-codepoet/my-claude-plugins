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

### $ARGUMENTS 없이 실행

1. views/by-subject/ 폴더 확인
2. 기존 view 목록 표시
3. "새로 만들까요, 아니면 기존 것을 업데이트할까요?" 질문

### $ARGUMENTS로 subject 지정

1. views/by-subject/{subject}.md 존재 여부 확인
2. **존재하면**: views 태그 기반 자동 수집 → 업데이트
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

1. library에서 `views: [{subject}]` 태그된 문서 자동 수집
2. 새로 추가된 문서가 있으면 스토리 업데이트 제안
3. 변경사항 컨펌 후 저장

## 파일 위치

```
ground-truth/
├── library/        # 원천
└── views/
    └── by-subject/
        ├── gemify.md
        ├── forgeify.md
        └── gitops.md
```
