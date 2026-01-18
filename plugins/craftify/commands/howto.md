---
description: Craftify 사용 가이드. 인자 없이 실행하면 가능한 주제 목록을, 주제를 지정하면 해당 가이드를 표시합니다.
argument-hint: "[topic]"
---

# /craftify:howto 명령어

사용자가 요청한 주제에 대한 Craftify 사용 가이드를 제공합니다.

## 사용법

- `/craftify:howto` - 가능한 주제 목록 표시
- `/craftify:howto <topic>` - 특정 주제 가이드 표시

## 가능한 주제 (Topics)

### 프로젝트 개발
| 주제 | 설명 | 예시 |
|------|------|------|
| `poc` | POC.md 기반 프로젝트 구현 | `/craftify:poc` |
| `deploy` | Cloudflare 배포 설정 및 실행 | `/craftify:deploy setup` |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.
   - `poc` → poc 스킬
   - `deploy` → deploy 스킬

3. **알 수 없는 주제**: 가능한 주제 목록을 보여주고 올바른 주제를 선택하도록 안내합니다.

## 워크플로우 개요

```
gemify:poc       → POC.md 생성 (Why/What)
       ↓
craftify:poc     → 프로젝트 구현 (How 판단)
       ↓
craftify:deploy  → Cloudflare 배포
```

## 배포 흐름

```
[로컬 개발]
    ↓ pnpm build (빌드 확인)
    ↓ GitHub push (main 브랜치)
    ↓ Dashboard에서 Git 연결 (최초 1회)
[Production 배포 완료]
    ↓ 이후 main push → 자동 배포
    ↓ 브랜치/PR push → Preview URL 자동 생성
```
