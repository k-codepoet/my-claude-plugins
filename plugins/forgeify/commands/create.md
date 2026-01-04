---
description: 지정된 경로의 내용을 기반으로 Claude Code 플러그인을 생성합니다.
argument-hint: "<path> <topic>"
---

# /forgeify:create

create 스킬을 사용하여 플러그인을 생성합니다.

## 사용법

```
/forgeify:create <path> <topic>
```

- `<path>`: 플러그인 소스가 될 파일 또는 디렉토리 경로
- `<topic>`: 플러그인 주제/이름 (예: "docker-helper", "git-workflow")

## 예시

```
/forgeify:create ~/my-scripts/docker-utils docker-helper
```
