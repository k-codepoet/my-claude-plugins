---
name: scope
description: Gemify User Scope 경로 관리. 모든 gemify 스킬 실행 전 ~/.gemify/ 존재 여부 확인. 없으면 setup 안내.
---

# Scope Skill

모든 gemify 스킬이 **동일한 경로**에서 동작하도록 보장합니다.

## User Scope 경로

```
~/.gemify/
```

모든 gemify 데이터는 이 경로에 저장됩니다.

## 스킬 실행 전 확인

**모든 gemify 스킬 실행 시 이 확인을 먼저 수행**:

```
~/.gemify/ 존재?
├── 예 → 스킬 실행 계속
└── 아니오 → setup 안내 후 중단
```

### Setup 안내 메시지

```
~/.gemify/가 설정되지 않았습니다.

설정하기:
  /gemify:setup              # 새로 시작
  /gemify:setup --clone URL  # 기존 repo 가져오기

도움말: /gemify:help
```

## 경로 규칙

| 폴더 | 용도 | 예시 경로 |
|------|------|-----------|
| inbox/thoughts/ | 내 생각 | ~/.gemify/inbox/thoughts/2026-01-06-idea.md |
| inbox/materials/ | 외부 재료 | ~/.gemify/inbox/materials/2026-01-06-article.md |
| drafts/ | 다듬는 중 | ~/.gemify/drafts/project-plan.md |
| library/ | 완성된 지식 | ~/.gemify/library/insights/key-learning.md |
| views/by-subject/ | 문제 → 해결책 | ~/.gemify/views/by-subject/ai-tools.md |
| views/by-talk/ | 발표/강연 | ~/.gemify/views/by-talk/ai-presentation.md |
| views/by-curriculum/ | 교육/커리큘럼 | ~/.gemify/views/by-curriculum/ai-course.md |
| views/by-portfolio/ | 포트폴리오 | ~/.gemify/views/by-portfolio/my-work.md |
| views/by-essay/ | 에세이/수필 | ~/.gemify/views/by-essay/my-thoughts.md |
| views/by-poc/ | PoC 프로젝트 | ~/.gemify/views/by-poc/new-product.md |
| views/by-improvement/ | 플러그인 개선 | ~/.gemify/views/by-improvement/gemify-feature.md |
| sessions/ | 세션 리포트 | ~/.gemify/sessions/2026-01-06-wrapup.md |
| meta/cluster/ | 지식 클러스터 맵 | ~/.gemify/meta/cluster/current.md |

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

1. **inbox**: `~/.gemify/inbox/thoughts/`
2. **import**: `~/.gemify/inbox/materials/`
3. **draft**: `~/.gemify/drafts/`
4. **library**: `~/.gemify/library/`
5. **view**: `~/.gemify/views/` (7가지 타입)
6. **wrapup**: `~/.gemify/sessions/`
7. **triage/map**: `~/.gemify/meta/cluster/`
