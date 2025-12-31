# Materials 예시

## 예시 1: 웹 기사 (article)

**파일명**: `inbox/materials/2024-12-31-claude-code-plugins.md`

```markdown
---
title: "Claude Code 플러그인 시스템 소개"
date: 2024-12-31
source: "https://docs.anthropic.com/claude-code/plugins"
type: article
status: used
used_in: drafts/plugin-architecture.md
---

# Claude Code 플러그인 시스템

Claude Code는 확장 가능한 플러그인 시스템을 제공합니다...

## 주요 기능

- Skills: 자동 활성화되는 전문 지식
- Commands: 사용자가 직접 호출하는 명령어
- Agents: 자연어 트리거로 활성화되는 워크플로우
...
```

**포인트**:
- source에 원본 URL 기록
- type: article (웹 기사)
- draft에서 사용 후 status=used, used_in에 경로 기록

## 예시 2: 대화 내용 (conversation)

**파일명**: `inbox/materials/2024-12-31-team-brainstorm.md`

```markdown
---
title: "팀 브레인스토밍 - 신규 기능 아이디어"
date: 2024-12-31
source: "Slack #product-ideas"
type: conversation
status: raw
used_in:
---

## 대화 요약

**김철수**: 사용자들이 지식을 체계적으로 정리하기 어려워해
**이영희**: 메모 앱은 많은데 "다듬는" 과정이 없어서 그래
**박민수**: Claude랑 대화하면서 정리하면 어떨까?

## 핵심 인사이트

- 지식 정리의 어려움
- "다듬기" 프로세스의 필요성
- AI 대화를 통한 정제
```

**포인트**:
- source: 대화 출처 명시
- type: conversation
- 대화 내용 구조화하여 저장

## 예시 3: 코드 스니펫 (snippet)

**파일명**: `inbox/materials/2024-12-31-yaml-frontmatter.md`

```markdown
---
title: "YAML Frontmatter 파싱 코드"
date: 2024-12-31
source: "직접 입력"
type: snippet
status: raw
used_in:
---

\`\`\`python
import yaml
import re

def parse_frontmatter(content):
    pattern = r'^---\n(.*?)\n---\n(.*)$'
    match = re.match(pattern, content, re.DOTALL)
    if match:
        return yaml.safe_load(match.group(1)), match.group(2)
    return {}, content
\`\`\`

간단한 YAML frontmatter 파싱 함수. 정규식으로 추출 후 yaml 라이브러리로 파싱.
```

**포인트**:
- source: "직접 입력"
- type: snippet (짧은 코드 조각)
- 코드와 간단한 설명 포함

## 예시 4: 공식 문서 (document)

**파일명**: `inbox/materials/2024-12-31-api-reference.md`

```markdown
---
title: "Anthropic API Messages Endpoint"
date: 2024-12-31
source: "https://docs.anthropic.com/api/messages"
type: document
status: raw
used_in:
---

# Messages API

## Endpoint

POST https://api.anthropic.com/v1/messages

## Request Body

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| model | string | Yes | Model ID (e.g., claude-3-opus) |
| messages | array | Yes | Array of message objects |
| max_tokens | integer | Yes | Maximum tokens to generate |

...
```

**포인트**:
- source: 공식 문서 URL
- type: document
- 원본 구조 최대한 보존
