---
name: help
description: ced (Claude Extension Dev) 플러그인 도움말을 표시합니다
---

# ced (Claude Extension Dev) 도움말

Claude Code 확장(플러그인, 스킬, 에이전트 등) 개발을 위한 한국어 가이드입니다.

## 사용 가능한 커맨드

### 가이드 조회
| 커맨드 | 설명 |
|--------|------|
| `/ced:help` | 이 도움말 표시 |
| `/ced:howto` | 가능한 가이드 주제 목록 표시 |
| `/ced:howto <topic>` | 특정 주제 가이드 표시 |

**가능한 주제**: `plugin`, `command`, `agent`, `skill`, `hook`, `marketplace`, `workflow`

### 플러그인 관리
| 커맨드 | 설명 |
|--------|------|
| `/ced:create <path> <topic>` | 경로의 내용을 기반으로 플러그인 생성 |
| `/ced:validate [path]` | 가이드라인 준수 검증 및 리팩토링 |
| `/ced:update [path]` | 최신 가이드라인으로 내용 갱신 |

## 사용 예시

**명시적 호출**: 슬래시 커맨드로 직접 호출
```
/ced:howto plugin
/ced:howto agent
```

**자동 활성화**: 대화 컨텍스트에 따라 Claude가 관련 스킬 자동 로드
```
"플러그인 만드는 방법 알려줘"
"agent 파일 어떻게 작성해?"
```

## 참고 자료

- [Agent Skills 표준](https://agentskills.io)
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
