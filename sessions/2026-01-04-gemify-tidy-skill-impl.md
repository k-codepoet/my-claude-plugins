---
title: "gemify:tidy 스킬 구현 및 help/howto 업데이트"
date: 2026-01-04
---

## Summary

개선 문서 `gemify-add-tidy-skill.md`를 기반으로 gemify 플러그인에 tidy 스킬을 추가하고, 오래된 help/howto 문서를 최신 상태로 업데이트했다.

## Outputs

| 파일 | 변경 |
|------|------|
| `plugins/gemify/skills/tidy/SKILL.md` | CREATE - 역방향 검증 스킬 |
| `plugins/gemify/commands/tidy.md` | CREATE - tidy 커맨드 |
| `plugins/gemify/.claude-plugin/plugin.json` | MODIFY - 1.9.1 → 1.10.0 |
| `plugins/gemify/commands/help.md` | MODIFY - 누락 커맨드 추가 |
| `plugins/gemify/commands/howto.md` | MODIFY - 누락 주제 추가 |
| `CLAUDE.md` | MODIFY - Quick Reference에 tidy 추가 |

## Key Decisions

- **tidy 스킬 핵심**: views ↔ artifact 일치 검사, 하나씩 집중(HITL), 점진적 실행
- **help/howto 재구성**: 3개 카테고리 (지식 파이프라인 / Human Documents / 플러그인·설정)

## Stashed for Next

없음

## Next Actions

- [ ] tidy 스킬 실제 테스트 (ground-truth가 있는 프로젝트에서)
- [ ] triage 스킬 구현 (tidy 이후 순방향 정리)
