---
description: Forgeify 사용 가이드. 인자 없이 실행하면 가능한 주제 목록을, 주제를 지정하면 해당 가이드를 표시합니다.
argument-hint: "[topic]"
---

# /forgeify:howto 명령어

사용자가 요청한 주제에 대한 Forgeify 사용 가이드를 제공합니다.

## 사용법

- `/forgeify:howto` - 가능한 주제 목록 표시
- `/forgeify:howto <topic>` - 특정 주제 가이드 표시

## 가능한 주제 (Topics)

### 개발 가이드
| 주제 | 설명 | 예시 |
|------|------|------|
| `plugin` | 플러그인 구조, plugin.json 작성법 | `/forgeify:howto plugin` |
| `command` | 슬래시 커맨드 작성법 | `/forgeify:howto command` |
| `skill` | SKILL.md 작성법, Agent Skills 표준 | `/forgeify:howto skill` |
| `agent` | 서브에이전트 정의 및 활용법 | `/forgeify:howto agent` |
| `hook` | 이벤트 기반 훅 작성법 | `/forgeify:howto hook` |
| `marketplace` | 마켓플레이스 구축 및 배포 | `/forgeify:howto marketplace` |
| `workflow` | 실전 개발 워크플로우 예시 | `/forgeify:howto workflow` |

### 플러그인 작업
| 주제 | 설명 | 예시 |
|------|------|------|
| `poc` | POC.md 기반 플러그인 구현 | `/forgeify:poc` |
| `compose` | 여러 플러그인 조립 | `/forgeify:compose gemify forgeify` |
| `improve-plugin` | 개선 문서 기반 수정 | `/forgeify:improve-plugin path/to/doc.md` |
| `validate` | 가이드라인 검증 | `/forgeify:validate plugins/my-plugin` |
| `update` | 최신 가이드라인 적용 | `/forgeify:update plugins/my-plugin` |
| `bugfix` | 버그 수정 실행 | `/forgeify:bugfix` |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.
   - `plugin` → plugin-guide 스킬
   - `command` → command-guide 스킬
   - `skill` → skill-guide 스킬
   - `agent` → agent-guide 스킬
   - `hook` → hook-guide 스킬
   - `marketplace` → marketplace-guide 스킬
   - `workflow` → workflow-guide 스킬
   - `poc` → poc 스킬
   - `compose` → compose 스킬
   - `improve-plugin` → improve-plugin 스킬
   - `validate` → validate 스킬
   - `update` → update 스킬
   - `bugfix` → bugfix 스킬

3. **알 수 없는 주제**: 가능한 주제 목록을 보여주고 올바른 주제를 선택하도록 안내합니다.

## 플러그인 개발 흐름

```
gemify:poc      → POC.md 생성 (아이디어 → 문서)
     ↓
forgeify:poc    → 플러그인 구현 (문서 → 코드)
     ↓
forgeify:validate → 가이드라인 검증
     ↓
forgeify:update   → 최신화 (필요시)
```
