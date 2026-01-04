# Library 파일 형식

## Frontmatter

```yaml
---
title: {제목}
type: principle | decision | insight | how-to | spec | workflow
origin: original | digested | derived
---
```

## Type 분류

| Type | 설명 | 예시 |
|------|------|------|
| principle | 근본 원칙, 철학 | "Capture First", "한 번에 하나씩" |
| decision | 의사결정 기록 (ADR) | "React 대신 Svelte 선택" |
| insight | 발견, 깨달음 | "domain은 views의 lens다" |
| how-to | 방법론, 절차 | "PR 리뷰 프로세스" |
| spec | 명세, 스펙 | "API 응답 포맷" |
| workflow | input→output 파이프라인 | "gemify→forgeify 연계 흐름" |

**workflows vs how-tos:**
- **how-to**: 단일 작업의 방법론/절차
- **workflow**: 여러 단계/도구를 연결한 파이프라인

## Origin 분류

| Origin | 설명 |
|--------|------|
| original | 내 생각에서 나온 것 |
| digested | 외부 콘텐츠를 소화해서 내 방식으로 재구성 |
| derived | 산출물(artifact)에서 역추출한 것 |

## 본문 구조

```markdown
## Context
{왜 이 지식이 필요한지}

## Content
{핵심 내용}

## Connections
{관련 문서 링크}
```
