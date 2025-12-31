# Claude Extension Dev

Claude Code 확장 개발을 위한 **한국어 가이드** 플러그인입니다.

## 개요

이 플러그인은 Claude Code의 확장 시스템(Skills, Commands, Agents, Hooks, Plugins, Marketplace) 개발 방법을 스킬 형태로 제공합니다. Claude가 대화 컨텍스트에 따라 관련 스킬을 자동으로 활성화합니다.

## 설치

```bash
# 마켓플레이스 추가
/plugin marketplace add k-codepoet/my-claude-plugins

# 플러그인 설치
/plugin install claude-extension-dev@k-codepoet-plugins
```

## 포함된 스킬

| 스킬 | 설명 |
|------|------|
| `plugin-guide` | 플러그인 구조, plugin.json 작성법, CLI 명령어 |
| `command-guide` | 슬래시 커맨드 작성법, Skills vs Commands 비교 |
| `agent-guide` | 서브에이전트 정의, frontmatter 필드, 내장 Subagent |
| `skill-guide` | SKILL.md 작성법, Agent Skills 표준, Progressive Disclosure |
| `hook-guide` | 이벤트 기반 훅 작성법, 8가지 이벤트 타입 |
| `marketplace-guide` | 마켓플레이스 구축, marketplace.json 스키마 |
| `workflow-guide` | Skill → Agent → Plugin → Marketplace 실전 워크플로우 |

## 사용 방법

스킬은 Claude가 대화 컨텍스트에 따라 **자동으로 활성화**됩니다.

**예시 질문:**
- "플러그인 만드는 방법 알려줘"
- "agent 파일 어떻게 작성해?"
- "hook 이벤트 종류가 뭐야?"
- "marketplace.json 스키마 알려줘"
- "skill이랑 command 차이가 뭐야?"

## 커맨드

```bash
/claude-extension-dev:help    # 도움말 표시
```

## 참고 자료

- [Agent Skills 표준](https://agentskills.io)
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
