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

| 주제 | 설명 |
|------|------|
| `inbox` | 생각 포착, inbox/thoughts/ 사용법 |
| `import` | 외부 재료 가져오기, inbox/materials/ 사용법 |
| `draft` | 원석 다듬기, facet/polish 모드 |
| `library` | 보석 정리, 6대 domain 분류 |
| `wrapup` | 세션 마무리, HITL 체크 + 리포트 생성 |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.
   - `inbox` → inbox 스킬 사용
   - `import` → import 스킬 사용
   - `draft` → draft 스킬 사용
   - `library` → library 스킬 사용
   - `wrapup` → wrapup 스킬 사용

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
