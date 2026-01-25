---
description: Gemify 지식 파이프라인을 설정합니다. 기본은 ~/.gemify/ (user scope)에 생성되며, 새로 초기화하거나 기존 repo를 clone할 수 있습니다.
argument-hint: "[--examples] [--clone <url>]"
allowed-tools: Read, Write, Bash, Glob
---

# /gemify:setup - User Scope 설정

`~/.gemify/`에 Gemify 지식 파이프라인을 설정합니다. 멀티 도메인을 지원합니다.

**반드시 `skills/scope/SKILL.md`와 `skills/domain/SKILL.md` 참조.**

## 사용법

```bash
/gemify:setup                      # 새로 초기화 (interactive)
/gemify:setup --examples           # 예제 포함하여 초기화
/gemify:setup --clone <url>        # 기존 repo clone
```

## 옵션

| 옵션 | 설명 |
|------|------|
| `--examples` | 예제 파일 포함 (학습용) |
| `--clone <url>` | 기존 gemify repo를 clone |

## User Scope 구조 (멀티 도메인)

```
~/.gemify/
├── config.json           # 도메인 설정 (current, domains)
├── builder/              # 기술/서비스개발 도메인
│   ├── inbox/
│   │   ├── thoughts/     # 내 생각 (원석)
│   │   └── materials/    # 외부 재료
│   ├── drafts/           # 다듬는 중
│   ├── library/          # 완성된 지식
│   ├── views/            # 주제별 조합
│   ├── sessions/         # 세션 리포트
│   └── visions/          # 비전
├── leader/               # 리더십 도메인
│   └── (동일 구조)
└── (확장 가능: planner, writer, teacher...)
```

각 도메인은 독립적인 git repo로 관리 가능.

## 동작

### 1단계: ~/.gemify/ 존재 확인

```
~/.gemify/ 존재?
├── 예 → "이미 설정되어 있습니다. /gemify:sync로 동기화하세요." + 종료
└── 아니오 → 2단계로
```

**중요**: 이미 존재하면 절대 덮어쓰지 않음

### 2단계: 설정 방식 결정

`--clone` 옵션 확인:
- `--clone <url>` 있음 → 3단계 (Clone)
- 없음 → 4단계 (Initialize)

### 3단계: Clone (기존 repo 가져오기)

```bash
git clone <url> ~/.gemify
```

clone 완료 후:
```
기존 gemify repo를 가져왔습니다!

동기화: /gemify:sync
도움말: /gemify:help
```

### 4단계: Initialize (새로 초기화)

```bash
# 구조 생성
mkdir -p ~/.gemify
cp -r ${CLAUDE_PLUGIN_ROOT}/assets/empty/* ~/.gemify/
# 또는 --examples 시:
cp -r ${CLAUDE_PLUGIN_ROOT}/assets/examples/* ~/.gemify/

# git 초기화
cd ~/.gemify && git init
git add -A && git commit -m "Initial gemify setup"
```

초기화 완료 후:
```
Gemify가 설정되었습니다! (~/.gemify/)

시작하기:
1. /gemify:inbox 으로 첫 번째 생각 포착
2. /gemify:draft 로 대화하며 다듬기
3. /gemify:library 로 완성된 지식 정리

동기화 설정: /gemify:sync push (remote 추가 후)
도움말: /gemify:help
```

## 예제

### 새로 시작

```bash
/gemify:setup
```

→ `~/.gemify/`에 빈 구조 생성 + git init

### 예제와 함께 시작

```bash
/gemify:setup --examples
```

→ 예제 파일이 포함된 구조 생성 (학습용)

### 기존 repo 가져오기

```bash
/gemify:setup --clone git@github.com:user/my-gemify.git
```

→ 기존 repo를 `~/.gemify/`로 clone

## 안전 장치

- **절대 ~/.gemify/ 폴더를 삭제하지 않음**
- 이미 존재하면 덮어쓰기 없이 중단
- clone 실패 시 원래 상태 유지

## 여러 머신에서 사용하기

1. 첫 번째 머신: `/gemify:setup` → GitHub에 push
2. 두 번째 머신: `/gemify:setup --clone <url>`
3. 동기화: `/gemify:sync pull` / `/gemify:sync push`
