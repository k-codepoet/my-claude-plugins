---
description: Cloudflare 배포 설정 및 실행. Dashboard Git 연결 방식.
allowed-tools: Read, Bash, Glob
argument-hint: [setup|status]
---

# /craftify:deploy

**Cloudflare Workers/Pages**로 배포합니다.

## 사용법

```
/craftify:deploy [command]
```

### 명령어

| 명령어 | 설명 |
|--------|------|
| (없음) | 배포 가이드 표시 |
| `setup` | Cloudflare 설정 안내 |
| `status` | 배포 상태 확인 |

## 배포 방식

SSR/SPA 모두 **Dashboard에서 Git 연결** 방식:
- 최초 1회 Dashboard 설정
- 이후 push마다 자동 배포
- PR에 Preview URL 자동 코멘트

## 동작

1. 프로젝트 확인 (SSR/SPA 감지)
2. Dashboard 설정 안내 (최초 1회)
3. 자동 배포 상태 확인

## References

상세 워크플로우는 스킬 참조:
- `skills/deploy/SKILL.md` - 배포 스킬 상세
