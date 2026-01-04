---
title: "gemify:triage, gemify:map 스킬 구현"
date: 2026-01-04
---

## Summary

개선 문서 `gemify-add-triage-skill.md`를 기반으로 gemify 플러그인에 triage/map 스킬을 추가했다. Progressive Disclosure 원칙에 따라 map을 별도 스킬로 분리하고, triage가 map을 참조하도록 구성. command → skill 위임 전략 적용.

## Outputs

| 파일 | 변경 |
|------|------|
| `plugins/gemify/skills/triage/SKILL.md` | CREATE - 순방향 inbox 정리 스킬 |
| `plugins/gemify/skills/map/SKILL.md` | CREATE - 클러스터 맵 생성/관리 스킬 |
| `plugins/gemify/commands/triage.md` | CREATE - skill 위임 |
| `plugins/gemify/commands/map.md` | CREATE - skill 위임 |
| `plugins/gemify/.claude-plugin/plugin.json` | MODIFY - 1.10.0 → 1.12.0 |

## Key Decisions

- **map 별도 분리**: 처음엔 triage 내장으로 작성했으나, Progressive Disclosure 원칙에 따라 map을 별도 스킬로 분리
- **command → skill 위임**: command는 진입점만 제공, 실제 로직은 skill에 집중
- **triage → map 참조**: `meta/cluster/current.md` 없으면 map 스킬 호출

## Stashed for Next

- 기존 다른 command들(tidy, inbox 등)도 skill 위임 전략 적용 검토

## Next Actions

- [ ] triage/map 스킬 실제 테스트
- [ ] 기존 command들 skill 위임 전략 일괄 적용
