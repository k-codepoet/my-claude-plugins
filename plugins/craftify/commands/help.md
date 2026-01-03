---
description: Craftify 플러그인 도움말 표시
allowed-tools: Read
---

# /craftify:help

Craftify 플러그인 사용법을 안내합니다.

## 출력

```
🔨 Craftify - Craft your products with AI

turborepo + Cloudflare 기반 개발환경 자동화 플러그인

## 명령어

| 명령어 | 설명 |
|--------|------|
| /craftify:create | 새 프로젝트 생성 |
| /craftify:dev | 로컬 개발 환경 |
| /craftify:deploy | Cloudflare 배포 |
| /craftify:status | 프로젝트 상태 |
| /craftify:help | 이 도움말 |

## Quick Start

1. 프로젝트 생성
   /craftify:create webapp my-app

2. 개발 시작
   cd my-app && pnpm install && pnpm dev

3. 배포 준비되면
   /craftify:deploy

## 지원 타입

| 타입 | 설명 |
|------|------|
| webapp | 웹앱 (React Router 7 + Cloudflare) |

## Progressive Disclosure

복잡함은 숨기고, 필요할 때만 드러냅니다.
- 생성 시: 순수 코드만
- 배포 필요 시: Cloudflare 설정 가이드
- 자동화 필요 시: GitHub 연동 안내
```
