---
name: sync
description: ~/.gemify/ 저장소를 remote와 동기화하고 SSOT 일치 점검을 수행합니다. 인자 없이 실행 시 전체 진단 + 심기 제안.
allowed-tools: Read, Bash, Write, Glob, Grep
argument-hint: "[pull|push|status]"
---

# Sync Skill

현재 도메인의 저장소를 remote와 동기화하고, SSOT 일치 점검을 수행합니다.

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

## 동작

### 인자 없이 실행 (/gemify:sync)

전체 상태 진단을 수행합니다:

```
/gemify:sync 실행
    │
    ├─▶ 1. Remote 동기화 상태
    │       - git fetch 후 local/remote 차이 비교
    │       - 차이 있으면: "pull 또는 push가 필요합니다" 표시
    │
    ├─▶ 2. SSOT 일치 점검
    │       - {domain_path}/principles/ ↔ plugins/gemify/principles/
    │       - {domain_path}/CLAUDE.md ↔ plugins/gemify/assets/*/CLAUDE.md
    │       - 불일치 항목 나열
    │
    └─▶ 3. 수정 제안
            - 불일치 항목별 수정 방법 제안
            - "현재 도메인 내용을 플러그인에 심을까요? (y/n)" 확인
            - y 입력 시: 해당 파일 복사/업데이트
```

### 서브커맨드

| 커맨드 | 동작 |
|--------|------|
| `sync pull` | remote → {domain_path}/ |
| `sync push` | {domain_path}/ → remote |
| `sync status` | remote ↔ local 차이 |
| `sync` (없음) | 전체 진단 + 불일치 수정 제안 |

## 전체 진단 상세

### 1단계: Remote 동기화 상태 확인

```bash
cd {domain_path}  # scope 스킬에서 결정된 경로
git fetch origin
git status -sb
```

출력 해석:
- `## main...origin/main` → 동기화 완료
- `## main...origin/main [ahead N]` → push 필요
- `## main...origin/main [behind N]` → pull 필요
- `## main...origin/main [ahead N, behind M]` → 동기화 필요 (pull 후 push)

### 2단계: SSOT 일치 점검

비교 대상:

| {domain_path}/ | plugins/gemify/ | 설명 |
|----------------|-----------------|------|
| `principles/` | `principles/` | 설계 원칙 문서 |
| `CLAUDE.md` | `assets/*/CLAUDE.md` | 에셋별 CLAUDE.md |

점검 방법:
```bash
# principles/ 비교
diff -rq {domain_path}/principles/ plugins/gemify/principles/

# CLAUDE.md 비교 (핵심 섹션만)
# {domain_path}/CLAUDE.md의 "## 핵심 원칙" 섹션과 assets 비교
```

불일치 시 출력:
```
📊 SSOT 일치 점검 결과

불일치 발견:
  - principles/gemify-philosophy.md: 현재 도메인 쪽이 최신
  - CLAUDE.md → assets/craftify/CLAUDE.md: 핵심 원칙 섹션 불일치

수정 방안:
  1. {domain_path}/principles/ → plugins/gemify/principles/ 복사
  2. {domain_path}/CLAUDE.md 핵심 내용 → assets/ 반영

현재 도메인 내용을 플러그인에 심을까요? (y/n)
```

### 3단계: 심기 (Apply)

사용자가 `y` 입력 시:

```bash
# principles/ 동기화
cp -r {domain_path}/principles/* plugins/gemify/principles/

# 변경된 파일 목록 출력
echo "변경된 파일:"
git status --short plugins/gemify/
```

## 출력 예시

### 모두 정상

```
📊 /gemify:sync 전체 진단

1. Remote 동기화
   ✅ 현재 도메인과 remote가 동기화되어 있습니다.

2. SSOT 일치 점검
   ✅ 현재 도메인과 plugins/gemify/가 일치합니다.

모든 항목이 정상입니다.
```

### 불일치 발견

```
📊 /gemify:sync 전체 진단

1. Remote 동기화
   ⚠️ push가 필요합니다 (2 commits ahead)
   → /gemify:sync push

2. SSOT 일치 점검
   ⚠️ 불일치 발견 (2건)

   - principles/gemify-philosophy.md
     현재 도메인 쪽이 최신 (2026-01-14 vs 2026-01-10)

   - CLAUDE.md 핵심 원칙 섹션
     {domain_path}/CLAUDE.md에서 추가된 내용 있음

현재 도메인 내용을 플러그인에 심을까요? (y/n)
```

## 플러그인 디렉토리 탐색

gemify 플러그인 경로를 찾는 방법:

```bash
# 현재 작업 디렉토리에서 탐색
find . -path "*/plugins/gemify/.claude-plugin/plugin.json" -type f 2>/dev/null | head -1

# 또는 marketplace 기준 탐색
# marketplace.json의 source 필드 참조
```

## 안전 장치

- **절대 ~/.gemify/ 폴더를 삭제하지 않음**
- 심기 전 항상 사용자 확인 필요
- 심기 후 변경된 파일 목록 표시
- git으로 변경사항 추적 가능

## 관련 스킬

- **scope**: 도메인 경로 규칙 및 안전 장치
- **domain**: 도메인 관리 (list, set, add)
- **setup**: gemify 초기 설정
