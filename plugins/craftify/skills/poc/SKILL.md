---
name: poc
description: POC.md 기반 프로젝트 구현. gemify:poc이 생성한 문서를 읽고 boilerplate 복제 → 빌드/배포 → 코드 구현.
---

# PoC Skill

POC.md를 읽고 **프로젝트를 구현**합니다.

## 전제 조건

- 현재 디렉토리에 `POC.md` 존재 (gemify:poc이 생성)
- POC.md 필수 섹션: Why, Hypothesis, What, Acceptance Criteria

## 워크플로우 (5단계)

### 1. POC.md 읽기

- 있으면 → 내용 분석
- 없으면 → 에러 (`references/error-handling.md` 참조)

### 2. 문서 분석

파악할 내용:
- **product**: 제품명 (frontmatter)
- **hypothesis**: 검증하려는 가설 (frontmatter)
- **Why/What**: 배경, 핵심 기능
- **Acceptance Criteria**: 가설 검증 기준 (체크리스트)
- **Context** (선택): `references/context.md` 참조

### 3. How 판단 (대화)

SSR/SPA 추천:
- 서버 로직 필요 → SSR
- 정적/목업 → SPA

사용자 확인 후 결정.

### 4. 프로젝트 셋업

1. boilerplate 복제 (`references/boilerplate.md` 참조)
2. turborepo 구조 생성
3. 빌드 확인: `pnpm install && pnpm build && pnpm dev`
4. 배포 (선택): `/craftify:deploy` (`references/deploy-types.md` 참조)

### 5. 코드 구현

- What 기반 기능 구현
- AC 체크리스트 하나씩 검증
- 모든 AC 완료 → **가설 검증 완료**

### 6. 가설 검증 확인

구현 완료 후:
- AC 체크리스트 모두 통과했는지 확인
- **hypothesis가 검증되었는지** 사용자에게 확인
- POC.md의 AC 항목에 체크 표시 업데이트

## 규칙

- **How는 craftify가 판단**: gemify는 Why/What만 전달
- **빌드 확인 후 구현**: boilerplate 정상 동작 먼저 확인
- **가설 검증 기반 완료**: AC = 가설 검증 기준, 모든 AC 통과 = 가설 검증 성공

## References

상세 정보는 `references/` 참조:
- `boilerplate.md` - boilerplate 복제 방법
- `deploy-types.md` - SSR/SPA 배포 차이
- `context.md` - Context 필드 활용
- `error-handling.md` - 에러 처리
