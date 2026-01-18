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
| 주제 | 설명 | 예시 |
|------|------|------|
| `inbox` | 생각 포착 | `/gemify:inbox 이런 생각이 들었어` |
| `import` | 외부 재료 가져오기 | `/gemify:import https://example.com/article` |
| `sidebar` | 본 작업 중 떠오른 것 빼두기 | `/gemify:sidebar` |
| `draft` | 원석 다듬기 (facet/polish 모드) | `/gemify:draft drafts/my-idea.md` |
| `library` | 보석 정리 (type 분류) | `/gemify:library drafts/my-idea.md` |
| `view` | 주제별 지식 조합 | `/gemify:view claude-plugins` |
| `retro` | 완료 작업 역방향 기록 | `/gemify:retro 방금 만든 기능 기록해줘` |
| `triage` | inbox 정리 + 우선순위 판단 | `/gemify:triage` |
| `map` | 지식 클러스터 맵 생성 | `/gemify:map` |
| `tidy` | 문서 점진적 정리 (역방향 검증) | `/gemify:tidy` |

### 비전 관리
| 주제 | 설명 | 예시 |
|------|------|------|
| `vision` | 비전 생성/조회 | `/gemify:vision my-project` |
| `vision-review` | 비전 대비 현재 상태 평가 | `/gemify:vision-review my-project` |

### 문제 해결
| 주제 | 설명 | 예시 |
|------|------|------|
| `troubleshoot` | 버그/문제 분석 및 가설 도출 | `/gemify:troubleshoot` |
| `bugfix` | 버그 수정 문서 생성 (2-track) | `/gemify:bugfix 로그인 안됨` |
| `improve-plugin` | 플러그인 개선 문서 생성 | `/gemify:improve-plugin forgeify` |
| `poc` | PoC 개발 문서 생성 | `/gemify:poc 새 아이디어` |

### 세션/설정
| 주제 | 설명 | 예시 |
|------|------|------|
| `wrapup` | 세션 마무리 (HITL 체크 + 리포트) | `/gemify:wrapup` |
| `setup` | Gemify 구조 초기화 | `/gemify:setup` |
| `sync` | remote와 동기화 | `/gemify:sync push` |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.
   - `inbox` → inbox 스킬
   - `import` → import 스킬
   - `sidebar` → sidebar 스킬
   - `draft` → draft 스킬
   - `library` → library 스킬
   - `view` → view 스킬
   - `retro` → retro 스킬
   - `triage` → triage 스킬
   - `map` → map 스킬
   - `tidy` → tidy 스킬
   - `vision` → vision 스킬
   - `vision-review` → vision-review 스킬
   - `troubleshoot` → troubleshoot 스킬
   - `bugfix` → bugfix 스킬
   - `improve-plugin` → improve-plugin 스킬
   - `poc` → poc 스킬
   - `wrapup` → wrapup 스킬
   - `setup` → scope 스킬 (setup 안내)
   - `sync` → sync 스킬

3. **알 수 없는 주제**: 가능한 주제 목록을 보여주고 올바른 주제를 선택하도록 안내합니다.

## 파이프라인 개요

```
inbox/thoughts/   ← /gemify:inbox (내 생각)
inbox/materials/  ← /gemify:import (외부 재료)
       ↓
drafts/           ← /gemify:draft (다듬기)
       ↓
library/          ← /gemify:library (정리)
       ↓
views/            ← /gemify:view (조합)
```

## Library Type 분류

| Type | 핵심 질문 |
|------|----------|
| principle | 왜 이렇게 해야 하는가? |
| decision | 무엇을 선택했고 왜? |
| insight | 무엇을 알게 됐는가? |
| how-to | 어떻게 하는가? |
| spec | 정확히 무엇인가? |
| workflow | 어떤 순서로 진행하는가? |
