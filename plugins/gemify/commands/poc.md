---
description: PoC 파이프라인 라우터 - 상황에 따라 poc-idea/shape/proto/pack으로 분기합니다.
allowed-tools: Read, Write, Glob, Grep, Bash, Skill
argument-hint: ["아이디어 설명" | "화면 만들어봐" | "패키징해줘"]
---

# /gemify:poc

PoC 파이프라인 라우터입니다. 사용자의 현재 상태를 판단하여 적절한 하위 스킬로 안내합니다.

## 사용법

```
/gemify:poc "이런 앱 만들고 싶어"    # → poc-idea (아이디어 정제)
/gemify:poc                          # → 상황 판단 후 라우팅
/gemify:poc "화면 보여줘"            # → poc-proto (실시간 미리보기)
/gemify:poc "패키징해줘"             # → poc-pack (git 설정 + 핸드오프)
```

## 하위 스킬

| 스킬 | 역할 | 결과물 |
|------|------|--------|
| poc-idea | 본질 질문으로 아이디어 정제 | inbox/thoughts에 저장 |
| poc-shape | 재료 탐색 + 무의식 도출 | drafts에 형태 문서 |
| poc-proto | HTML 생성 + 로컬 서버 미리보기 | prototype.html |
| poc-pack | git repo 생성 + 핸드오프 | POC.md, CONTEXT.md |

ARGUMENTS: $ARGUMENTS
