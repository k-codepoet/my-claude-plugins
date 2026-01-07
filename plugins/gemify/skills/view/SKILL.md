---
name: view
description: library 지식을 목적별로 조합하여 views/에 저장. 6가지 타입(subject, talk, curriculum, portfolio, essay, poc)별 렌즈로 지식을 렌더링.
---

# View Skill

library의 지식을 **목적(view type)별로 조합**하여 views에 저장합니다.

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

## 핵심 개념

```
library/     ← 모델 (재사용 가능한 원자 단위)
    ↓
views/       ← 렌더링 레이어 (서사가 있는 스토리텔링)
├── by-subject/      # 문제 → 해결책
├── by-talk/         # 메시지 전달
├── by-curriculum/   # 가르침
├── by-portfolio/    # 셀프 브랜딩
├── by-essay/        # 자기 성찰
├── by-poc/          # PoC 프로젝트 (gemify:poc 전용)
└── .history/        # 변경 히스토리
```

**Views = 렌더링 레이어**
- library: 재사용 가능한 원자 단위 (지식의 재료)
- views: 서사(narrative)가 있는 스토리텔링

## View 타입 개요

| 타입 | 목적 | 서사의 핵심 질문 |
|------|------|-----------------|
| subject | 문제 → 해결책 | 어떤 문제를 어떻게 풀었는가? |
| talk | 메시지 전달 | 청중이 무엇을 깨닫고 가는가? |
| curriculum | 가르침 | 학습자가 무엇을 할 수 있게 되는가? |
| portfolio | 셀프 브랜딩 | 나는 어떤 사람인가? (증명과 함께) |
| essay | 자기 성찰 | 나는 무엇을 믿고/느끼는가? |
| poc | PoC 프로젝트 | 무엇을 왜 만들고 어디까지 왔는가? |

## 타입별 대화 흐름 (렌즈 질문)

### by-subject (기본)
1. 어떤 subject인가요?
2. artifact 경로는?
3. 어떤 domain들과 관련있나요? (복수 선택 가능)
   - product, engineering, operations, growth, business, ai-automation
4. 참조할 library 문서들은?

### by-talk
1. 발표 제목은?
2. 청중은 누구인가요?
3. 청중이 얻어갈 것(takeaway)은?
4. 발표 시간은?
5. 참조할 library 문서들은?

### by-curriculum
1. 커리큘럼 제목은?
2. 대상자는 누구인가요?
3. 대상자 수준은? (beginner/intermediate/advanced)
4. 학습 목표는?
5. 모듈 구성은?
6. 참조할 library 문서들은?

### by-portfolio
1. 포트폴리오 제목은?
2. 어떤 역할로 셀링하나요?
3. 강조할 강점은?
4. 증명할 수 있는 evidence는?
5. 참조할 library 문서들은?

### by-essay
1. 에세이 제목은?
2. 어떤 질문에 대한 답인가요?
3. 어떤 톤/감정인가요?
4. 참조할 library 문서들은?

### by-poc (gemify:poc 전용)

**참고**: by-poc는 `/gemify:poc` 커맨드가 직접 생성합니다. view 스킬에서 직접 생성하지 않음.

1. 제품명은? (namify:name 결과)
2. 프로젝트 경로는? (artifact)
3. 참조한 inbox/drafts 문서들은? (sources)

## 타입별 Frontmatter 템플릿

### by-subject
```yaml
---
title: "{Subject} View"
subject: {subject}
artifact: {연결된 결과물 경로}
domains:
  - {domain1}
  - {domain2}
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

### by-talk
```yaml
---
title: "{발표 제목}"
audience: "{청중}"
takeaway: "{청중이 얻어갈 것}"
duration: {시간}
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

### by-curriculum
```yaml
---
title: "{커리큘럼 제목}"
audience: "{대상}"
level: beginner|intermediate|advanced
objective: "{학습 목표}"
modules:
  - title: "{모듈1 제목}"
    sources: [...]
  - title: "{모듈2 제목}"
    sources: [...]
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

### by-portfolio
```yaml
---
title: "{포트폴리오 제목}"
role: "{역할}"
strengths:
  - {강점1}
  - {강점2}
evidence:
  - {증명1}
  - {증명2}
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

