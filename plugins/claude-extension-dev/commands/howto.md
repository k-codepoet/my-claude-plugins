---
name: howto
description: Claude Code 확장 개발 가이드. 인자 없이 실행하면 가능한 주제 목록을, 주제를 지정하면 해당 가이드를 표시합니다.
argument-hint: "[topic]"
---

# /ced:howto 명령어

사용자가 요청한 주제에 대한 Claude Code 확장 개발 가이드를 제공합니다.

## 사용법

- `/ced:howto` - 가능한 주제 목록 표시
- `/ced:howto <topic>` - 특정 주제 가이드 표시

## 가능한 주제 (Topics)

| 주제 | 설명 |
|------|------|
| `plugin` | 플러그인 구조, plugin.json 작성법 |
| `command` | 슬래시 커맨드 작성법 |
| `agent` | 서브에이전트 정의 및 활용법 |
| `skill` | SKILL.md 작성법, Agent Skills 표준 |
| `hook` | 이벤트 기반 훅 작성법 |
| `marketplace` | 마켓플레이스 구축 및 배포 |
| `workflow` | 실전 개발 워크플로우 예시 |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.
   - `plugin` → plugin-guide 스킬 사용
   - `command` → command-guide 스킬 사용
   - `agent` → agent-guide 스킬 사용
   - `skill` → skill-guide 스킬 사용
   - `hook` → hook-guide 스킬 사용
   - `marketplace` → marketplace-guide 스킬 사용
   - `workflow` → workflow-guide 스킬 사용

3. **알 수 없는 주제**: 가능한 주제 목록을 보여주고 올바른 주제를 선택하도록 안내합니다.
