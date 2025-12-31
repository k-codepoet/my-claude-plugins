# Claude Extension Dev

Claude Code 확장 개발을 위한 **한국어 가이드** 플러그인입니다.

## 개요

이 플러그인은 Claude Code의 확장 시스템(Skills, Commands, Agents, Hooks, Plugins, Marketplace) 개발 방법을 스킬 형태로 제공합니다. Claude가 대화 컨텍스트에 따라 관련 스킬을 자동으로 활성화합니다.

## 설치

```bash
# 마켓플레이스 추가
/plugin marketplace add k-codepoet/my-claude-plugins

# 플러그인 설치
/plugin install ced@k-codepoet-plugins
```

## 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/ced:help` | 도움말 표시 |
| `/ced:howto` | 가능한 가이드 주제 목록 |
| `/ced:howto <topic>` | 특정 주제 가이드 표시 |
| `/ced:create <path> <topic>` | 경로 내용 기반 플러그인 생성 |
| `/ced:validate [path]` | 가이드라인 준수 검증 |
| `/ced:update [path]` | 최신 가이드라인으로 갱신 |

**가능한 주제**: `plugin`, `command`, `agent`, `skill`, `hook`, `marketplace`, `workflow`

## 사용 방법

**명시적 호출**:
```bash
/ced:howto plugin    # 플러그인 구조, plugin.json 작성법
/ced:howto agent     # 서브에이전트 정의, frontmatter 필드
/ced:howto skill     # SKILL.md 작성법, Agent Skills 표준
```

**자동 활성화**: 대화 컨텍스트에 따라 Claude가 관련 스킬 자동 로드
```
"플러그인 만드는 방법 알려줘"
"agent 파일 어떻게 작성해?"
"hook 이벤트 종류가 뭐야?"
```

## 참고 자료

- [Agent Skills 표준](https://agentskills.io)
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
