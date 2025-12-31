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
| `/ced:plugin-guide` | 플러그인 구조, plugin.json 작성법 |
| `/ced:command-guide` | 슬래시 커맨드 작성법 |
| `/ced:agent-guide` | 서브에이전트 정의 및 활용법 |
| `/ced:skill-guide` | SKILL.md 작성법, Agent Skills 표준 |
| `/ced:hook-guide` | 이벤트 기반 훅 작성법 |
| `/ced:marketplace-guide` | 마켓플레이스 구축 및 배포 |
| `/ced:workflow-guide` | 실전 개발 워크플로우 예시 |

### 플러그인 관리
| 커맨드 | 설명 |
|--------|------|
| `/ced:validate [path]` | 가이드라인 준수 검증 및 리팩토링 |
| `/ced:update [path]` | 최신 가이드라인으로 내용 갱신 |

## 사용 방법

**명시적 호출**: 슬래시 커맨드로 직접 호출
```
/ced:plugin-guide
/ced:agent-guide
```

**자동 활성화**: 대화 컨텍스트에 따라 Claude가 관련 스킬 자동 로드
```
"플러그인 만드는 방법 알려줘"
"agent 파일 어떻게 작성해?"
```

## 참고 자료

- [Agent Skills 표준](https://agentskills.io)
- [Claude Code Plugins Reference](https://code.claude.com/docs/en/plugins-reference)
