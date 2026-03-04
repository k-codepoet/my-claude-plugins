---
description: "선택된 브랜치 전략 스캐폴딩 생성. 'setup', '브랜치 설정', '전략 적용' 요청 시 활성화."
---

# 브랜치 전략 스캐폴딩 설정

> 선택된 브랜치 전략에 따라 프로젝트에 필요한 파일과 설정을 자동 생성한다.

---

## 사전 조건

- Git 저장소가 초기화되어 있어야 함
- 전략이 선택되어 있어야 함 (strategy-select 스킬 또는 직접 지정)

---

## 설정 워크플로우

### 1단계: 전략 확인

사용자에게 브랜치 전략을 확인한다. strategy-select에서 전달받았으면 그대로 사용.

- **downstream-fork**: upstream이 있는 fork 프로젝트
- **vendor-branch**: 외부 라이브러리를 vendor 브랜치로 관리하는 프로젝트

### 2단계: 통합 브랜치 이름 결정

사용자에게 통합 브랜치 이름을 묻는다. 기본값: `my-work`

```
통합 브랜치 이름을 정해주세요 (기본: my-work):
```

### 3단계: 플레이스홀더 값 결정

템플릿에 사용될 값을 설정한다:

| 플레이스홀더 | 값 |
|---|---|
| `{{INTEGRATION_BRANCH}}` | 사용자가 지정한 통합 브랜치 이름 |
| `{{PROTECTED_BRANCHES}}` | `main {{INTEGRATION_BRANCH}}` |

### 4단계: 파일 생성

선택된 전략에 맞는 템플릿을 읽고, 플레이스홀더를 치환하여 프로젝트에 파일을 생성한다.

> 템플릿 위치: 이 플러그인의 `templates/{전략}/` 디렉토리 (플러그인 루트 기준)

#### 4-1. pre-commit 훅 생성

1. 플러그인의 `templates/{전략}/pre-commit.sh` 파일 내용을 읽는다
2. `{{INTEGRATION_BRANCH}}`와 `{{PROTECTED_BRANCHES}}`를 사용자 값으로 치환한다
3. 프로젝트의 `.githooks/pre-commit`에 기록하고 실행 권한을 부여한다

```bash
mkdir -p .githooks
chmod +x .githooks/pre-commit
```

#### 4-2. Git hooks 경로 설정

```bash
git config core.hooksPath .githooks
```

#### 4-3. CLAUDE.md에 브랜치 정책 섹션 추가

`templates/{전략}/claude-md-section.md`의 내용을 CLAUDE.md 끝에 추가한다.
플레이스홀더를 치환한 후 추가.

- CLAUDE.md가 없으면 새로 생성
- 이미 `브랜치 정책` 섹션이 있으면 교체

#### 4-4. branching 스킬 생성

```bash
mkdir -p .claude/skills/branching
cp templates/{전략}/branching-skill.md .claude/skills/branching/SKILL.md
# 플레이스홀더 치환
```

#### 4-5. 설정 파일 생성

`.git-branch-strategy.json` 파일을 프로젝트 루트에 생성:

```json
{
  "strategy": "downstream-fork",
  "integration_branch": "my-work",
  "protected_branches": ["main", "my-work"]
}
```

> `strategy`와 `integration_branch`는 사용자 선택에 따라 변경된다.

### 5단계: 통합 브랜치 생성

통합 브랜치가 아직 없으면 생성한다:

```bash
# 브랜치 존재 여부 확인
if ! git rev-parse --verify {{INTEGRATION_BRANCH}} >/dev/null 2>&1; then
  git branch {{INTEGRATION_BRANCH}}
  echo "브랜치 '{{INTEGRATION_BRANCH}}'를 생성했습니다."
fi
```

---

## 완료 메시지

설정 완료 후 생성된 파일 목록과 다음 단계를 안내한다:

```
브랜치 전략 설정 완료!

생성된 파일:
  - .githooks/pre-commit (브랜치 보호 훅)
  - .claude/skills/branching/SKILL.md (브랜치 정책 스킬)
  - .git-branch-strategy.json (전략 설정)
  - CLAUDE.md에 브랜치 정책 섹션 추가

설정:
  - git core.hooksPath → .githooks
  - 보호 브랜치: main, {통합 브랜치}
  - 작업 흐름: feat/* → {통합 브랜치} → main

다음 단계:
  - 변경사항을 커밋하세요
  - 팀원에게 git config core.hooksPath .githooks 실행을 안내하세요
```
