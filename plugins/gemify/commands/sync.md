---
description: ~/.gemify/ 저장소를 remote와 동기화합니다. pull/push/status 서브커맨드를 지원합니다.
argument-hint: "<pull|push|status>"
allowed-tools: Read, Bash
---

# /gemify:sync - Git 동기화

`~/.gemify/` 저장소를 remote와 동기화합니다.

## 사용법

```bash
/gemify:sync pull     # remote에서 가져오기
/gemify:sync push     # remote로 올리기
/gemify:sync status   # 동기화 상태 확인
/gemify:sync          # status와 동일
```

## 서브커맨드

| 커맨드 | 설명 |
|--------|------|
| `pull` | remote에서 최신 변경사항 가져오기 (git pull) |
| `push` | 로컬 변경사항을 remote로 올리기 (add + commit + push) |
| `status` | 현재 동기화 상태 확인 |

## 동작

### 0단계: ~/.gemify/ 확인

```
~/.gemify/ 존재?
├── 아니오 → "/gemify:setup으로 먼저 설정하세요" + 종료
└── 예 → 계속
```

### pull

```bash
cd ~/.gemify
git pull --rebase
```

- conflict 발생 시 사용자에게 알림
- remote 없으면 → remote 설정 안내

### push

```bash
cd ~/.gemify
git add -A
git commit -m "Update gemify $(date +%Y-%m-%d)"
git push
```

- 변경사항 없으면 "동기화할 내용이 없습니다" 출력
- remote 없으면 → remote 설정 안내 (아래 참조)

### status

```bash
cd ~/.gemify
git status
git log --oneline -5
```

출력 예시:
```
📍 ~/.gemify/ 상태

브랜치: main
Remote: git@github.com:user/my-gemify.git

로컬 변경:
  - inbox/thoughts/2026-01-06-new-idea.md (new)
  - drafts/project-plan.md (modified)

최근 커밋:
  abc1234 Update gemify 2026-01-05
  def5678 Add new insight
  ...

동기화: /gemify:sync push
```

## Remote 설정 안내

remote가 없는 경우:

```
Remote가 설정되지 않았습니다.

GitHub에서 빈 repo 생성 후:
  cd ~/.gemify
  git remote add origin <url>
  git push -u origin main

또는 기존 repo가 있다면:
  rm -rf ~/.gemify
  /gemify:setup --clone <url>
```

## 예제

### 다른 머신에서 작업 후 동기화

```bash
# 최신 변경사항 가져오기
/gemify:sync pull

# 작업 후 올리기
/gemify:sync push
```

### 상태 확인

```bash
/gemify:sync status
```

## 안전 장치

- **절대 ~/.gemify/ 폴더를 삭제하지 않음**
- push 전 항상 현재 상태 확인
- conflict 발생 시 자동 해결하지 않고 사용자에게 알림

## 주의사항

- force push 사용하지 않음
- merge conflict는 수동 해결 필요
- 대용량 파일은 .gitignore 권장
