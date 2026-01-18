# Knowledge Pipeline

> Turn your thoughts into gems.

Gemify를 사용한 개인 지식 파이프라인입니다.

---

## 핵심 개념

```
inbox → draft → library → view
  │       │        │        │
  │       │        │        └─→ vision (방향, 모든 것이 향하는 곳)
  │       │        │
정제되지  다듬기   밀도 있는   흩어진 지식에
않은 생각        지식/재료   의미 부여
```

원석이 **탐색 → 연마 → 응축**되어 밀도 있는 지식이 됩니다.

---

## 구조

```
.
├── visions/            # 비전 (지향점, 평가 기준)
├── inbox/
│   ├── thoughts/       # 내 생각 (원석)
│   └── materials/      # 외부 재료 (기사, 문서, 대화 등)
├── drafts/             # 다듬는 중인 아이디어
├── library/            # 완성된 지식 (type별 분류)
│   ├── principles/     # 왜 이렇게 해야 하는가?
│   ├── decisions/      # 무엇을 선택했고 왜?
│   ├── insights/       # 무엇을 알게 됐는가?
│   ├── how-tos/        # 어떻게 하는가?
│   ├── specs/          # 정확히 무엇인가?
│   └── workflows/      # 어떤 순서로 진행하는가?
├── views/              # 서사가 있는 렌더링
└── sessions/           # 세션 리포트
```

---

## 명령어

| 명령어 | 설명 | 저장 위치 |
|--------|------|----------|
| `/gemify:inbox` | 내 생각 포착 | inbox/thoughts/ |
| `/gemify:import` | 외부 재료 가져오기 | inbox/materials/ |
| `/gemify:draft` | 원석 다듬기 (대화로 확장) | drafts/ |
| `/gemify:library` | 보석 정리 (library로) | library/ |
| `/gemify:view` | library를 목적별로 조합 | views/ |

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
