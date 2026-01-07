---
description: 지정된 경로의 내용을 기반으로 Claude Code 플러그인을 생성합니다.
argument-hint: "<path> <topic>"
---

# /forgeify:create

지정된 경로의 내용을 기반으로 Claude Code 플러그인을 생성합니다.

## 사용법

```
/forgeify:create <path> <topic>
```

- `<path>`: 플러그인 소스가 될 파일 또는 디렉토리 경로
- `<topic>`: 플러그인 주제/이름 (예: "docker-helper", "git-workflow")

## 워크플로우

1. **소스 분석**: 지정 경로의 파일/디렉토리 내용 분석
2. **구조 설계**: 생성할 컴포넌트 목록 제시
3. **사용자 확인**: 승인 후 진행
4. **플러그인 생성**: 구조 생성
5. **마켓플레이스 등록**: marketplace.json에 추가
6. **검증**: validate 스킬로 검증

## 생성 구조

```
plugins/{plugin-name}/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── *.md
├── skills/
│   └── {skill-name}/
│       └── SKILL.md
├── agents/
│   └── *.md
└── scripts/
    └── *.sh
```

## 소스 → 컴포넌트 매핑

| 소스 특성 | 생성 컴포넌트 |
|-----------|---------------|
| 반복 작업 | Commands |
| 지식/가이드 | Skills |
| 자연어 트리거 | Agents |
| 스크립트 | scripts/ |

## 예시

```
/forgeify:create ~/my-scripts/docker-utils docker-helper
```

결과:
```
plugins/docker-helper/
├── .claude-plugin/plugin.json
├── commands/build.md
├── commands/run.md
├── skills/docker-guide/SKILL.md
└── scripts/docker-utils.sh
```

상세 생성 규칙은 `skills/create/SKILL.md` 참조.
