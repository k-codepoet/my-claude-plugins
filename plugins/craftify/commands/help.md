---
description: craftify 플러그인 도움말을 표시합니다
---

# Craftify 도움말

> Craft your products with AI.

turborepo + Cloudflare 기반 웹앱 개발환경 자동화 도구입니다.

## 사용 가능한 커맨드

### 가이드
| 커맨드 | 설명 |
|--------|------|
| `/craftify:help` | 이 도움말 표시 |
| `/craftify:howto [topic]` | 사용 가이드 (주제별 사용법과 예시) |

### 프로젝트 개발
| 커맨드 | 설명 |
|--------|------|
| `/craftify:poc` | POC.md 기반 프로젝트 구현 |
| `/craftify:deploy` | Cloudflare 배포 설정 및 실행 |

## 워크플로우 개요

```
gemify:poc       → POC.md 생성 (아이디어 → 문서)
       ↓
craftify:poc     → 프로젝트 구현 (문서 → 코드)
       ↓
craftify:deploy  → Cloudflare 배포
```

## 더 알아보기

`/craftify:howto`로 각 기능의 상세 사용법과 예시를 확인하세요.
