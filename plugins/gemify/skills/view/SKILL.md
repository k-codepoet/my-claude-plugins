---
name: view
description: library 지식을 목적별로 조합하여 views/에 저장. 8가지 타입(plugin, product, talk, curriculum, portfolio, essay, poc, improvement)별 렌즈로 지식을 렌더링.
allowed-tools: Read, Write, Edit, Glob, Grep
argument-hint: "[type]|[title]"
---

# View Skill

library의 지식을 **목적(view type)별로 조합**하여 views에 저장합니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 핵심 개념

```
library/     ← 모델 (재사용 가능한 원자 단위)
    ↓
views/       ← 렌더링 레이어 (서사가 있는 스토리텔링)
├── by-plugin/       # Claude Code 플러그인
├── by-product/      # 사용자용 제품/서비스
├── by-talk/         # 메시지 전달
├── by-curriculum/   # 가르침
├── by-portfolio/    # 셀프 브랜딩
├── by-essay/        # 철학/에세이
├── by-poc/          # PoC 프로젝트 (gemify:poc 전용)
├── by-improvement/  # 플러그인/제품 개선 (gemify:improve-plugin 전용)
├── by-bugfix/       # 버그 수정 (gemify:bugfix 전용)
└── .history/        # 변경 히스토리
```

**Views = 렌더링 레이어**
- library: 재사용 가능한 원자 단위 (지식의 재료)
- views: 서사(narrative)가 있는 스토리텔링

## View 타입 개요

| 타입 | 목적 | 서사의 핵심 질문 |
|------|------|-----------------|
| plugin | Claude Code 플러그인 | 어떤 플러그인을 왜/어떻게 만들었는가? |
| product | 사용자용 제품/서비스 | 어떤 제품을 왜/어떻게 만들었는가? |
| talk | 메시지 전달 | 청중이 무엇을 깨닫고 가는가? |
| curriculum | 가르침 | 학습자가 무엇을 할 수 있게 되는가? |
| portfolio | 셀프 브랜딩 | 나는 어떤 사람인가? (증명과 함께) |
| essay | 철학/에세이 | 나는 무엇을 믿고/느끼는가? |
| poc | PoC 프로젝트 | 무엇을 왜 만들고 어디까지 왔는가? |
| improvement | 플러그인/제품 개선 | 어떤 문제를 어떻게 개선하는가? |
| bugfix | 버그 수정 | 어떤 버그를 어떻게 고쳤는가? |

## 타입별 대화 흐름 (렌즈 질문)

### by-plugin (신규)
1. 어떤 플러그인인가요? (이름)
2. 플러그인 경로는? (artifact)
3. 태그라인은? (한 문장으로 설명)
4. 참조할 library 문서들은?

### by-product (신규)
1. 어떤 제품/서비스인가요? (이름)
2. 프로젝트 경로는? (artifact)
3. 태그라인은? (한 문장으로 설명)
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

### by-improvement (gemify:improve-plugin 전용)

**참고**: by-improvement는 `/gemify:improve-plugin` 커맨드가 직접 생성합니다.

### by-bugfix (gemify:bugfix 전용)

**참고**: by-bugfix는 `/gemify:bugfix` 커맨드가 직접 생성합니다.

## 타입별 Frontmatter 템플릿

### by-plugin (신규)
```yaml
---
title: "{Plugin Name}"
plugin: {plugin-name}
artifact: {플러그인 경로}
tagline: "{한 문장 설명}"
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

### by-product (신규)
```yaml
---
title: "{Product Name}"
product: {product-name}
artifact: {프로젝트 경로}
tagline: "{한 문장 설명}"
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
# library 문서 중 views 필드에 해당 view가 있는 문서
views: [gemify, forgeify]  # 이 문서는 gemify, forgeify view에 포함
```

**대화로 수집 (신규 생성 시):**
1. 타입별 렌즈 질문으로 정보 수집
2. 사용자가 알려주면 해당 문서에 `views: [slug]` 추가

### 2. View 파일 생성/업데이트

**by-plugin (신규):**
```markdown
# {Plugin Name}

> {tagline}

## 구조
(아키텍처, 주요 컴포넌트)

## 스토리
(왜 시작 → 뭘 결정 → 어디까지)

## 관련 문서
(views: [slug] 태그 기반 자동 수집 목록)
```

**by-product (신규):**
```markdown
# {Product Name}

> {tagline}

## 구조
(아키텍처, 주요 기능)

## 스토리
(왜 시작 → 뭘 결정 → 어디까지)

## 관련 문서
(views: [slug] 태그 기반 자동 수집 목록)
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
├── by-plugin/        # Claude Code 플러그인
│   ├── gemify.md
│   └── forgeify.md
├── by-product/       # 사용자용 제품/서비스
│   └── tetritime.md
├── by-talk/          # 발표
├── by-curriculum/    # 교육
├── by-portfolio/     # 포트폴리오
├── by-essay/         # 철학/에세이
│   └── design-philosophy.md
├── by-poc/           # PoC 프로젝트 (gemify:poc 전용)
│   └── {product}.md
├── by-improvement/   # 플러그인/제품 개선 (gemify:improve-plugin 전용)
├── by-bugfix/        # 버그 수정 (gemify:bugfix 전용)
└── .history/         # 변경 히스토리
    ├── plugin/
    │   └── gemify/
    │       └── 01-2024-12-31.md
    ├── product/
    ├── talk/
    ├── curriculum/
    ├── portfolio/
    ├── essay/
    ├── poc/
    ├── improvement/
    └── bugfix/
```

## 파일명 규칙

- **by-plugin**: `{plugin-name}.md` (영문 kebab-case)
- **by-product**: `{product-name}.md` (영문 kebab-case)
- **by-talk**: `{slug}.md`
- **by-curriculum**: `{slug}.md`
- **by-portfolio**: `{slug}.md`
- **by-essay**: `{slug}.md`
- **by-poc**: `{product}.md` (namify:name 결과)
- **by-improvement**: `{target}-{slug}.md`
- **by-bugfix**: `{target}-{slug}.md`

## 세션 동작

| 시점 | 동작 |
|------|------|
| 목록 | 타입 선택 → 해당 폴더 파일 목록 표시 |
| 신규 | 타입별 렌즈 질문 → 관련 문서 수집 → view 생성 |
| 업데이트 | **스냅샷 생성** → views 태그 기반 자동 수집 → 갱신 |

## 규칙

- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- 타입 생략 시 "무엇을 만들었나요?" 질문으로 분기
- library 문서에 views 태그 추가 시 사용자 확인
- **업데이트 시 반드시 히스토리 스냅샷 생성**

## 타입 선택 가이드

타입을 명시하지 않았을 때:
```
"무엇에 대한 view인가요?"
├── Claude Code 플러그인 → by-plugin/
├── 사용자용 제품/서비스 → by-product/
├── 아직 검증 중 (PoC) → by-poc/ (→ gemify:poc 안내)
├── 발표/강연 → by-talk/
├── 교육/커리큘럼 → by-curriculum/
├── 포트폴리오/셀프 브랜딩 → by-portfolio/
└── 철학/생각/에세이 → by-essay/
```

## 마이그레이션 노트 (v1.21.0)

`by-subject`는 deprecated되었습니다.
- 플러그인 → `by-plugin/`으로 이동
- 제품/서비스 → `by-product/`으로 이동
- 철학/에세이 → `by-essay/`로 이동

기존 `by-subject/` 파일들은 현재 도메인 저장소에서 직접 마이그레이션 필요.

> **Note**: `~/.gemify/{domain}/`은 해당 도메인의 지식 저장소(Single Source of Truth)입니다.
