---
date: 2026-01-04
type: session-report
plugin: gemify
version: 1.13.0
tags: [refactor, library, classification]
---

# gemify library Type 기반 분류로 변경

## Summary

library 분류 체계를 6대 domain 기반에서 Type 기반으로 변경. 개선 문서(`gemify-library-type-classification.md`)를 기반으로 작업.

**변경 이유:**
- domain 경계가 겹침 (engineering과 ai-automation 등)
- 복수 domain 해당 시 하나만 선택해야 하는 문제
- 핵심 인사이트: "domain은 views의 lens이지, library의 분류 기준이 아니다"

## Outputs

| 파일 | 변경 |
|------|------|
| `skills/library/SKILL.md` | domain → type + origin 분류로 변경 |
| `skills/library/references/library-format.md` | 스키마 재작성 |
| `skills/library/references/example-library.md` | 예시 재작성 |
| `assets/empty/library/_template.md` | frontmatter 업데이트 |
| `assets/examples/library/_template.md` | frontmatter 업데이트 |
| `assets/examples/library/principles/capture-first.md` | 신규 (operations → principles 이동) |
| `.claude-plugin/plugin.json` | 버전 1.12.2 → 1.13.0 |

## 핵심 변경사항

### 저장 경로

```
# Before
library/{domain}/{slug}.md

# After
library/{type}s/{slug}.md
```

### Frontmatter

```yaml
# Before
domain: product|engineering|operations|growth|business|ai-automation

# After
type: principle|decision|insight|how-to|spec|workflow
origin: original|digested|derived
```

### Type 분류

| Type | 설명 |
|------|------|
| principle | 근본 원칙, 철학 |
| decision | 의사결정 기록 (ADR) |
| insight | 발견, 깨달음 |
| how-to | 방법론, 절차 |
| spec | 명세, 스펙 |
| workflow | input→output 파이프라인 |

### Origin 분류

| Origin | 설명 |
|--------|------|
| original | 내 생각에서 나온 것 |
| digested | 외부 콘텐츠를 소화해서 재구성 |
| derived | 산출물에서 역추출 |

## Stashed for Next

없음

## Next Actions

- [ ] library→views 옮기는 기준 체크 (별도 작업 문서 예정)
- [ ] 기존 library 파일 마이그레이션 (별도 작업)
