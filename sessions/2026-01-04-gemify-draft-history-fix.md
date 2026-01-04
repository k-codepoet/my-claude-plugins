---
date: 2026-01-04
type: session-report
plugin: gemify
version: 1.12.2
tags: [bugfix, feature, draft, history]
---

# gemify draft 히스토리 저장 기능 개선

## Summary

gemify:draft 세션에서 히스토리가 제대로 남지 않는 문제 해결. 개선 문서(`gemify-draft-history-hooks.md`)를 기반으로 hooks.json 추가 및 히스토리 저장 기준 명확화.

## Outputs

| 파일 | 변경 |
|------|------|
| `.claude-plugin/hooks.json` | 신규 생성 - Stop 이벤트 prompt 훅 |
| `skills/draft/SKILL.md` | 히스토리 저장 기준 섹션 추가/수정 |
| `.claude-plugin/plugin.json` | 버전 1.12.0 → 1.12.2 |

## 핵심 변경사항

### 히스토리 저장 시점

1. **최초 대화 시작** - `.history/{slug}/` 폴더 없으면 원본 스냅샷 (00-origin) 자동 생성
2. **pivot 발생** - facet ↔ polish 모드 전환 시 즉시 스냅샷
3. **세션 종료** - turns >= 3 또는 변경 있으면 저장 제안

### Stop 훅 추가

세션 종료 시 gemify:draft 작업이 있었다면 히스토리 저장 필요 여부를 자동 체크하는 prompt 훅 추가.

## Stashed for Next

없음

## Next Actions

- [ ] 실제 draft 세션에서 히스토리 저장 동작 테스트
- [ ] 원본 스냅샷 (00-origin) 파일 형식 예시 추가 검토
