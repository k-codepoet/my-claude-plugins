---
description: PoC 패키징 및 핸드오프. 확정된 프로토타입을 git repo로 패키징하고 craftify/forgeify 핸드오프 준비. "패키징해줘", "확정", "이거 맞아" 등 요청 시 활성화.
---

# PoC Pack Skill

확정된 프로토타입을 **프로젝트로 패키징**하고 **craftify/forgeify 핸드오프**를 준비합니다.

## 언제 사용

- "이 느낌 맞아", "확정", "패키징해줘" 등 명시적 확정
- drafts에 충분히 정제된 형태 문서 존재
- prototype.html 등 결과물 존재
- 프로젝트 폴더/git 설정 단계

## 핵심 역할

### 1. 프로젝트 디렉토리 생성

```
프로젝트를 어디에 생성할까요?
기본값: ~/k-codepoet/{product}/

[1] 기본값 사용
[2] 경로 직접 입력
```

### 2. 프로젝트 파일 생성

| 파일 | 역할 |
|------|------|
| POC.md | views/by-poc/{product}.md 복사본 |
| CONTEXT.md | 프로젝트 서사/맥락 |
| assets/ | 프로토타입, 목업 등 |

### 3. Git 설정 + 원격 저장소

```
git init
├── GitHub 사용? (gh CLI)
└── GitLab 사용? (glab CLI)

저장소 설정:
├── organization: {기본값 또는 입력}
├── visibility: private (기본) / public
└── repo name: {product}
```

### 4. views/by-poc 업데이트

artifact 필드에 저장소 URL 추가

## 워크플로우

```
입력: 패키징 요청 ("확정", "패키징해줘" 등)
    ↓
관련 자료 수집:
├── drafts/{product}-shape.md
├── proto/{date}-{slug}/prototype.html
└── inbox/thoughts/{product}.md
    ↓
작업 디렉토리 질문 (기본: ~/k-codepoet/{product}/)
    ↓
프로젝트 파일 생성:
├── POC.md (Why/What 문서)
├── CONTEXT.md (서사/맥락)
└── assets/ (프로토타입, 목업)
    ↓
프로젝트 타입 판단:
├── webapp → craftify 핸드오프
└── plugin → forgeify 핸드오프
    ↓
Git 설정:
├── git init
├── gh/glab repo create
└── initial commit + push
    ↓
views/by-poc 업데이트 (artifact URL)
    ↓
핸드오프 안내
```

## 프로젝트 타입 판단

```
입력 분석
├── "앱", "웹", "서비스", "사이트" 등 → webapp
├── "플러그인", "커맨드", "스킬", "에이전트" 등 → plugin
└── 판단 불가 → 사용자에게 질문
```

판단 불가 시:
```
어떤 타입의 프로젝트인가요?

1. webapp - 웹 앱/서비스 (craftify로 구현)
2. plugin - Claude Code 플러그인 (forgeify로 구현)
```

## POC.md 템플릿

```markdown
---
title: "{프로젝트명}"
type: poc
created: YYYY-MM-DD
status: ready
---

# {프로젝트명}

## Why
{배경, 해결할 문제}

## Hypothesis
{검증하려는 가설}

## What
{핵심 기능, MVP 범위}

### 핵심 화면
{poc-shape에서 정의된 화면들}

## Acceptance Criteria
{가설 검증 기준}

## Assets
- prototype.html: 프로토타입
- (기타 목업, 샘플 데이터 등)
```

## CONTEXT.md 템플릿

```markdown
# {프로젝트명} Context

## 프로젝트 서사
{아이디어가 나온 배경, 문제 인식 과정}

## 핵심 결정들
{poc 과정에서 내린 중요한 결정과 이유}

## 참고 자료
{현재 도메인 지식 체계에서 사용된 재료들}

## 구현 담당
{craftify 또는 forgeify}
```

## Git 설정 상세

### GitHub 사용 시

```bash
cd {project_dir}
git init
git add .
git commit -m "Initial commit: POC ready"

# gh CLI로 저장소 생성
gh repo create {org}/{product} --private --source=. --push
```

### GitLab 사용 시

```bash
cd {project_dir}
git init
git add .
git commit -m "Initial commit: POC ready"

# glab CLI로 저장소 생성
glab repo create {group}/{product} --private
git remote add origin git@gitlab.com:{group}/{product}.git
git push -u origin main
```

### 플랫폼 선택

```
어떤 플랫폼을 사용할까요?

[1] GitHub (gh CLI)
[2] GitLab (glab CLI)
[3] 로컬만 (원격 저장소 없이)
```

## assets 폴더 구조

```
assets/
├── prototype.html    # 실제 동작하는 HTML 목업
├── mockup.png        # 디자인 이미지, 스크린샷
├── wireframe.svg     # 와이어프레임
├── sample-data.json  # 테스트용 데이터
└── notes.md          # 추가 메모
```

## 대화 예시

```
사용자: "이 느낌 맞아! 패키징해줘"

Claude: 프로젝트를 패키징할게요.

[수집된 자료]
- drafts/2026-01-18-gemify-webapp-shape.md
- proto/2026-01-18-pipeline-view/prototype.html

프로젝트 경로: ~/k-codepoet/gemify-webapp/
이대로 진행할까요? (다른 경로 입력 가능)

사용자: "좋아"

Claude: [생성 중...]
├── POC.md
├── CONTEXT.md
└── assets/prototype.html

플랫폼을 선택해주세요:
[1] GitHub  [2] GitLab  [3] 로컬만

사용자: "1"

Claude: [Git 설정 중...]
├── git init
├── gh repo create choigawoon/gemify-webapp --private
└── Initial commit + push

완료!

저장소: https://github.com/choigawoon/gemify-webapp
views/by-poc에 artifact URL 업데이트 완료

craftify로 구현을 시작하려면:
  cd ~/k-codepoet/gemify-webapp && claude
  /craftify:poc
```

## views/by-poc 업데이트

패키징 완료 후 views/by-poc/{product}.md의 artifact 필드 업데이트:

```yaml
---
artifact: https://github.com/{org}/{product}
status: packaged
---
```

## 완료 안내

### webapp인 경우
```
POC가 패키징되었습니다!

저장소: {repo_url}
로컬: {project_path}

craftify로 구현 시작:
  cd {project_path} && claude
  /craftify:poc
```

### plugin인 경우
```
POC가 패키징되었습니다!

저장소: {repo_url}
로컬: {project_path}

forgeify로 구현 시작:
  cd {project_path} && claude
  /forgeify:poc
```

## 규칙

- **사용자 확인 필수**: 경로, 플랫폼 선택 시 확인
- **views/by-poc 원본 유지**: 프로젝트에는 복사본
- **artifact URL 업데이트**: 패키징 완료 시 반드시
- **기존 repo 확인**: 같은 이름 있으면 경고
- **How 지정 금지**: gemify는 Why/What만, How는 craftify/forgeify가 결정
