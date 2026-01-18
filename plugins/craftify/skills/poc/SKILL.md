---
name: poc
description: POC.md 기반 프로젝트 구현. gemify:poc이 생성한 문서를 읽고 boilerplate 복제 → 빌드/배포 → 코드 구현.
---

# PoC Skill

POC.md를 읽고 **프로젝트를 구현**합니다.

## ⚠️ 필수 규칙 (반드시 준수)

> **이 규칙을 어기면 안 됩니다. 워크플로우 진행 전 반드시 숙지하세요.**

1. **How는 craftify가 판단한다**
   - POC.md에 기술 스택(Next.js, Vite 등)이 적혀 있어도 **무시**
   - gemify는 Why/What만 전달, **기술 선택권은 craftify에게 있음**

2. **대화 없이 진행 금지**
   - 3단계(How 판단)에서 **반드시 사용자에게 옵션 제시**
   - 사용자가 선택하기 전까지 **절대 코드 작성 시작 금지**

3. **boilerplate 필수 사용**
   - `npx create-next-app`, `npx create-vite` 등 **직접 실행 금지**
   - 반드시 `references/boilerplate.md`의 degit 명령 사용

## 전제 조건

- 현재 디렉토리에 `POC.md` 존재 (gemify:poc이 생성)
- POC.md 필수 섹션: Why, Hypothesis, What, Acceptance Criteria

## 워크플로우 (6단계)

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

#### 사용 가능한 boilerplates 표시

```
사용 가능한 boilerplates:

Web - Cloudflare:
  • react-router-ssr-cloudflare - SSR on Cloudflare Workers (엣지 SSR)
  • react-router-spa-cloudflare - SPA on Cloudflare Pages (정적 배포)

Web - Docker/Self-hosted:
  • react-router-ssr - SSR with Node.js (Docker, k8s 호환)
  • react-router-spa - SPA with nginx (Docker, 정적 호스팅)
```

#### 1단계: 배포 플랫폼 선택

```
어디에 배포할까요?

1. Cloudflare (Workers/Pages) - 엣지 배포, 글로벌 CDN
2. Docker (Self-hosted) - 컨테이너 배포, k8s/클라우드 호환
```

#### 2단계: 렌더링 방식 선택

```
렌더링 방식을 선택하세요:

1. SSR - 서버 사이드 렌더링 (SEO, 동적 데이터)
2. SPA - 클라이언트 렌더링 (정적, 빠른 배포)
```

#### 선택 조합 → boilerplate 결정

| 플랫폼 | 렌더링 | boilerplate |
|--------|--------|-------------|
| Cloudflare | SSR | `react-router-ssr-cloudflare` |
| Cloudflare | SPA | `react-router-spa-cloudflare` |
| Docker | SSR | `react-router-ssr` |
| Docker | SPA | `react-router-spa` |

사용자 확인 후 결정. 상세 복제 방법은 `references/boilerplate.md` 참조.

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

## 추가 규칙

- **빌드 확인 후 구현**: boilerplate 정상 동작 먼저 확인
- **가설 검증 기반 완료**: AC = 가설 검증 기준, 모든 AC 통과 = 가설 검증 성공

## References

상세 정보는 `references/` 참조:
- `boilerplate.md` - boilerplate 복제 방법
- `deploy-types.md` - SSR/SPA 배포 차이
- `context.md` - Context 필드 활용
- `error-handling.md` - 에러 처리
