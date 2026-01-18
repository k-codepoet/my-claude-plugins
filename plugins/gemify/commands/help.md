---
description: gemify 플러그인 도움말을 표시합니다
---

# Gemify 도움말

> Turn your thoughts into gems.

원석(생각)을 다듬어 보석(지식)으로 변환하는 개인 지식 파이프라인입니다.

## 파이프라인 흐름

```
/gemify:inbox → /gemify:draft → /gemify:library → /gemify:view
    inbox/         drafts/         library/          views/
```

## 사용 가능한 커맨드

### 가이드
| 커맨드 | 설명 |
|--------|------|
| `/gemify:help` | 이 도움말 표시 |
| `/gemify:howto [topic]` | 사용 가이드 (주제별 사용법과 예시) |

### 지식 파이프라인
| 커맨드 | 설명 |
|--------|------|
| `/gemify:inbox` | 내 생각 포착 → inbox/thoughts/ |
| `/gemify:import` | 외부 재료 가져오기 → inbox/materials/ |
| `/gemify:sidebar` | 본 작업 중 떠오른 것 빼두기 → inbox/ |
| `/gemify:draft` | 원석 다듬기 (대화로 확장) → drafts/ |
| `/gemify:library` | 보석 정리 → library/ |
| `/gemify:view` | 주제별 지식 조합 → views/ |
| `/gemify:retro` | 완료 작업 역방향 기록 → library/ |
| `/gemify:triage` | inbox 정리 + 우선순위 판단 |
| `/gemify:map` | 지식 클러스터 맵 생성 |
| `/gemify:tidy` | 문서 점진적 정리 (역방향 검증) |

### 비전 관리
| 커맨드 | 설명 |
|--------|------|
| `/gemify:vision` | 비전 생성/조회 → visions/ |
| `/gemify:vision-review` | 비전 대비 현재 상태 평가 |

### 문제 해결
| 커맨드 | 설명 |
|--------|------|
| `/gemify:troubleshoot` | 버그/문제 분석 및 가설 도출 |
| `/gemify:bugfix` | 버그 수정 문서 생성 (2-track) |
| `/gemify:improve-plugin` | 플러그인 개선 문서 생성 |
| `/gemify:poc` | PoC 개발 문서 생성 |

### 세션/설정
| 커맨드 | 설명 |
|--------|------|
| `/gemify:wrapup` | 세션 마무리 (HITL 체크 + 리포트) |
| `/gemify:setup` | Gemify 구조 초기화 |
| `/gemify:sync` | remote와 동기화 |

## 더 알아보기

`/gemify:howto`로 각 기능의 상세 사용법과 예시를 확인하세요.
