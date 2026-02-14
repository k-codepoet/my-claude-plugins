---
description: "Git repo를 분석하여 관리체계/워크플로우/프로세스를 Claude Code 스킬 또는 플러그인으로 변환"
argument-hint: "<repo-path-or-url> [--mode project-local|plugin]"
---

# /forgeify:harvest

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/harvest/SKILL.md
```

스킬의 워크플로우(7단계)를 따라 진행하세요.

**스캔 대상 참조가 필요하면:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/harvest/references/scan-targets.md
```

## 사용법

```
/forgeify:harvest <repo-path-or-url> [--mode project-local|plugin]
```

ARGUMENTS: $ARGUMENTS

### 인자

- `repo-path-or-url` (필수): 분석할 repo의 로컬 경로 또는 git clone URL
- `--mode` (선택): 출력 형식
  - `project-local` (기본): 대상 repo의 `.claude/skills/`에 스킬 생성
  - `plugin`: 새 플러그인 구조로 생성

### 예시

```bash
# 현재 디렉토리의 repo 분석
/forgeify:harvest .

# 특정 경로의 repo 분석
/forgeify:harvest /path/to/my-project

# git URL에서 clone 후 분석
/forgeify:harvest https://github.com/user/repo.git

# 플러그인으로 생성
/forgeify:harvest /path/to/project --mode plugin
```

## 워크플로우 요약

1. **소스 준비** - 로컬 경로 확인 또는 shallow clone
2. **스캔** - 핵심 파일 탐색 (CLAUDE.md, docs/, scripts/, CI config 등)
3. **분석 & 분류** - 패턴을 카테고리별로 그룹화
4. **사용자 선택** - 생성할 스킬 선택
5. **출력 모드 확인** - project-local vs plugin
6. **생성** - SKILL.md + references/ 생성, CLAUDE.md 슬림화 제안
7. **검증** - 키워드 중복, 경로 유효성 확인
