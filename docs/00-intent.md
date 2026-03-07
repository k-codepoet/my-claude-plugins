# Intent - my-claude-plugins 의도 문서

> 이 마켓플레이스는 왜 존재하며, 어디로 가고 있는가.

## 핵심 의도

**"내가 가장 익숙한 도구와 방식으로, AI와 함께 제품을 만들 수 있는 환경"**

Claude Code를 개인 개발 파트너로 삼아, 아이디어 포착부터 프로덕션 배포까지 일관된 파이프라인을 제공한다.

## 설계 원칙

### 1. 단방향 파이프라인 (Knowledge -> Execution)

```
생각 포착     지식 정제       제품 구현       인프라 배포
gemify:inbox → gemify:draft → craftify:poc → terrafy/deploy
     ↑              ↑              ↑
  namify         forgeify      boilerplates
 (이름짓기)    (플러그인 개발)  (검증된 시작점)
```

- **gemify**: 원석(아이디어)을 보석(지식)으로 다듬는 파이프라인
- **craftify**: 지식을 제품으로 만드는 실행 도구 (boilerplates 활용)
- **forgeify**: 이 생태계 자체를 확장하는 메타 도구
- **namify**: 제품/서비스 네이밍
- **terrafy**: 인프라 자동화 (homelab, Docker, Portainer)
- **shellify**: 개발 환경 셋업
- **git-branch-strategy**: 브랜치 전략 선택/강제

### 2. 플러그인 유형 분류

| 유형 | 플러그인 | 특성 |
|------|----------|------|
| **Knowledge** | gemify, forgeify, namify | Skills-only, 컨텍스트 기반 자동 활성화 |
| **Product** | craftify | Skills + Agent, boilerplates 연동 |
| **Infrastructure** | terrafy, shellify, my-devops-tools | Skills + Scripts, 시스템 변경 |
| **Automation** | git-branch-strategy | Skills + Hooks, 워크플로우 강제 |

### 3. my-boilerplates 와의 관계

```
my-claude-plugins (HOW - 어떻게 만들지)
    └── craftify plugin
         └── degit으로 복제 ──→ my-boilerplates (WHAT - 무엇으로 시작하지)
                                  ├── web/ (6종)
                                  ├── cli/ (3종)
                                  ├── native-app/ (2종)
                                  ├── bot/ (3종)
                                  ├── game/ (2종)
                                  └── ai-context/ (1종)
```

- **my-boilerplates**: 검증된 프로젝트 템플릿 모음 (17종, degit 복제용)
- **craftify**: boilerplate 선택 → 복제 → 빌드 확인 → 코드 구현 → 배포까지 안내
- 연결 방식: `npx degit k-codepoet/my-boilerplates/{category}/{name}`

## 사용 시나리오 (End-to-End)

```
1. 아이디어 포착    → /gemify:inbox "이런 앱 만들고 싶어"
2. 아이디어 정제    → /gemify:poc-idea → poc-shape → poc 문서 생성
3. 제품 구현 시작   → /craftify:poc POC.md  (boilerplate 선택 → 복제 → 구현)
4. 배포 설정       → /craftify:deploy setup (Cloudflare Dashboard Git 연동)
5. 반복/개선       → /gemify:retro (사후 기록) → 다음 사이클
```

## 이 문서의 위치

```
docs/
├── 00-intent.md          ← 지금 여기 (왜, 어디로)
├── 01-status.md          ← 현재 상태 (무엇이 되어있고, 무엇이 안 되어있나)
└── 02-roadmap.md         ← 스텝별 진행 계획
```
