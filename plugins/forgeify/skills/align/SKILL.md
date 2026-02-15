---
description: 공식문서/외부 레퍼런스 기반으로 가이드 스킬 또는 플러그인 정렬. "정렬", "align", "공식문서 동기화", "최신화" 등 요청 시 활성화.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebFetch
argument-hint: "[target] [--source <url>]"
---

# align Skill

## 개요

Claude 공식문서 또는 외부 레퍼런스를 기준으로 forgeify의 가이드 스킬들을 갱신하고, 플러그인을 재정렬합니다.

## 인자

```
/forgeify:align [target] [--source <url>]

- target: 가이드 이름 또는 플러그인 경로
  - guide: plugin-guide, skill-guide, command-guide, agent-guide, hook-guide
  - plugin: 플러그인 경로
- --source: 공식문서 URL 또는 GitHub 레퍼런스 URL
```

## 워크플로우

### 1단계: 소스 확인

인자 파싱:

| 상황 | 동작 |
|------|------|
| `--source` 있음 | WebFetch로 해당 URL 내용 수집 |
| `--source` 없음 | 소스 선택 질문 |

```
어떤 소스를 기준으로 정렬할까요?

1. Claude 공식문서 (docs.anthropic.com)
2. 외부 URL 입력
3. 로컬 파일 경로

선택:
```

### 2단계: 대상 확인

| 상황 | 동작 |
|------|------|
| `target`이 가이드 이름 | 해당 가이드 스킬 갱신 |
| `target`이 플러그인 경로 | 해당 플러그인 정렬 |
| `target` 없음 | 대상 선택 질문 |

```
무엇을 정렬할까요?

1. 가이드 스킬 (plugin-guide, skill-guide 등)
2. 특정 플러그인

선택:
```

### 3단계: 현재 상태 수집

**가이드 스킬 대상 시:**
- 해당 스킬의 SKILL.md 읽기
- references/ 폴더 내용 확인

**플러그인 대상 시:**
- plugin.json 읽기
- commands/, skills/, agents/, hooks/ 구조 확인

### 4단계: 소스 분석

WebFetch 또는 Read로 소스 내용 수집 후 분석:
- 새로운 필드/기능
- 변경된 규격
- 폐기된 기능

### 5단계: 비교 및 변경 계획

현재 vs 소스 비교하여 변경사항 목록화:

```
## 정렬 계획: {target}

### 소스
{source URL 또는 경로}

### 발견된 차이점

#### 추가 필요 (신규 기능)
1. {새 필드/기능} - {설명}

#### 수정 필요 (규격 변경)
1. {변경된 항목} - {현재} → {변경 후}

#### 제거 필요 (폐기된 기능)
1. {폐기된 항목} - {설명}

### 변경 계획
1. [MODIFY] {파일 경로} - {변경 내용}
2. ...

진행하시겠습니까? [A]ll / [S]elect / [N]one
```

### 6단계: 변경 적용

선택에 따라 변경사항 적용:
- **All**: 모든 변경 적용
- **Select**: 개별 선택
- **None**: 취소

### 7단계: 검증

```
Skill 도구로 forgeify:validate 호출
```

### 8단계: 완료 메시지

```
✅ 정렬 완료

대상: {target}
소스: {source}
변경: {count}개 항목

변경 내역:
- {변경 1}
- {변경 2}
...
```

## 공식문서 URL 참조

| 가이드 | 공식문서 URL |
|--------|-------------|
| plugin-guide | https://docs.anthropic.com/en/docs/claude-code/plugins |
| skill-guide | https://docs.anthropic.com/en/docs/claude-code/skills |
| command-guide | https://docs.anthropic.com/en/docs/claude-code/commands |
| agent-guide | https://docs.anthropic.com/en/docs/claude-code/agents |
| hook-guide | https://docs.anthropic.com/en/docs/claude-code/hooks |

## 규칙

1. **사용자 확인 필수**: 모든 변경은 사용자 승인 후 적용
2. **검증 필수**: 변경 후 반드시 validate 실행
3. **버전 관리**: 가이드 스킬 변경 시 forgeify 버전 업데이트

## 참조

- 기존 update 스킬의 워크플로우 패턴 계승
- 각 *-guide 스킬의 상세 규격 참조
