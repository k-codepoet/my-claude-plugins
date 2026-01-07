---
description: 플러그인 내용을 최신 가이드라인으로 갱신합니다.
argument-hint: [plugin-path] [--check-only]
---

# /forgeify:update

기존 플러그인의 내용을 최신 Claude Code 가이드라인으로 갱신합니다.

## 사용법

```
/forgeify:update                       # 현재 디렉토리 플러그인 업데이트
/forgeify:update ./plugins/my-plugin   # 특정 플러그인 업데이트
/forgeify:update --check-only          # 변경 필요 사항만 확인 (수정 없음)
```

## 업데이트 대상

| 구성요소 | 주요 갱신 항목 |
|----------|----------------|
| plugin.json | 필드 최신화, agents 경로 형식 |
| commands/*.md | allowed-tools, argument-hint 추가 |
| agents/*.md | model, `<example>` 블록 추가 |
| skills/*/SKILL.md | Progressive Disclosure 적용 |

## 업데이트 프로세스

1. **현재 상태 분석**: 모든 구성요소 스캔
2. **최신 가이드라인 대조**: 각 스킬의 최신 규격 참조
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

## 버전 규칙

- **patch** (x.x.1): 버그 수정, 문서 개선
- **minor** (x.1.0): 새 기능 추가, 하위 호환
- **major** (1.0.0): 호환성 깨지는 변경

상세 업데이트 규칙은 `skills/update/SKILL.md` 참조.
