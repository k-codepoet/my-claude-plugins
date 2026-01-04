---
date: 2026-01-04
slug: plugin-hooks-bugfix
task: forgeify hooks-guide 보강 및 validate 연동
status: completed
---

# 세션 리포트: Plugin Hooks Bugfix

## Summary

forgeify 플러그인의 hooks-guide 문서를 올바른 스키마로 수정하고, validate 스킬에 hooks 검증 로직을 추가했다. 테스트 과정에서 `type: "prompt"` 훅이 플러그인에서 작동하지 않는 Claude Code 제약사항을 발견하여 Known Issues로 문서화했다.

## Outputs

### 수정된 파일

**my-claude-plugins (8cbe worktree):**
- `plugins/forgeify/.claude-plugin/plugin.json` - 버전 1.6.0 → 1.7.1
- `plugins/forgeify/skills/hook-guide/SKILL.md` - 올바른 스키마 + Progressive Disclosure 적용 + Known Issues 추가
- `plugins/forgeify/skills/hook-guide/references/troubleshooting.md` - 신규
- `plugins/forgeify/skills/hook-guide/references/examples.md` - 신규
- `plugins/forgeify/skills/validate/SKILL.md` - hooks 검증 + Progressive Disclosure 검증 추가

**ground-truth (2개 worktree):**
- `library/how-tos/plugin-improvements/forgeify-hooks-guide-enhancement.md` - 올바른 스키마로 수정

### 주요 변경 내용

1. **hooks.json 올바른 포맷 문서화**
   - 플랫 배열 구조 ❌ → 중첩 객체 구조 ✅
   - 이벤트 타입이 객체 키로 사용됨
   - `type`, `command` 필드 필수

2. **Progressive Disclosure 적용**
   - SKILL.md: 860→294 단어로 간결화
   - 상세 예시 → `references/examples.md`
   - 트러블슈팅 → `references/troubleshooting.md`

3. **Known Issues 추가**
   - `type: "prompt"` 훅이 플러그인에서 silently ignored됨
   - GitHub Issue: #13155
   - Workaround: `type: "command"` 사용

## Stashed for Next

- gemify hooks `type: "prompt"` → `type: "command"` 전환 작업 (inbox에 저장됨)

## Next Actions

- [ ] 변경사항 커밋
- [ ] gemify 플러그인 hooks 수정 (별도 태스크)
- [ ] 다른 플러그인에 동일 패턴 적용

## Lessons Learned

- 공식 플러그인 예시로 스키마 검증 필수
- Progressive Disclosure 검증을 validate에 포함해야 함
- 플러그인 hooks는 `type: "command"`만 지원됨 (현재 버전 기준)
