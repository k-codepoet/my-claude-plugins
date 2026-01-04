---
description: Gemify 사용 가이드. 인자 없이 실행하면 가능한 주제 목록을, 주제를 지정하면 해당 가이드를 표시합니다.
argument-hint: "[topic]"
---

# /gemify:howto 명령어

사용자가 요청한 주제에 대한 Gemify 사용 가이드를 제공합니다.

## 사용법

- `/gemify:howto` - 가능한 주제 목록 표시
- `/gemify:howto <topic>` - 특정 주제 가이드 표시

## 가능한 주제 (Topics)

### 지식 파이프라인
| 주제 | 설명 |
|------|------|
| `inbox` | 생각 포착, inbox/thoughts/ 사용법 |
| `import` | 외부 재료 가져오기, inbox/materials/ 사용법 |
| `sidebar` | 본 작업 중 떠오른 것을 옆에 빼두기 |
| `draft` | 원석 다듬기, facet/polish 모드 |
| `library` | 보석 정리, 6대 domain 분류 |
| `view` | 주제별 지식 조합 |
| `retro` | 완료 작업 역방향 기록 |
| `tidy` | 문서 점진적 정리, 역방향 검증 |
| `wrapup` | 세션 마무리, HITL 체크 + 리포트 생성 |

### Human Documents
| 주제 | 설명 |
|------|------|
| `human-decision` | 의사결정 기록 생성 |
| `human-principle` | 작업 원칙 문서 생성 |
| `human-policy` | 정책 문서 생성 |

### 플러그인/설정
| 주제 | 설명 |
|------|------|
| `improve-plugin` | 플러그인 개선 문서 생성 |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.
   - `inbox` → inbox 스킬 사용
   - `import` → import 스킬 사용
   - `sidebar` → sidebar 스킬 사용
   - `draft` → draft 스킬 사용
   - `library` → library 스킬 사용
   - `view` → view 스킬 사용
   - `retro` → retro 스킬 사용
   - `tidy` → tidy 스킬 사용
   - `wrapup` → wrapup 스킬 사용
   - `human-decision` → human-decision 스킬 사용
   - `human-principle` → human-principle 스킬 사용
   - `human-policy` → human-policy 스킬 사용
   - `improve-plugin` → improve-plugin 스킬 사용

3. **알 수 없는 주제**: 가능한 주제 목록을 보여주고 올바른 주제를 선택하도록 안내합니다.

## 파이프라인 개요

```
inbox/thoughts/   ← /gemify:inbox (내 생각)
inbox/materials/  ← /gemify:import (외부 재료)
       ↓
drafts/           ← /gemify:draft (다듬기)
       ↓
library/          ← /gemify:library (정리)
```

## 상태 흐름

| 폴더 | 상태값 |
|------|--------|
| inbox/ | `raw` → `used` |
| drafts/ | `cutting` → `set` |
