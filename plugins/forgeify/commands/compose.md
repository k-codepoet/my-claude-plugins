---
description: 여러 플러그인을 분석하여 필요한 부분만 추출하고 새로운 플러그인으로 조립합니다.
argument-hint: "<topic> <plugin1> [plugin2] [plugin3] ..."
allowed-tools: Read, Write, Bash, Glob, Grep
---

# /forgeify:compose - 플러그인 조립

여러 플러그인에서 필요한 부분을 추출하여 새로운 플러그인으로 조립합니다.

## 사용법

```
/forgeify:compose <topic> <plugin1> [plugin2] [plugin3] ...
```

- `<topic>`: 새로 만들 플러그인 주제/이름
- `<plugin1,2,3...>`: 소스로 사용할 플러그인 경로들

## 참조 스킬 (Progressive Disclosure)

조립 시 각 구성요소는 해당 스킬 규격을 따릅니다:

| 구성요소 | 참조 스킬 |
|----------|-----------|
| plugin.json | **plugin-guide** |
| commands/*.md | **command-guide** |
| skills/*/SKILL.md | **skill-guide** |
| agents/*.md | **agent-guide** |

## 워크플로우

### 1단계: 플러그인 분석
- 각 소스 플러그인의 구성요소 목록화
- 컴포넌트별 역할 정리하여 사용자에게 제시

### 2단계: 사용자 선택
- 포함할 commands, skills, agents, scripts 선택

### 3단계: 컴포넌트 조립
- 선택된 컴포넌트들을 새 플러그인 구조로 조립
- `${CLAUDE_PLUGIN_ROOT}` 경로 유지

### 4단계: 통합 및 수정
- 이름 충돌 해결
- 스크립트 의존성 확인
- skill 디렉토리 구조 유지 (skill-name/SKILL.md)

### 5단계: 검증
- `/forgeify:validate` 실행 권장

## 조립 규칙

1. **이름 충돌**: 같은 이름의 컴포넌트가 있으면 사용자에게 선택 요청
2. **스크립트 의존성**: 참조하는 스크립트 함께 포함
3. **원본 보존**: 원본 플러그인은 수정하지 않음

## 예시

```
/forgeify:compose my-devops ./plugins/homeserver-gitops ./plugins/ubuntu-dev-setup
```
