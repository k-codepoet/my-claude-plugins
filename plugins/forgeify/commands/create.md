---
description: 지정된 경로의 내용을 기반으로 Claude Code 플러그인을 생성합니다. 가이드라인에 맞춰 plugin.json, commands, skills, agents 구조를 자동 생성합니다.
argument-hint: "<path> <topic>"
allowed-tools: Read, Write, Bash, Glob, Grep
---

# /forgeify:create - 플러그인 생성

사용자가 지정한 경로와 주제를 기반으로 Claude Code 플러그인을 생성합니다.

## 사용법

```
/forgeify:create <path> <topic>
```

- `<path>`: 플러그인 소스가 될 파일 또는 디렉토리 경로
- `<topic>`: 플러그인 주제/이름 (예: "docker-helper", "git-workflow")

## 참조 스킬 (Progressive Disclosure)

각 구성요소 생성 시 해당 스킬을 반드시 참조합니다:

| 구성요소 | 참조 스킬 | 핵심 규격 |
|----------|-----------|-----------|
| plugin.json | **plugin-guide** | name(kebab-case), version, description, author |
| commands/*.md | **command-guide** | description 필수, allowed-tools, argument-hint |
| skills/*/SKILL.md | **skill-guide** | 디렉토리명=스킬명, Progressive Disclosure |
| agents/*.md | **agent-guide** | name, description, `<example>` 블록 |

## 워크플로우

### 1단계: 소스 분석
- 지정 경로의 파일/디렉토리 내용 분석
- 플러그인화 가능한 요소 식별:
  - 반복 작업 → Commands
  - 지식/가이드 → Skills
  - 자연어 트리거 → Agents
  - 스크립트 → scripts/

### 2단계: 구조 설계 및 사용자 확인
- 생성할 컴포넌트 목록 제시
- 사용자 승인 후 진행

### 3단계: 플러그인 생성
- 각 스킬 기준에 따라 구성요소 생성
- **agents 필드**: 반드시 개별 .md 파일 경로 (디렉토리 불가)

### 4단계: 마켓플레이스 등록
- marketplace.json에 자동 추가 (이미 등록되어 있으면 스킵)

### 5단계: 검증
- `/forgeify:validate` 자동 호출
- 오류 발생 시 자동 수정 시도

## 예시

```
/forgeify:create ~/my-scripts/docker-utils docker-helper
```
