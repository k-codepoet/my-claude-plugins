---
name: poc
description: POC.md 기반 플러그인 구현. gemify:poc이 생성한 문서를 읽고 플러그인 구조 설계 → 생성 → 검증.
---

# PoC Skill

POC.md를 읽고 **Claude Code 플러그인을 구현**합니다.

## 전제 조건

- 현재 디렉토리에 `POC.md` 존재 (gemify:poc이 생성)
- POC.md 필수 섹션: Why, Hypothesis, What, Acceptance Criteria

## 워크플로우 (6단계)

### 1. POC.md 읽기

- 있으면 → 내용 분석
- 없으면 → 에러 (`references/error-handling.md` 참조)

### 2. 문서 분석

파악할 내용:
- **product**: 플러그인명 (frontmatter)
- **hypothesis**: 검증하려는 가설 (frontmatter)
- **Why/What**: 배경, 핵심 기능
- **Acceptance Criteria**: 가설 검증 기준 (체크리스트)

### 3. 플러그인 구조 설계 (대화)

사용자와 대화로 확인:

```
POC.md를 분석했습니다.

플러그인 구조를 설계합니다:

플러그인명: {product}

Commands (슬래시 커맨드):
- /{product}:help - 도움말

Skills (자동 활성화 지식):
- {skill-name} - {description}

Agents (자연어 트리거):
- (선택) {agent-name} - {trigger condition}

이대로 진행할까요?
```

상세 구조는 `references/plugin-structure.md` 참조.

### 4. 플러그인 생성

#### 4-1. 마켓플레이스 경로 확인

```
플러그인을 어디에 생성할까요?

현재 경로: {cwd}

1. 현재 경로가 마켓플레이스인 경우 → plugins/{product}/ 생성
2. 마켓플레이스 경로 직접 입력
```

#### 4-2. 구조 생성

```
{marketplace}/plugins/{product}/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── *.md
├── skills/
│   └── {skill-name}/
│       └── SKILL.md
└── agents/ (선택)
    └── *.md
```

생성 규칙:
- plugin.json의 `name`은 kebab-case
- skills는 `skills/{skill-name}/SKILL.md` 구조
- agents는 개별 .md 파일 (디렉토리 불가)

### 5. 마켓플레이스 등록

marketplace.json에 자동 추가 (이미 등록되어 있으면 스킵)

### 6. 검증

`/forgeify:validate` 자동 호출:
- plugin.json 스키마 검증
- 참조 파일 존재 확인
- 오류 발생 시 자동 수정 시도

### 7. 가설 검증 확인

구현 완료 후:
- AC 체크리스트 모두 통과했는지 확인
- **hypothesis가 검증되었는지** 사용자에게 확인
- POC.md의 AC 항목에 체크 표시 업데이트

## 규칙

- **How는 forgeify가 판단**: gemify는 Why/What만 전달
- **validate 통과 필수**: 생성 후 반드시 검증
- **가설 검증 기반 완료**: AC = 가설 검증 기준, 모든 AC 통과 = 가설 검증 성공

## References

상세 정보는 `references/` 참조:
- `plugin-structure.md` - 플러그인 구조 상세
- `error-handling.md` - 에러 처리
