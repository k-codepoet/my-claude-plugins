---
name: skill-guide
description: Claude Code 스킬(SKILL.md) 작성법 가이드. 스킬 만들기, Agent Skills 표준, Progressive Disclosure 원칙, frontmatter 필드에 대해 질문할 때 사용합니다.
---

# Skills (스킬) 가이드

## 개념

**Claude가 작업 컨텍스트를 보고 자동으로 로드하여 사용하는 전문 지식과 워크플로우**입니다. 사용자가 명시적으로 호출하지 않아도 Claude가 필요하다고 판단하면 자동으로 활성화됩니다.

### Agent Skills 표준

[agentskills.io](https://agentskills.io)에서 관리하는 **오픈 스탠다드**로, Claude뿐만 아니라 다른 AI 에이전트에서도 동일한 스킬을 재사용할 수 있습니다.

## 디렉토리 구조

```
my-skill/
├── SKILL.md           # 필수: 스킬 정의
├── scripts/           # 선택: 실행 가능한 스크립트
├── references/        # 선택: 상세 참고 문서
└── assets/           # 선택: 템플릿, 이미지 등
```

## SKILL.md 작성법

```markdown
---
name: pdf-processing
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction.
license: Apache-2.0
compatibility: Requires python3, poppler-utils
metadata:
  author: myorg
  version: "1.0"
allowed-tools: Bash(python3:*) Read Write
---

# PDF Processing Skill

## Overview
이 스킬은 PDF 문서 작업을 지원합니다...

## Usage
1. PDF 텍스트 추출하기
2. 폼 필드 채우기
3. PDF 병합하기

## Examples
...
```

## 필수 필드 (Frontmatter)

| 필드 | 필수 | 제약사항 |
|------|------|----------|
| `name` | Y | 1-64자, 소문자+숫자+하이픈만, 디렉토리명과 일치 |
| `description` | Y | 1-1024자, 무엇을 하는지 + 언제 사용하는지 포함 |
| `license` | - | 라이선스 정보 |
| `compatibility` | - | 환경 요구사항 (1-500자) |
| `metadata` | - | 추가 메타데이터 (key-value) |
| `allowed-tools` | - | 사전 승인된 도구 목록 (실험적) |

## Progressive Disclosure 원칙

1. **Metadata** (~100 토큰): `name`과 `description`은 시작 시 모든 스킬에 대해 로드
2. **Instructions** (<5000 토큰 권장): `SKILL.md` 본문은 스킬 활성화 시 로드
3. **Resources** (필요시): `scripts/`, `references/`, `assets/` 파일은 필요할 때만 로드

## 검증

```bash
skills-ref validate ./my-skill
```

## Skills vs Commands 비교

| 구분 | Skills | Commands |
|------|--------|----------|
| 호출 방식 | Claude가 자동 판단 | 사용자가 명시적으로 `/command` |
| 범위 | 작업별, 필요시 로드 | 항상 사용 가능 |
| 표준 | Agent Skills 오픈 스탠다드 | Claude Code 전용 |
| 사용 목적 | 재사용 가능한 전문 워크플로우 | 특정 프로젝트 작업 자동화 |
