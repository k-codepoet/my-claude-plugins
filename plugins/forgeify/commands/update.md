---
description: 플러그인 내용을 최신 가이드라인으로 갱신합니다. 기존 기능 개선, 최신 규격 반영, 문서 업데이트가 필요할 때 사용합니다.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, WebFetch
argument-hint: [plugin-path] [--check-only]
---

# /forgeify:update - 최신 가이드라인 갱신

기존 플러그인의 내용을 최신 Claude Code 가이드라인으로 갱신합니다.

## 사용법

```
/forgeify:update                       # 현재 디렉토리 플러그인 업데이트
/forgeify:update ./plugins/my-plugin   # 특정 플러그인 업데이트
/forgeify:update --check-only          # 변경 필요 사항만 확인 (수정 없음)
```

## 참조 스킬 (Progressive Disclosure)

각 구성요소의 최신 규격은 해당 스킬을 참조합니다:

| 구성요소 | 참조 스킬 | 주요 갱신 항목 |
|----------|-----------|----------------|
| plugin.json | **plugin-guide** | 필드 최신화, agents 경로 형식 |
| commands/*.md | **command-guide** | allowed-tools, argument-hint 추가 |
| agents/*.md | **agent-guide** | model, `<example>` 블록 추가 |
| skills/*/SKILL.md | **skill-guide** | Progressive Disclosure 적용 |

## 업데이트 영역

### Frontmatter 최신화
- **Commands**: allowed-tools, argument-hint 추가
- **Agents**: model, `<example>` 블록 추가
- **Skills**: description 품질 향상

### 본문 내용 개선
- Description: 무엇을 하는지 + 언제 사용하는지 포함
- Progressive Disclosure: 본문 5000 토큰 이하로 압축

### 구조 현대화
- 네이밍 컨벤션 적용
- `${CLAUDE_PLUGIN_ROOT}` 환경변수 활용

## 업데이트 프로세스

1. **현재 상태 분석**: 모든 구성요소 스캔
2. **최신 가이드라인 대조**: 스킬들의 최신 규격 참조
3. **변경 계획 수립**: 필수/권장/선택 분류
4. **사용자 확인**: 변경 계획 승인 요청
5. **변경 적용**: 승인된 항목만 수정
6. **버전 업데이트**: plugin.json 버전 증가

## 출력 형식

```
## Update Plan: {plugin-name} (v1.0.0 → v1.1.0)

### Breaking Changes (필수)
None

### Enhancements (권장)
1. [commands/help.md] Add argument-hint field
2. [agents/setup.md] Add example blocks

### Nice-to-have (선택)
1. [plugin.json] Add homepage field

Apply updates? [A]ll / [S]elect / [N]one
```

## 주의사항

- 기존 기능이 손상되지 않도록 주의
- 변경 전 git status 확인 권장
