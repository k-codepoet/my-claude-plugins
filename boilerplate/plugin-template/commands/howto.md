---
description: {{Plugin Name}} 사용 가이드. 인자 없이 실행하면 가능한 주제 목록을, 주제를 지정하면 해당 가이드를 표시합니다.
argument-hint: "[topic]"
---

# /{{plugin-name}}:howto 명령어

사용자가 요청한 주제에 대한 {{Plugin Name}} 사용 가이드를 제공합니다.

## 사용법

- `/{{plugin-name}}:howto` - 가능한 주제 목록 표시
- `/{{plugin-name}}:howto <topic>` - 특정 주제 가이드 표시

## 가능한 주제 (Topics)

### 핵심 기능
| 주제 | 설명 | 예시 |
|------|------|------|
| `{{topic1}}` | {{설명}} | `/{{plugin-name}}:{{command}} {{args}}` |
| `{{topic2}}` | {{설명}} | `/{{plugin-name}}:{{command}} {{args}}` |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.
   - `{{topic1}}` → {{topic1}} 스킬
   - `{{topic2}}` → {{topic2}} 스킬

3. **알 수 없는 주제**: 가능한 주제 목록을 보여주고 올바른 주제를 선택하도록 안내합니다.
