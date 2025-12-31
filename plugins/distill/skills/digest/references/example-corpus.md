# Corpus 예시

## 예시: 완성된 corpus 파일

**파일명**: `corpus/operations/grow-branch-ripen-mode.md`

```markdown
---
title: "grow 스킬의 branch/ripen 모드"
domain: operations
---

## Context

/distill:grow 대화 시 탐색 방식을 명시적으로 구분하여 효율적인 지식 확장이 가능하도록 함. seed → grow → digest 흐름과 일관된 식물 메타포 유지.

## Content

### 두 가지 모드

\`\`\`
/distill:grow
├── branch - 가지치기, 넓게 뻗기 (BFS)
└── ripen  - 익히기, 응축 (DFS) → digest 준비
\`\`\`

| 모드 | 성격 | 질문 스타일 |
|------|------|------------|
| branch | 넓게 탐색 | "연결되는 건?", "다른 관점에서?" |
| ripen | 깊이 응축 | "왜 중요해?", "핵심만 남기면?" |

### 전환 규칙

- **기본**: branch
- **ripen 트리거**: "익혀봐", "좀 더 익히자", "핵심이 뭐야"

### revision (스냅샷)

방향 전환(pivot) 시 자동 스냅샷:

\`\`\`
revision 증가 조건:
├── branch → 다른 방향 branch
├── branch → ripen 전환
└── ripen → 다른 방향 ripen
\`\`\`

### 히스토리 구조

\`\`\`
growing/
├── {slug}.md              # 현재 상태 (압축)
└── .history/{slug}/
    └── {rev}-{mode}-{date}.md  # 스냅샷
\`\`\`

- 메인 파일: frontmatter \`history\` 배열로 요약
- 스냅샷: 그 시점의 결정사항 + 다음 작업 (바로 작업 가능한 형태)

## Connections

- \`skills/grow/SKILL.md\` - 스킬 구현
- \`skills/grow/references/growing-format.md\` - 파일 형식 상세
```

## 포인트

1. **Context**: 왜 이 지식이 필요한지 (배경)
2. **Content**: 핵심 내용 (실제 지식)
3. **Connections**: 관련 문서 링크 (선택)

## Domain 선택 기준

| Domain | 핵심 질문 | 예시 |
|--------|----------|------|
| product | 무엇을 만들 것인가? | 제품 기획, 기능 정의 |
| engineering | 어떻게 만들 것인가? | 아키텍처, 기술 결정 |
| operations | 어떻게 돌릴 것인가? | 프로세스, 워크플로우 |
| growth | 어떻게 알릴 것인가? | 마케팅, 사용자 획득 |
| business | 어떻게 유지할 것인가? | 수익, 전략 |
| ai-automation | 어떻게 위임할 것인가? | AI 활용, 자동화 |

## 디렉토리 구조

```
corpus/
├── product/
├── engineering/
├── operations/
│   └── grow-branch-ripen-mode.md
├── growth/
├── business/
├── ai-automation/
│   └── execution-first-principle.md
└── _template.md
```
