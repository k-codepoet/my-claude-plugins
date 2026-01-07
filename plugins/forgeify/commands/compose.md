---
description: 여러 플러그인을 분석하여 필요한 부분만 추출하고 새로운 플러그인으로 조립합니다.
argument-hint: "<topic> <plugin1> [plugin2] [plugin3] ..."
---

# /forgeify:compose

여러 플러그인에서 필요한 부분을 추출하여 새로운 플러그인으로 조립합니다.

## 사용법

```
/forgeify:compose <topic> <plugin1> [plugin2] [plugin3] ...
```

- `<topic>`: 새로 만들 플러그인 주제/이름
- `<plugin1,2,3...>`: 소스로 사용할 플러그인 경로들

## 워크플로우

1. **플러그인 분석**: 각 소스 플러그인의 구성요소 목록화
2. **사용자 선택**: 포함할 commands, skills, agents, scripts 선택
3. **컴포넌트 조립**: 선택된 컴포넌트를 새 구조로 조립
4. **통합 및 수정**: 이름 충돌 해결, 의존성 확인
5. **검증**: validate로 검증 실행

## 조립 규칙

| 상황 | 처리 방법 |
|------|-----------|
| 이름 충돌 | 사용자에게 선택 요청 |
| 스크립트 의존성 | 참조하는 스크립트 함께 포함 |
| 원본 플러그인 | 수정하지 않음 |
| 스킬 구조 | `skills/{skill-name}/SKILL.md` 형태 유지 |

## 결과물 구조

```
plugins/{new-plugin}/
├── .claude-plugin/plugin.json
├── commands/
│   └── *.md (선택된 것들)
├── skills/
│   └── {skill-name}/SKILL.md
└── scripts/
    └── *.sh (의존성 포함)
```

## 예시

```
/forgeify:compose my-devops ./plugins/homeserver-gitops ./plugins/ubuntu-dev-setup
```

상세 조립 규칙은 `skills/compose/SKILL.md` 참조.
