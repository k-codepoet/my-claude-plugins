---
name: agent-guide
description: Claude Code 서브에이전트 작성법 가이드. Agent 만들기, frontmatter 필드, 내장 Subagent, Best Practices에 대해 질문할 때 사용합니다.
---

# Agents (서브에이전트) 가이드

## 개념

**특정 작업을 처리하기 위한 전문화된 AI 어시스턴트**입니다. 각 subagent는 독립적인 컨텍스트 윈도우에서 작동하며, 고유한 시스템 프롬프트와 도구 권한을 가집니다.

### 주요 이점

- **Context 보존**: 메인 대화가 깔끔하게 유지됨
- **전문화**: 도메인별 최적화된 성능
- **재사용성**: 프로젝트/팀 간 일관된 워크플로우
- **권한 제어**: 도구별 세밀한 권한 관리

## 디렉토리 구조

| 유형 | 경로 | 범위 |
|------|------|------|
| 프로젝트 subagent | `.claude/agents/` | 현재 프로젝트만 |
| 사용자 subagent | `~/.claude/agents/` | 모든 프로젝트 |
| 플러그인 subagent | `plugin-root/agents/` | 플러그인 범위 |

## Agent 파일 작성법

```markdown
---
name: code-reviewer
description: 코드 품질 검토 전문가. 코드 작성 후 PROACTIVELY 사용하세요.
tools: Read, Grep, Glob, Bash
model: sonnet
---

당신은 시니어 코드 리뷰어입니다.

호출되면:
1. `git diff`로 최근 변경사항 확인
2. 수정된 파일에 집중
3. 리뷰 시작

검토 체크리스트:
- 코드 가독성
- 에러 처리
- 보안 (노출된 시크릿)
- 테스트 커버리지
```

## Frontmatter 필드

### 필수 필드

| 필드 | 설명 |
|------|------|
| `name` | 소문자+하이픈 (예: `code-reviewer`) |
| `description` | 언제 사용할지 자연언어로 설명 |

### 선택 필드

| 필드 | 설명 |
|------|------|
| `tools` | 쉼표 구분 도구 목록 (생략시 모든 도구 상속) |
| `model` | `sonnet`, `opus`, `haiku`, `inherit` |
| `color` | 터미널 출력 색상 (예: `green`, `blue`) |
| `permissionMode` | `default`, `acceptEdits`, `bypassPermissions`, `plan` |
| `skills` | 자동 로드할 skill 이름 목록 |

## 내장 Subagent

### General-Purpose
- **모델**: Sonnet
- **도구**: 모든 도구
- **용도**: 복잡한 다단계 작업

### Plan
- **모델**: Sonnet
- **도구**: Read, Glob, Grep, Bash (읽기 전용)
- **용도**: Plan 모드에서 코드베이스 연구

### Explore
- **모델**: Haiku (빠른 응답)
- **도구**: Glob, Grep, Read, Bash (읽기 전용)
- **용도**: 코드베이스 검색, 빠른 탐색

## 관리 명령어

```bash
# 모든 subagent 조회 및 관리
/agents

# 특정 subagent 호출
> code-reviewer subagent를 사용해서 검토해줘
```

## Best Practices

1. **집중된 책임**: 단일, 명확한 목적
2. **상세한 프롬프트**: 구체적 지시사항과 예시 포함
3. **최소 도구 권한**: 필요한 도구만 부여
4. **버전 관리**: 프로젝트 subagent를 VCS에 커밋

## 자동 위임 팁

Claude가 자동으로 subagent를 사용하게 하려면:

```yaml
description: "Use proactively after code changes"
# 또는
description: "MUST BE USED when debugging errors"
```
