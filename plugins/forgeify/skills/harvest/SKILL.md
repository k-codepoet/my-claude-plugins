---
name: harvest
description: "Git repo를 분석하여 관리체계, 워크플로우, 프로세스를 Claude Code 스킬/플러그인으로 변환. repo 분석, 워크플로우 추출, harvest, 스킬 생성, 패턴 추출, repo에서 스킬 만들기 시 활성화."
---

# Harvest Skill

Git repo의 구조와 문서를 분석하여 Claude Code 스킬 또는 플러그인으로 변환합니다.

## 인자

```
/forgeify:harvest <repo-path-or-url> [--mode project-local|plugin]
```

- `repo-path-or-url`: 로컬 경로 또는 git clone URL
- `--mode`: 출력 형식 (기본: `project-local`)
  - `project-local`: 대상 repo의 `.claude/skills/`에 스킬 생성
  - `plugin`: 새 플러그인 구조로 생성 (forgeify:new-plugin 연계)

## 워크플로우

### 1단계: 소스 준비

**로컬 경로인 경우:**
- 경로 유효성 확인 (디렉토리 존재, git repo 여부)
- 해당 경로를 작업 대상으로 설정

**git URL인 경우:**
- `/tmp/forgeify-harvest-{repo-name}/`에 shallow clone:
  ```bash
  git clone --depth 1 {url} /tmp/forgeify-harvest-{repo-name}/
  ```
- clone된 경로를 작업 대상으로 설정
- 작업 완료 후 정리 안내 (사용자 판단에 맡김)

### 2단계: 스캔

대상 repo에서 패턴을 드러내는 파일을 탐색합니다.

**스캔 전략:**
1. Glob으로 아래 파일/디렉토리 존재 여부 확인
2. 발견된 파일의 내용을 Read로 수집
3. 파일별로 어떤 패턴을 드러내는지 태깅

**스캔 대상 목록은 Progressive Disclosure로 분리:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/harvest/references/scan-targets.md
```

**스캔 시 주의사항:**
- 파일이 너무 큰 경우 (500줄 이상) 처음 100줄 + 구조만 파악
- `.env`, credentials 등 민감 파일은 내용을 읽지 않고 존재 여부만 기록
- `.claude/skills/`가 이미 있으면 기존 스킬 목록 파악 (중복 방지)

### 3단계: 분석 & 분류

스캔 결과를 아래 카테고리로 그룹화:

| 카테고리 | 키워드 | 예시 소스 |
|----------|--------|-----------|
| **infrastructure** | 배포, 인프라, 컨테이너, docker | docker-compose.yml, Dockerfile, terraform/ |
| **ci-cd** | 파이프라인, 빌드, 테스트, CI | .github/workflows/, .gitlab-ci.yml |
| **development** | 개발 워크플로우, 코드 컨벤션 | package.json, Makefile, .editorconfig |
| **operations** | 운영, 모니터링, 유지보수, 스크립트 | scripts/, cron, monitoring config |
| **architecture** | 아키텍처, 시스템 구조, 설계 | docs/architecture/, README.md |
| **security** | 시크릿, 인증, 권한, vault | .env.example, vault config, auth/ |

**분류 규칙:**
- 하나의 파일이 여러 카테고리에 해당할 수 있음
- CLAUDE.md/AGENTS.md 내용은 섹션별로 분리하여 각 카테고리에 배분
- 카테고리에 해당하는 파일이 없으면 해당 카테고리 제외

**각 카테고리에 대해 산출:**
- 제안 스킬명 (lowercase-hyphen)
- description 초안 (트리거 키워드 포함)
- 포함할 핵심 내용 요약 (3~5줄)
- 참조할 기존 docs/ 파일 목록
- 예상 크기 (SKILL.md 본문 vs references/ 분리 필요 여부)

### 4단계: 사용자에게 제시 & 선택

발견된 패턴을 테이블로 제시:

```
## 발견된 패턴