### by-essay
```yaml
---
title: "{에세이 제목}"
question: "{다루는 질문}"
mood: "{톤/감정}"
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

### by-poc (gemify:poc 전용)
```yaml
---
title: "{Product Name} PoC"
product: {product-name}
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

**상태 파악 (artifact 기반):**
- `artifact: null` → 아이디어 단계 (문서만 존재)
- `artifact: {path}` → 프로젝트 생성됨 (craftify 진행 가능)

## 핵심 행동

### 1. 관련 문서 수집

**자동 수집:**
```bash
# library 문서 중 views 필드에 해당 subject가 있는 문서
views: [gemify, forgeify]  # 이 문서는 gemify, forgeify view에 포함
```

**대화로 수집 (신규 생성 시):**
1. 타입별 렌즈 질문으로 정보 수집
2. 사용자가 알려주면 해당 문서에 `views: [subject]` 추가

### 2. View 파일 생성/업데이트

**by-subject (기본 형식):**
```markdown
# {Subject} View

## 구조
(단순 ASCII 도식, 필요시 Mermaid)

## 스토리
(왜 시작 → 뭘 결정 → 어디까지)

## 관련 문서
(views: [subject] 태그 기반 자동 수집 목록)
```

**by-talk:**
```markdown
# {발표 제목}

## 핵심 메시지
(청중이 기억할 한 가지)

## 흐름
(도입 → 전개 → 결론)

## 슬라이드 구성
(슬라이드별 요약)

## 참고 자료
(sources 목록)
```

**by-curriculum:**
```markdown
# {커리큘럼 제목}

## 학습 목표
(무엇을 할 수 있게 되는가)

## 모듈 구성
### 모듈 1: {제목}
- 학습 내용
- 실습

## 평가 방법
(어떻게 확인하는가)

## 참고 자료
(sources 목록)
```

**by-portfolio:**
```markdown
# {포트폴리오 제목}

## 나는 누구인가
(한 줄 정의)

## 강점
(증명과 함께)

## 대표 프로젝트
(evidence 기반)

## 참고 자료
(sources 목록)
```

**by-essay:**
```markdown
# {에세이 제목}

(자유 형식, 질문에 대한 답)

## 참고 자료
(sources 목록)
```

**by-poc (gemify:poc 전용):**
```markdown
# {Product Name} PoC

## Why - 왜 만드는가
(배경/맥락, 해결하려는 문제)

## What - 무엇을 만드는가
(핵심 기능, 사용자 기대 결과)

## Acceptance Criteria
- [ ] 완료 조건

## Context - 참조
(관련 draft, inbox 링크)
```

### 3. 양방향 연결

- **library → views**: `views: [gemify, forgeify]` 필드
- **views → library**: 스토리 안에 자연스러운 링크

### 4. 히스토리 스냅샷 (변경 시)

**업데이트 전 반드시 스냅샷 생성:**
1. 기존 view 파일이 존재하면 → `.history/{type}/{slug}/`에 스냅샷 저장
2. 스냅샷 파일명: `{revision:02d}-{YYYY-MM-DD}.md`
3. view 파일의 `revision` 증가 후 업데이트

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
├── by-poc/           # PoC 프로젝트 (gemify:poc 전용)
│   └── {product}.md
└── .history/         # 변경 히스토리
    ├── subject/
    │   └── gemify/
    │       └── 01-2024-12-31.md
    ├── talk/
    ├── curriculum/
    ├── portfolio/
    ├── essay/
    └── poc/
```

## 파일명 규칙

- **by-subject**: `{subject}.md` (영문 kebab-case)
- **by-talk**: `{slug}.md`
- **by-curriculum**: `{slug}.md`
- **by-portfolio**: `{slug}.md`
- **by-essay**: `{slug}.md`
- **by-poc**: `{product}.md` (namify:name 결과)

## 세션 동작

| 시점 | 동작 |
|------|------|
| 목록 | 타입 선택 → 해당 폴더 파일 목록 표시 |
| 신규 | 타입별 렌즈 질문 → 관련 문서 수집 → view 생성 |
| 업데이트 | **스냅샷 생성** → views 태그 기반 자동 수집 → 갱신 |

## 규칙

- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- 타입 생략 시 `subject`로 동작 (하위 호환)
- library 문서에 views 태그 추가 시 사용자 확인
- **업데이트 시 반드시 히스토리 스냅샷 생성**
