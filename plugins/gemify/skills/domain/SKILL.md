---
name: domain
description: 도메인 관리. 현재 도메인 확인, 목록 조회, 전환, 추가. 세션 시작 시 한 번 설정.
allowed-tools: Read, Write, Bash, Glob, Grep, AskUserQuestion
argument-hint: "[list|set <name>|add <name>]"
---

# Domain Skill

gemify 도메인을 관리합니다. 도메인별로 독립적인 지식 파이프라인을 운영할 수 있습니다.

## 사용법

```
/gemify:domain              # 현재 도메인 확인
/gemify:domain list         # 도메인 목록
/gemify:domain set <name>   # 도메인 전환
/gemify:domain add <name>   # 새 도메인 추가
```

## 명령어

### `/gemify:domain` - 현재 도메인 확인

현재 활성화된 도메인 정보를 표시합니다.

**출력 예시:**
```
현재 도메인: leader
경로: ~/.gemify/leader/
설명: 리더십/의사결정/팀운영
```

### `/gemify:domain list` - 도메인 목록

등록된 모든 도메인을 표시합니다.

**출력 예시:**
```
도메인 목록:

  * builder    ~/.gemify/builder/    기술/서비스개발/아키텍처
    leader     ~/.gemify/leader/     리더십/의사결정/팀운영

(* = 현재 도메인)
```

### `/gemify:domain set <name>` - 도메인 전환

활성 도메인을 변경합니다.

**정책:**
- **세션 시작 시 한 번만 설정** 권장
- 세션 중간 전환은 가능하지만, 혼란 방지를 위해 새 세션 시작 권장
- config.json의 `current` 값을 업데이트

**예시:**
```
/gemify:domain set leader

→ 도메인이 'leader'로 전환되었습니다.
  경로: ~/.gemify/leader/
```

### `/gemify:domain add <name>` - 새 도메인 추가

새 도메인을 생성합니다.

**워크플로우:**
```
/gemify:domain add planner

→ 새 도메인 'planner' 생성

도메인 설명을 입력해주세요:
> 기획/시나리오/스토리

git repo를 연결할까요? (y/n)
> y

git repo URL을 입력해주세요 (Enter: 새로 init):
> git@github.com:user/planner-knowledge.git

→ 도메인 'planner' 생성 완료!
  경로: ~/.gemify/planner/
```

**생성되는 폴더 구조:**
```
~/.gemify/planner/
├── inbox/
│   ├── thoughts/
│   └── materials/
├── drafts/
├── library/
│   ├── principles/
│   ├── decisions/
│   ├── insights/
│   ├── how-tos/
│   ├── specs/
│   └── workflows/
├── views/
│   ├── by-improvement/
│   ├── by-poc/
│   └── ...
├── sessions/
└── visions/
```

## config.json 관리

도메인 정보는 `~/.gemify/config.json`에 저장됩니다.

```json
{
  "version": "1.0",
  "current": "leader",
  "domains": {
    "builder": {
      "path": "~/.gemify/builder",
      "repo": "git@github.com:user/builder-knowledge.git",
      "description": "기술/서비스개발/아키텍처"
    },
    "leader": {
      "path": "~/.gemify/leader",
      "repo": "git@github.com:user/leader-knowledge.git",
      "description": "리더십/의사결정/팀운영"
    }
  }
}
```

## 도메인 전환 정책

- **세션 시작 시 한 번만 설정**: 세션 중간에 도메인 전환하지 않음 권장
- 전환 후 해당 세션 내 모든 gemify 명령이 해당 도메인에서 동작
- 다른 도메인 작업 필요 시 → 새 세션 시작 권장

## 경로 결정 우선순위

scope 스킬 참조. 도메인 결정 순서:

```
1. 환경변수: GEMIFY_DOMAIN=leader
2. cwd 기반: cwd가 ~/.gemify/leader/ 하위면 → leader
3. config.json의 current 값
4. 기본값: 첫 번째 도메인
```

## 예시 도메인들

| 도메인 | 설명 | 역할 |
|--------|------|------|
| builder | 기술/서비스개발/아키텍처 | 개발자, CTO |
| leader | 리더십/의사결정/팀운영 | 팀장, 리더 |
| planner | 기획/시나리오/스토리 | 기획자 |
| writer | 글쓰기/콘텐츠 | 작가 |
| teacher | 교육/커리큘럼 | 강사 |

## 주의사항

- 도메인명은 영문 소문자, 하이픈 사용 가능
- 도메인 삭제는 직접 폴더 삭제 필요 (gemify는 삭제 명령 제공 안 함)
- 각 도메인은 독립적인 git repo로 관리 가능
