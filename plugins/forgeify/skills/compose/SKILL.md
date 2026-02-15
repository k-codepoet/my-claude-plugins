---
description: 여러 플러그인을 조립하여 새 플러그인 생성. "플러그인 조립", "compose", "플러그인 합치기", "컴포넌트 추출" 등 요청 시 활성화.
argument-hint: "<topic> <plugin1> [plugin2] ..."
---

# Compose Skill

여러 플러그인에서 필요한 부분을 추출하여 새로운 플러그인으로 조립합니다.

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

```
## 소스 플러그인 분석

### plugin-a
- commands: build.md, run.md
- skills: docker-guide
- scripts: docker-utils.sh

### plugin-b
- commands: deploy.md
- skills: k8s-guide
- agents: setup-wizard.md
```

### 2단계: 사용자 선택
- 포함할 commands, skills, agents, scripts 선택

```
포함할 컴포넌트를 선택하세요:

Commands:
[x] plugin-a/build.md
[x] plugin-a/run.md
[ ] plugin-b/deploy.md

Skills:
[x] plugin-a/docker-guide
[ ] plugin-b/k8s-guide
```

### 3단계: 컴포넌트 조립
- 선택된 컴포넌트들을 새 플러그인 구조로 조립
- `${CLAUDE_PLUGIN_ROOT}` 경로 유지

### 4단계: 통합 및 수정
- 이름 충돌 해결
- 스크립트 의존성 확인
- skill 디렉토리 구조 유지 (skill-name/SKILL.md)

### 5단계: 검증
- validate 스킬로 검증 실행 권장

## 조립 규칙

1. **이름 충돌**: 같은 이름의 컴포넌트가 있으면 사용자에게 선택 요청
2. **스크립트 의존성**: 참조하는 스크립트 함께 포함
3. **원본 보존**: 원본 플러그인은 수정하지 않음
4. **스킬 구조**: `skills/{skill-name}/SKILL.md` 형태 유지

## 결과물 구조

```
plugins/{new-plugin}/
├── .claude-plugin/plugin.json
├── commands/
│   ├── build.md      (from plugin-a)
│   └── run.md        (from plugin-a)
├── skills/
│   └── docker-guide/
│       └── SKILL.md  (from plugin-a)
└── scripts/
    └── docker-utils.sh (from plugin-a)
```

## 예시

```
/forgeify:compose my-devops ./plugins/homeserver-gitops ./plugins/ubuntu-dev-setup
```
