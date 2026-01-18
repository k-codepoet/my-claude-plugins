---
description: gemify 개선 문서를 읽고 해당 플러그인을 수정합니다. 지식 생산(gemify)과 실행(forgeify) 분리 원칙에 따라 외부 문서 기반으로 플러그인을 개선합니다.
argument-hint: "<plugin-name> <improvement-doc-path>"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Skill
---

# /forgeify:improve-plugin - 개선 문서 기반 플러그인 수정

gemify에서 생성된 개선 문서를 읽고, 해당 내용에 따라 플러그인을 수정합니다.

> **Note**: `~/.gemify/`는 사용자의 지식 저장소(Single Source of Truth)입니다. 모든 개선 문서는 이곳에서 관리됩니다.

## 사용법

```
/forgeify:improve-plugin <plugin-name> <improvement-doc-path>
```

- `<plugin-name>`: 대상 플러그인 이름 (예: `gemify`, `forgeify`)
- `<improvement-doc-path>`: gemify 개선 문서 경로 (예: `~/.gemify/views/by-improvement/gemify-new-feature.md`)

**인자가 부족한 경우 안내:**
```
사용법: /forgeify:improve-plugin <plugin-name> <improvement-doc-path>

예시:
  /forgeify:improve-plugin gemify ~/.gemify/views/by-improvement/gemify-retro-action-proposal.md
```

## 필수: 스킬 호출

**Skill 도구를 사용하여 `improve-plugin` 스킬을 반드시 먼저 호출하라.**

```json
{
  "skill": "forgeify:improve-plugin",
  "args": "<plugin-name> <improvement-doc-path>"
}
```

스킬이 로드되면 해당 워크플로우를 따라 진행한다.

## 워크플로우

1. **개선 문서 파싱**: frontmatter에서 plugin, problem, solution, requirements 추출
2. **대상 플러그인 확인**: plugins/{plugin}/ 탐색
3. **참조 문서 로드**: references/ 폴더가 있으면 추가 참조
4. **개선 계획 수립**: 변경 계획 목록 작성
5. **사용자 확인**: 변경 계획 승인 요청
6. **변경 적용**: 파일 생성/수정, 버전 업데이트
7. **검증**: Skill 도구로 `/forgeify:validate` 호출
8. **CHANGELOG.md 업데이트**: 변경 내역 기록

## 7단계: 검증 (필수)

변경 완료 후 **반드시** Skill 도구를 사용하여 검증합니다:

```json
{
  "skill": "forgeify:validate",
  "args": "{plugin-name}"
}
```

검증 통과 시 8단계로 진행. 실패 시 문제 수정 후 재검증.

## 8단계: CHANGELOG.md 업데이트 (필수)

검증 통과 후 플러그인의 CHANGELOG.md를 업데이트합니다:

```markdown
## [{new-version}] - {YYYY-MM-DD}

### {Added|Changed|Fixed}
- **{변경 제목}** - {간략 설명}
  - {상세 내용}
```

- `improvement_type`에 따라 섹션 결정:
  - `feature` → `### Added`
  - `bugfix` → `### Fixed`
  - `refactor` → `### Changed`
- Keep a Changelog 형식 준수
- 버전은 6단계에서 업데이트한 plugin.json 버전과 일치

## 예시

```
/forgeify:improve-plugin ~/.gemify/views/by-improvement/forgeify-add-validation.md
```

## 개선 문서 위치

gemify:improve-plugin이 생성하는 개선 문서의 위치:

```
~/.gemify/views/by-improvement/{plugin}-{slug}.md
```

## 주의사항

- 자동 실행 없음: 모든 변경은 사용자 확인 후 진행
- 개선 문서 형식이 잘못된 경우 에러 표시
- 대규모 변경 시 git status 확인 권장
