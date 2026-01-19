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

### 생성 (new-*)
| 주제 | 설명 | 예시 |
|------|------|------|
| `new` | 메타도구 생성 라우터 | `/forgeify:new plugin my-plugin` |
| `new-plugin` | 플러그인 전체 생성 | `/forgeify:new-plugin my-plugin ./` |
| `new-skill` | 스킬 생성 | `/forgeify:new-skill my-skill ./plugin` |
| `new-command` | 커맨드 생성 | `/forgeify:new-command deploy ./plugin` |
| `new-agent` | 에이전트 생성 | `/forgeify:new-agent reviewer ./plugin` |
| `new-hook` | 훅 생성 | `/forgeify:new-hook PreToolUse ./plugin` |

### 개선 (improve-*)
| 주제 | 설명 | 예시 |
|------|------|------|
| `improve` | 메타도구 개선 라우터 | `/forgeify:improve plugin my-plugin` |
| `improve-plugin` | 플러그인 개선 | `/forgeify:improve-plugin my-plugin ./doc.md` |
| `improve-skill` | 스킬 개선 | `/forgeify:improve-skill my-skill ./doc.md` |
| `improve-command` | 커맨드 개선 | `/forgeify:improve-command deploy ./doc.md` |
| `improve-agent` | 에이전트 개선 | `/forgeify:improve-agent reviewer ./doc.md` |
| `improve-hook` | 훅 개선 | `/forgeify:improve-hook PreToolUse ./doc.md` |

### 기타
| 주제 | 설명 | 예시 |
|------|------|------|
| `compose` | 여러 플러그인 조립 | `/forgeify:compose gemify forgeify` |
| `validate` | 가이드라인 검증 | `/forgeify:validate plugins/my-plugin` |
| `align` | 공식문서/레퍼런스 기반 정렬 | `/forgeify:align plugin-guide` |
| `bugfix` | 버그 수정 실행 | `/forgeify:bugfix` |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.

   **개발 가이드**:
   - `plugin` → plugin-guide 스킬
   - `command` → command-guide 스킬
   - `skill` → skill-guide 스킬
   - `agent` → agent-guide 스킬
   - `hook` → hook-guide 스킬
   - `marketplace` → marketplace-guide 스킬
   - `workflow` → workflow-guide 스킬

   **생성 (new-*)**:
   - `new` → new 라우터 안내
   - `new-plugin` → new-plugin 스킬
   - `new-skill` → new-skill 스킬
   - `new-command` → new-command 스킬
   - `new-agent` → new-agent 스킬
   - `new-hook` → new-hook 스킬

   **개선 (improve-*)**:
   - `improve` → improve 라우터 안내
   - `improve-plugin` → improve-plugin 스킬
   - `improve-skill` → improve-skill 스킬
   - `improve-command` → improve-command 스킬
   - `improve-agent` → improve-agent 스킬
   - `improve-hook` → improve-hook 스킬

   **기타**:
   - `compose` → compose 스킬
   - `validate` → validate 스킬
   - `align` → align 스킬
   - `bugfix` → bugfix 스킬

3. **알 수 없는 주제**: 가능한 주제 목록을 보여주고 올바른 주제를 선택하도록 안내합니다.

## 메타도구 개발 흐름

```
gemify:poc         → POC.md 생성 (아이디어 → 문서, 메타도구 타입 결정)
     ↓
forgeify:new-*     → 메타도구 생성 (문서 → 코드)
     ↓
forgeify:validate  → 가이드라인 검증
     ↓
forgeify:align     → 공식문서 기준 정렬 (필요시)
```
