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

**가능한 주제**: `inbox`, `import`, `draft`, `library`

### 지식 파이프라인
| 커맨드 | 설명 | 저장 위치 |
|--------|------|----------|
| `/gemify:inbox [내용]` | 내 생각 포착 | inbox/thoughts/ |
| `/gemify:import [URL/내용]` | 외부 재료 가져오기 | inbox/materials/ |
| `/gemify:draft [파일/아이디어]` | 원석 다듬기 (대화로 확장) | drafts/ |
| `/gemify:library [파일]` | 보석 정리 (library로) | library/ |

## 사용 예시

```bash
# 생각 포착
/gemify:inbox 이런 생각이 들었어

# 외부 재료 가져오기
/gemify:import https://example.com/article

# 원석 다듬기
/gemify:draft "새로운 아이디어"
/gemify:draft drafts/my-idea.md

# 보석 정리
/gemify:library drafts/my-idea.md
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
