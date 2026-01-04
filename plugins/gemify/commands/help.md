---
description: gemify 플러그인 도움말을 표시합니다
---

# Gemify 도움말

> Turn your thoughts into gems.

원석(생각)을 다듬어 보석(지식)으로 변환하는 개인 지식 파이프라인입니다.

## 파이프라인 흐름

```
/gemify:inbox → /gemify:draft → /gemify:library
    inbox/         drafts/         library/
```

## 사용 가능한 커맨드

### 가이드 조회
| 커맨드 | 설명 |
|--------|------|
| `/gemify:help` | 이 도움말 표시 |
| `/gemify:howto` | 가능한 가이드 주제 목록 표시 |
| `/gemify:howto <topic>` | 특정 주제 가이드 표시 |

**가능한 주제**: `inbox`, `import`, `sidebar`, `draft`, `library`, `view`, `retro`, `tidy`, `wrapup`, `improve-plugin`

### 지식 파이프라인
| 커맨드 | 설명 | 저장 위치 |
|--------|------|----------|
| `/gemify:inbox [내용]` | 내 생각 포착 | inbox/thoughts/ |
| `/gemify:import [URL/내용]` | 외부 재료 가져오기 | inbox/materials/ |
| `/gemify:sidebar` | 본 작업 중 떠오른 것을 옆에 빼두기 | inbox/ |
| `/gemify:draft [파일/아이디어]` | 원석 다듬기 (대화로 확장) | drafts/ |
| `/gemify:library [파일]` | 보석 정리 (library로) | library/ |
| `/gemify:view [subject]` | 주제별 지식 조합 | views/by-subject/ |
| `/gemify:retro [내용]` | 완료 작업 역방향 기록 | library/ |
| `/gemify:tidy` | 문서 점진적 정리 (역방향 검증) | - |

### 플러그인 개선
| 커맨드 | 설명 | 저장 위치 |
|--------|------|----------|
| `/gemify:improve-plugin [플러그인명]` | 개선 문서 생성 | library/engineering/plugin-improvements/ |

### 세션/설정 관리
| 커맨드 | 설명 | 저장 위치 |
|--------|------|----------|
| `/gemify:wrapup` | 세션 마무리 (HITL 체크 + 리포트) | sessions/ |
| `/gemify:setup [경로]` | ground-truth 구조 생성 | 지정 경로 |

## 사용 예시

```bash
# 생각 포착
/gemify:inbox 이런 생각이 들었어

# 외부 재료 가져오기
/gemify:import https://example.com/article

# 본 작업 중 떠오른 것을 옆에 빼두기
/gemify:sidebar

# 원석 다듬기
/gemify:draft "새로운 아이디어"
/gemify:draft drafts/my-idea.md

# 보석 정리
/gemify:library drafts/my-idea.md

# 주제별 조합
/gemify:view claude-plugins

# 사후 기록
/gemify:retro 방금 만든 기능 기록해줘

# 문서 정리 (역방향 검증)
/gemify:tidy

# 플러그인 개선 문서 생성
/gemify:improve-plugin forgeify

# ground-truth 구조 생성
/gemify:setup ./my-project

# 세션 마무리
/gemify:wrapup
```

## 6대 Domain (library 분류)

| Domain | 핵심 질문 |
|--------|----------|
| product | 무엇을 만들 것인가? |
| engineering | 어떻게 만들 것인가? |
| operations | 어떻게 돌릴 것인가? |
| growth | 어떻게 알릴 것인가? |
| business | 어떻게 유지할 것인가? |
| ai-automation | 어떻게 위임할 것인가? |

## 더 알아보기

`/gemify:howto <topic>`으로 각 단계의 상세 가이드를 확인하세요.
