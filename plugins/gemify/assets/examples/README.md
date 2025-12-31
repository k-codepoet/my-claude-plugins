# Knowledge Pipeline

> Turn your thoughts into gems.

Gemify를 사용한 개인 지식 파이프라인입니다.

---

## 핵심 개념

```
/gemify:inbox → /gemify:draft → /gemify:library
    inbox/         drafts/         library/
```

원석이 **탐색 → 연마 → 응축**되어 밀도 있는 지식이 됩니다.

---

## 구조

```
.
├── inbox/
│   ├── thoughts/       # 내 생각 (원석)
│   └── materials/      # 외부 재료 (기사, 문서, 대화 등)
├── drafts/             # 다듬는 중인 아이디어
└── library/            # 완성된 지식 (domain별 분류)
    ├── product/        # 무엇을 만들 것인가?
    ├── engineering/    # 어떻게 만들 것인가?
    ├── operations/     # 어떻게 돌릴 것인가?
    ├── growth/         # 어떻게 알릴 것인가?
    ├── business/       # 어떻게 유지할 것인가?
    └── ai-automation/  # 어떻게 위임할 것인가?
```

---

## 명령어

| 명령어 | 설명 | 저장 위치 |
|--------|------|----------|
| `/gemify:inbox` | 내 생각 포착 | inbox/thoughts/ |
| `/gemify:import` | 외부 재료 가져오기 | inbox/materials/ |
| `/gemify:draft` | 원석 다듬기 (대화로 확장) | drafts/ |
| `/gemify:library` | 보석 정리 (library로) | library/ |

---

## 시작하기

1. gemify 플러그인이 설치되어 있는지 확인
2. `/gemify:inbox 첫 번째 생각` 으로 생각 포착
3. `/gemify:draft` 로 대화하며 다듬기
4. 완성되면 `/gemify:library` 로 정리

---

## 더 알아보기

- `/gemify:help` - 도움말
- `/gemify:howto` - 상세 가이드
