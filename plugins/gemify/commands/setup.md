---
description: 지정된 경로에 Gemify 지식 파이프라인 구조를 생성합니다. 기본은 빈 구조이며, --examples 옵션으로 예제를 포함할 수 있습니다.
argument-hint: "[path] [--examples]"
allowed-tools: Read, Write, Bash, Glob
---

# /gemify:setup - 지식 파이프라인 구조 생성

지정된 경로에 Gemify 지식 파이프라인 구조를 생성합니다.

## 사용법

```bash
/gemify:setup                      # 현재 디렉토리에 빈 구조 생성
/gemify:setup ./my-knowledge       # 지정 경로에 빈 구조 생성
/gemify:setup --examples           # 현재 디렉토리에 예제 포함 구조 생성
/gemify:setup ./my-knowledge --examples  # 지정 경로에 예제 포함 구조 생성
```

## 옵션

| 옵션 | 설명 |
|------|------|
| `[path]` | 생성할 경로 (기본: 현재 디렉토리) |
| `--examples` | 예제 파일 포함 |

## 생성되는 구조

```
{path}/
├── CLAUDE.md           # Claude Code 설정
├── README.md           # 프로젝트 설명
├── inbox/
│   ├── thoughts/       # 내 생각 (원석)
│   │   └── _template.md
│   └── materials/      # 외부 재료
│       └── _template.md
├── drafts/             # 다듬는 중
│   ├── _template.md
│   └── .history/       # 스냅샷 저장
├── library/            # 완성된 지식
│   ├── _template.md
│   ├── principles/     # 근본 원칙, 철학
│   ├── decisions/      # 의사결정 기록 (ADR)
│   ├── insights/       # 발견, 깨달음
│   ├── how-tos/        # 방법론, 절차
│   ├── specs/          # 명세, 스펙
│   └── workflows/      # input→output 파이프라인
├── views/              # 주제별 조합
│   └── by-subject/
│       └── _template.md
└── sessions/           # 세션 리포트
```

## 동작

### 1단계: 인자 파싱

- `$ARGUMENTS`에서 경로와 `--examples` 옵션 분리
- 경로가 없으면 현재 디렉토리 사용

### 2단계: 경로 확인

- 지정된 경로가 존재하는지 확인
- 이미 gemify 구조가 있는지 확인 (inbox/, drafts/, library/ 존재 여부)
- 기존 구조가 있으면 사용자에게 경고하고 덮어쓸지 확인

### 3단계: 구조 생성

`--examples` 옵션에 따라 적절한 assets 복사:

```bash
# 빈 구조 (기본)
cp -r ${CLAUDE_PLUGIN_ROOT}/assets/empty/* {path}/

# 예제 포함
cp -r ${CLAUDE_PLUGIN_ROOT}/assets/examples/* {path}/
```

### 4단계: 완료 안내

생성 완료 후 다음 안내:

```
Gemify 구조가 생성되었습니다!

시작하기:
1. /gemify:inbox 으로 첫 번째 생각 포착
2. /gemify:draft 로 대화하며 다듬기
3. /gemify:library 로 완성된 지식 정리

도움말: /gemify:help
```

## 예제

### 빈 구조로 시작

```bash
/gemify:setup ~/my-knowledge
```

→ `~/my-knowledge/` 에 빈 구조 생성

### 예제와 함께 시작

```bash
/gemify:setup ~/my-knowledge --examples
```

→ 예제 파일이 포함된 구조 생성 (학습용)

## 주의사항

- 기존 파일이 있으면 덮어쓰기 전 확인 필요
- CLAUDE.md가 이미 있으면 gemify 섹션만 추가할지 물어봄
- git 저장소가 아니면 `git init` 권장 안내
