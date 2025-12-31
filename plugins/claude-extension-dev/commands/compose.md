---
name: compose
description: 여러 플러그인을 분석하여 필요한 부분만 추출하고 새로운 플러그인으로 조립합니다.
argument-hint: "<topic> <plugin1> [plugin2] [plugin3] ..."
allowed-tools: Read, Write, Bash, Glob, Grep
---

# /ced:compose - 플러그인 조립

여러 플러그인에서 필요한 부분을 추출하여 새로운 플러그인으로 조립합니다.

## 사용법

```
/ced:compose <topic> <plugin1> [plugin2] [plugin3] ...
```

- `<topic>`: 새로 만들 플러그인 주제/이름
- `<plugin1,2,3...>`: 소스로 사용할 플러그인 경로들

## 예시

```
/ced:compose my-devops ./plugins/homeserver-gitops ./plugins/ubuntu-dev-setup
```

## 워크플로우

### 1단계: 플러그인 분석

각 소스 플러그인의 구조를 분석합니다:

```
플러그인 A                    플러그인 B
├── commands/                ├── commands/
│   ├── init.md             │   ├── setup.md
│   └── deploy.md           │   └── install.md
├── skills/                  ├── agents/
│   └── k8s-guide/          │   └── dev-setup.md
└── scripts/                 └── scripts/
    └── install-k3s.sh          └── install-zsh.sh
```

각 컴포넌트 목록과 역할을 정리하여 사용자에게 제시합니다:

| 플러그인 | 컴포넌트 | 설명 |
|----------|----------|------|
| homeserver-gitops | commands/init | K3s 초기화 |
| homeserver-gitops | skills/k8s-guide | K8s 가이드 |
| ubuntu-dev-setup | commands/setup | 개발환경 설정 |
| ubuntu-dev-setup | agents/dev-setup | 자연어 트리거 |

### 2단계: 사용자 선택

사용자에게 필요한 컴포넌트를 선택하도록 질문합니다:
- 어떤 commands를 포함할지
- 어떤 skills를 포함할지
- 어떤 agents를 포함할지
- 어떤 scripts를 포함할지

### 3단계: 컴포넌트 조립

선택된 컴포넌트들을 새 플러그인 구조로 조립합니다:

```
plugins/{topic}/
├── .claude-plugin/
│   └── plugin.json          # 새로 생성
├── commands/
│   ├── init.md              # A에서 가져옴
│   └── setup.md             # B에서 가져옴
├── skills/
│   └── k8s-guide/           # A에서 가져옴
├── agents/
│   └── dev-setup.md         # B에서 가져옴
└── scripts/
    ├── install-k3s.sh       # A에서 가져옴
    └── install-zsh.sh       # B에서 가져옴
```

### 4단계: 통합 및 수정

조립 시 필요한 수정 작업:
- **plugin.json**: 새 이름/설명으로 생성
- **경로 수정**: `${CLAUDE_PLUGIN_ROOT}` 경로 유지
- **중복 제거**: 동일 기능 컴포넌트 통합
- **의존성 해결**: 스크립트 간 의존성 확인

### 5단계: 검증 및 완료

생성된 플러그인 검증:
- 구조 확인
- 스크립트 문법 검사 (`bash -n`)
- 누락된 의존성 확인
- `/ced:validate` 실행 권장

## 조립 규칙

1. **이름 충돌**: 같은 이름의 컴포넌트가 있으면 사용자에게 선택 요청
2. **스크립트 의존성**: 스크립트가 다른 스크립트를 참조하면 함께 포함
3. **skill 구조**: 디렉토리 구조 유지 (skill-name/SKILL.md)
4. **agent 예시**: `<example>` 블록은 새 컨텍스트에 맞게 수정 제안

## 주의사항

- 원본 플러그인은 수정하지 않음
- 라이선스 호환성 확인 필요
- 생성 후 테스트 권장
