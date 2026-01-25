---
name: scope
description: Gemify User Scope 경로 관리. 멀티 도메인 지원. 모든 gemify 스킬 실행 전 경로 결정.
---

# Scope Skill

모든 gemify 스킬이 **현재 도메인의 경로**에서 동작하도록 보장합니다.

## 멀티 도메인 구조

```
~/.gemify/
├── config.json           # 도메인 설정
├── builder/              # 기술/서비스개발 도메인
│   ├── inbox/
│   ├── drafts/
│   ├── library/
│   ├── views/
│   └── sessions/
├── leader/               # 리더십 도메인
│   ├── inbox/
│   ├── drafts/
│   ├── library/
│   ├── views/
│   └── sessions/
└── (확장 가능: planner, writer, teacher...)
```

## 경로 결정 우선순위

**모든 gemify 스킬 실행 시 이 순서로 도메인 결정**:

```
1. 환경변수: GEMIFY_DOMAIN=leader
   ↓ (없으면)
2. cwd 기반: cwd가 ~/.gemify/leader/ 하위면 → leader
   ↓ (없으면)
3. config.json의 current 값
   ↓ (없으면)
4. 기본값: 첫 번째 도메인 (builder)
```

**최종 경로**: `~/.gemify/{domain}/`

## 스킬 실행 전 확인

**모든 gemify 스킬 실행 시 이 확인을 먼저 수행**:

```
~/.gemify/ 존재?
├── 아니오 → setup 안내 후 중단
└── 예 → config.json 존재?
         ├── 아니오 → 기본 config.json 생성
         └── 예 → 도메인 결정 후 스킬 실행
```

### Setup 안내 메시지

```
~/.gemify/가 설정되지 않았습니다.

설정하기:
  /gemify:setup              # 새로 시작
  /gemify:setup --clone URL  # 기존 repo 가져오기

도움말: /gemify:help
```

## config.json 스키마

```json
{
  "version": "1.0",
  "current": "builder",
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

### 필드 설명

| 필드 | 설명 |
|------|------|
| `version` | config 스키마 버전 |
| `current` | 현재 활성 도메인 |
| `domains` | 도메인 목록 (key: 도메인명) |
| `domains.{name}.path` | 도메인 경로 |
| `domains.{name}.repo` | git remote URL (null 가능) |
| `domains.{name}.description` | 도메인 설명 |

## 도메인 전환 정책

- **세션 시작 시 한 번만 설정**: 세션 중간에 도메인 전환하지 않음
- 전환 후 해당 세션 내 모든 gemify 명령이 해당 도메인에서 동작
- 다른 도메인 작업 필요 시 → 새 세션 시작

## 경로 규칙

현재 도메인이 `{domain}`일 때:

| 폴더 | 용도 | 예시 경로 |
|------|------|-----------|
| visions/{vision-name}/ | 비전/평가 | ~/.gemify/{domain}/visions/ai-company/definition.md |
| inbox/thoughts/ | 내 생각 | ~/.gemify/{domain}/inbox/thoughts/2026-01-06-idea.md |
| inbox/materials/ | 외부 재료 | ~/.gemify/{domain}/inbox/materials/2026-01-06-article.md |
| drafts/ | 다듬는 중 | ~/.gemify/{domain}/drafts/project-plan.md |
| library/ | 완성된 지식 | ~/.gemify/{domain}/library/insights/key-learning.md |
| views/by-subject/ | 문제 → 해결책 | ~/.gemify/{domain}/views/by-subject/ai-tools.md |
| views/by-talk/ | 발표/강연 | ~/.gemify/{domain}/views/by-talk/ai-presentation.md |
| views/by-curriculum/ | 교육/커리큘럼 | ~/.gemify/{domain}/views/by-curriculum/ai-course.md |
| views/by-portfolio/ | 포트폴리오 | ~/.gemify/{domain}/views/by-portfolio/my-work.md |
| views/by-essay/ | 에세이/수필 | ~/.gemify/{domain}/views/by-essay/my-thoughts.md |
| views/by-poc/ | PoC 프로젝트 | ~/.gemify/{domain}/views/by-poc/new-product.md |
| views/by-improvement/ | 플러그인 개선 | ~/.gemify/{domain}/views/by-improvement/gemify-feature.md |
| sessions/ | 세션 리포트 | ~/.gemify/{domain}/sessions/2026-01-06-wrapup.md |
| meta/cluster/ | 지식 클러스터 맵 | ~/.gemify/{domain}/meta/cluster/current.md |

## 도메인별 Git Repo

각 도메인 폴더는 **독립적인 git repo**로 관리:

```bash
~/.gemify/builder/   ← git repo A (기술 지식)
~/.gemify/leader/    ← git repo B (리더십 지식)
```

- config.json의 `repo` 필드에 remote URL 저장
- `/gemify:sync`는 현재 활성 도메인의 repo만 동기화
- 도메인 추가 시 git clone 또는 git init 선택 가능

## 안전 장치

### 절대 금지 (CRITICAL)

**다음 명령은 어떤 상황에서도 실행하면 안 됨:**

```bash
# 절대 금지
rm -rf ~/.gemify
rm -rf ~/.gemify/
rm -r ~/.gemify
rmdir ~/.gemify  # 비어있어도 안 됨
mv ~/.gemify /other/path
```

**이유**: 사용자의 모든 지식 자산이 손실됨. 복구 불가.

### 금지 행위

- `~/.gemify/` 폴더 통째로 삭제
- `~/.gemify/`를 다른 경로로 이동
- 사용자 확인 없이 파일 덮어쓰기
- clone 시 기존 `~/.gemify/` 삭제 후 재생성

### 필수 행위

- 파일 생성/수정 전 경로 존재 확인
- 에러 발생 시 명확한 안내
- 변경사항은 git으로 추적 가능하도록
- clone 시 `~/.gemify/` 이미 존재하면 중단 + 경고

### 위반 시 대응

만약 사용자가 `~/.gemify/` 삭제를 요청하면:

```
⚠️ ~/.gemify/ 삭제는 모든 지식 자산 손실을 의미합니다.

정말 삭제하려면 터미널에서 직접 실행하세요:
rm -rf ~/.gemify

gemify는 이 명령을 대신 실행하지 않습니다.
```

## 다른 스킬에서 참조

모든 gemify 스킬은 이 scope 규칙을 따릅니다:

1. **domain**: 도메인 관리 (`/gemify:domain list`, `set`, `add`)
2. **vision**: `~/.gemify/{domain}/visions/{vision-name}/definition.md`
3. **vision-review**: `~/.gemify/{domain}/visions/{vision-name}/reviews/`
4. **inbox**: `~/.gemify/{domain}/inbox/thoughts/`
5. **import**: `~/.gemify/{domain}/inbox/materials/`
6. **draft**: `~/.gemify/{domain}/drafts/`
7. **library**: `~/.gemify/{domain}/library/`
8. **view**: `~/.gemify/{domain}/views/` (7가지 타입)
9. **wrapup**: `~/.gemify/{domain}/sessions/`
10. **triage/map**: `~/.gemify/{domain}/meta/cluster/`