| # | 카테고리 | 제안 스킬명 | 핵심 내용 | 소스 파일 수 |
|---|----------|------------|-----------|-------------|
| 1 | infrastructure | deploy-stack | 서비스 배포 워크플로우... | 5 |
| 2 | ci-cd | pipeline-ops | CI/CD 파이프라인... | 3 |
| ... | | | | |

생성할 스킬 번호를 선택하세요 (예: 1,2,3 또는 all):
```

사용자가 선택하지 않은 카테고리는 건너뜁니다.

### 5단계: 출력 모드 확인

**`--mode` 미지정 시 사용자에게 확인:**

- **project-local** (기본 추천): 대상 repo의 `.claude/skills/`에 생성
  - 해당 repo에서 Claude Code 사용 시 자동 로드
  - CLAUDE.md가 있으면 슬림화 제안도 함께 제공
- **plugin**: 새 플러그인으로 생성
  - 여러 프로젝트에서 재사용 가능
  - `forgeify:new-plugin` 워크플로우로 연계

### 6단계: 생성

선택된 각 스킬에 대해:

**SKILL.md 생성:**
```markdown
---
name: {스킬명}
description: "{what it does}. {when to activate - 트리거 키워드 나열}."
---

# {스킬명}

## 개요
{카테고리에서 추출한 핵심 내용 요약}

## 워크플로우 / 사용법
{스캔에서 발견한 구체적 명령어, 절차, 패턴}

## 규칙 / Guard Rails
{CLAUDE.md 등에서 추출한 제약사항}

## 참조
- {docs/ 파일 경로 목록}
```

**Progressive Disclosure 적용:**
- SKILL.md 본문은 5000 토큰 이내로 유지
- 테이블, 상세 목록, 설정 예시 등은 `references/`로 분리
- 기존 docs/ 파일이 있으면 중복 작성하지 않고 경로만 참조

**project-local 모드 추가 작업:**
- CLAUDE.md가 있고 200줄 이상이면 슬림화 제안:
  - 스킬로 이동한 섹션 목록 제시
  - 슬림화된 CLAUDE.md 초안 제안
  - 사용자 확인 후 적용 (자동 적용 금지)

**plugin 모드 추가 작업:**
- `forgeify:new-plugin` 스킬의 워크플로우를 참조하여 plugin.json, commands/ 등 생성
- 각 스킬에 대응하는 커맨드도 함께 생성 (Command-Skill 1:1 원칙)

### 7단계: 검증 & 완료

- 생성된 스킬 간 description 키워드 중복 확인
- 참조된 docs/ 파일 경로가 실제 존재하는지 확인
- plugin 모드인 경우 `forgeify:validate` 실행 제안
- 생성 결과 요약 테이블 출력:

```
## 생성 완료

| 스킬 | 경로 | 줄 수 | references |
|------|------|-------|------------|
| deploy-stack | .claude/skills/deploy-stack/SKILL.md | 85 | 2 files |
| ... | | | |

총 {N}개 스킬 생성, 예상 토큰: ~{T}
```

## 규칙

1. **읽기 전용 원칙**: 대상 repo의 기존 파일은 절대 수정하지 않는다 (CLAUDE.md 슬림화는 제안만)
2. **Progressive Disclosure**: SKILL.md 본문 5000 토큰 이내, 나머지는 references/
3. **중복 방지**: 기존 `.claude/skills/`가 있으면 기존 스킬과 중복되지 않게 생성
4. **민감 정보 제외**: .env, credentials, 토큰 등의 실제 값은 스킬에 포함하지 않음
5. **docs/ 참조 우선**: 기존 문서가 있으면 내용을 복사하지 않고 경로를 참조
6. **사용자 확인 필수**: 스킬 선택, 출력 모드, CLAUDE.md 슬림화 모두 사용자 확인 후 진행

## 참조

- `forgeify:new-skill` - 개별 스킬 생성 워크플로우
- `forgeify:new-plugin` - 플러그인 구조 생성 (plugin 모드)
- `forgeify:validate` - 생성 후 검증
- skill-guide 스킬 - SKILL.md 작성 규격
