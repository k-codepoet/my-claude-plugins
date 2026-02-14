---
description: forgeify 플러그인 도움말을 표시합니다
---

# Forgeify 도움말

> Forge your ideas into Claude extensions.

Claude Code 확장(플러그인, 스킬, 에이전트, 훅 등) 개발을 위한 도구입니다.

## 사용 가능한 기능

### 가이드
| 기능 | 설명 |
|------|------|
| `/forgeify:help` | 이 도움말 표시 |
| `/forgeify:howto [topic]` | 사용 가이드 (주제별 사용법과 예시) |

### 생성 (new-*)
| 기능 | 설명 |
|------|------|
| `/forgeify:new <type>` | 메타도구 생성 라우터 |
| `/forgeify:new-plugin` | 플러그인 전체 생성 |
| `/forgeify:new-skill` | 스킬 생성 |
| `/forgeify:new-command` | 커맨드 생성 |
| `/forgeify:new-agent` | 에이전트 생성 |
| `/forgeify:new-hook` | 훅 생성 |

### 개선 (improve-*)
| 기능 | 설명 |
|------|------|
| `/forgeify:improve <type>` | 메타도구 개선 라우터 |
| `/forgeify:improve-plugin` | 플러그인 개선 |
| `/forgeify:improve-skill` | 스킬 개선 |
| `/forgeify:improve-command` | 커맨드 개선 |
| `/forgeify:improve-agent` | 에이전트 개선 |
| `/forgeify:improve-hook` | 훅 개선 |

### 검증 및 정렬
| 기능 | 설명 |
|------|------|
| `/forgeify:validate` | 가이드라인 준수 검증 및 리팩토링 |
| `/forgeify:align` | 공식문서/외부 레퍼런스 기반 정렬 |

### 기타
| 기능 | 설명 |
|------|------|
| `/forgeify:compose` | 여러 플러그인에서 필요한 부분 조립 |
| `/forgeify:harvest` | Git repo에서 워크플로우를 스킬로 변환 |
| `/forgeify:bugfix` | 버그 수정 문서 기반 수정 실행 |

### 가이드 스킬 (자동 활성화)
| 스킬 | 설명 |
|------|------|
| `plugin-guide` | 플러그인 구조, plugin.json 작성법 |
| `skill-guide` | SKILL.md 작성법, Agent Skills 표준 |
| `command-guide` | 슬래시 커맨드 작성법 |
| `agent-guide` | 서브에이전트 정의 및 활용법 |
| `hook-guide` | 이벤트 기반 훅 작성법 |
| `marketplace-guide` | 마켓플레이스 구축 및 배포 |
| `workflow-guide` | 실전 개발 워크플로우 예시 |

## 메타도구 개발 흐름

```
gemify:poc         → POC.md 생성 (아이디어 → 문서, 메타도구 타입 결정)
     ↓
forgeify:new-*     → 메타도구 생성 (문서 → 코드)
     ↓
forgeify:validate  → 가이드라인 검증
     ↓
forgeify:align     → 공식문서 기준 정렬 (필요시)
```

## 더 알아보기

`/forgeify:howto`로 각 기능의 상세 사용법과 예시를 확인하세요.

### 참고 자료
- [Agent Skills 표준](https://agentskills.io)
- [Claude Code Skills](https://code.claude.com/docs/en/skills)
