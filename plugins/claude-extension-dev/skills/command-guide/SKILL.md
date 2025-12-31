---
name: command-guide
description: Claude Code 슬래시 커맨드 작성법 가이드. 커맨드 만들기, YAML frontmatter 작성, Skills vs Commands 비교에 대해 질문할 때 사용합니다.
---

# Commands (커맨드) 가이드

## 개념

**사용자가 `/` 슬래시로 명시적으로 실행하는 커스텀 명령어**입니다. Skills와 달리 사용자가 직접 호출합니다.

## 디렉토리 구조

```
plugin-root/
└── commands/
    ├── deploy.md      # /deploy 커맨드
    └── analyze.md     # /analyze 커맨드
```

## 작성법

```markdown
---
name: deploy
description: Deploy the application to production
---

# Deploy Command

## Steps
1. Build the application
2. Run tests
3. Deploy to production

## Usage
/deploy --env production
```

## Skills vs Commands 비교

| 구분 | Skills | Commands |
|------|--------|----------|
| 호출 방식 | Claude가 자동 판단 | 사용자가 명시적으로 `/command` |
| 범위 | 작업별, 필요시 로드 | 항상 사용 가능 |
| 표준 | Agent Skills 오픈 스탠다드 | Claude Code 전용 |
| 사용 목적 | 재사용 가능한 전문 워크플로우 | 특정 프로젝트 작업 자동화 |
