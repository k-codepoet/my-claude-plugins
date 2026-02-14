---
name: poc
description: POC.md 기반 프로젝트 구현. gemify:poc이 생성한 문서를 읽고 boilerplate 복제 → 빌드/배포 → 코드 구현.
allowed-tools: Read, Write, Bash, Glob
argument-hint: "[POC.md 경로]"
---

# PoC Skill

POC.md를 읽고 **프로젝트를 구현**합니다.

## ⚠️ 필수 규칙 (반드시 준수)

> **이 규칙을 어기면 안 됩니다. 워크플로우 진행 전 반드시 숙지하세요.**

1. **How는 craftify가 판단한다**
   - POC.md에 기술 스택(Next.js, Vite 등)이 적혀 있어도 craftify의 조언 우선
   - gemify는 Why/What만 전달, **기술 선택권은 craftify에게 있음**
   - 단, 사용자가 명시적으로 거부하면 존중

2. **대화 없이 진행 금지**
   - 3단계(How 판단)에서 **반드시 사용자에게 옵션 제시**
   - 사용자가 선택하기 전까지 **절대 코드 작성 시작 금지**

3. **boilerplate 필수 사용**
   - `npx create-next-app`, `npx create-vite` 등 **직접 실행 금지**
   - 반드시 `boilerplate-guide` 스킬의 degit 명령 사용

## 워크플로우 (7단계)

### 0. 인자 처리 (신규)

```
인자(POC.md 경로) 있음?
├── 예 → 해당 경로의 POC.md 읽기
│        └── 파일 존재?
│            ├── 예 → 1단계로 진행
│            └── 아니오 → 에러: "파일을 찾을 수 없습니다: {경로}"
└── 아니오 → 사용자에게 되묻기
             "POC 문서 경로를 입력해주세요.
              예: /craftify:poc ./path/to/POC.md

              POC 문서가 없다면:
              /gemify:poc 으로 먼저 생성하세요."
```

### 1. POC.md 읽기

- 인자로 받은 경로 또는 사용자가 입력한 경로의 POC.md 읽기
- 없으면 → 0단계의 안내 메시지 표시

### 2. 문서 분석

파악할 내용:
- **product**: 제품명 (frontmatter)
- **hypothesis**: 검증하려는 가설 (frontmatter)
- **Why/What**: 배경, 핵심 기능
- **Acceptance Criteria**: 가설 검증 기준 (체크리스트)
- **Context** (선택): `references/context.md` 참조
- **기술스택 지정 여부**: POC.md에 기술스택이 명시되어 있는지 확인

### 2.5. 기술스택 지정 시 전문가 조언 (신규)

```
POC.md에 기술스택(Next.js, Vite, React 등) 지정됨?
├── 예 → craftify 전문가 조언 제안
│        "POC.md에 '{기술스택}'이 지정되어 있습니다.
│
│         craftify는 boilerplate pool과 배포 환경을 고려한
│         기술 선택을 권장합니다:
│         • 검증된 boilerplate 사용으로 빠른 시작
│         • 배포 환경에 최적화된 설정
│         • turborepo 구조와의 호환성
│
│         craftify의 조언을 따르시겠습니까? (y/n)"
│
│        └── y → 3단계 "How 판단" 진행
│        └── n → 지정된 기술스택 사용 시도
│                (단, boilerplate가 없으면 경고 후 수동 설정 안내)
└── 아니오 → 3단계 "How 판단" 진행
```

### 3. How 판단 (boilerplate-guide 스킬 활용)

> **`boilerplate-guide` 스킬을 참조하여 선택 가이드를 제공합니다.**

boilerplate 선택 시:
1. `boilerplate-guide` 스킬의 선택 기준 매트릭스 참조
2. 프로젝트 요구사항 분석 (POC.md 기반)
3. 의사결정 플로우차트에 따라 추천
4. 사용자에게 옵션 제시 및 확인

#### 1단계: 렌더링 방식 (boilerplate-guide 참조)

```
프로젝트에 SEO나 동적 메타태그가 필요한가요?

1. 예 - SSR (서버 사이드 렌더링)
2. 아니오 - SPA (싱글 페이지 앱)
```

#### 2단계: 배포 플랫폼 (boilerplate-guide 참조)

```
어디에 배포할 계획인가요?

1. Cloudflare (권장) - 엣지 배포, 글로벌 CDN, 무료
2. Docker / Self-hosted - k8s, VM, 온프레미스
```

#### 선택 조합 → boilerplate 결정

| 렌더링 | 플랫폼 | boilerplate |
|--------|--------|-------------|
| SSR | Cloudflare | `react-router-ssr-cloudflare` |
| SPA | Cloudflare | `react-router-spa-cloudflare` |
| SSR | Docker | `react-router-ssr` |
| SPA | Docker | `react-router-spa` |

사용자 확인 후 결정.

### 4. 프로젝트 셋업

1. boilerplate 복제 (`boilerplate-guide` 스킬의 복제 명령 참조)
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

상세 정보는 참조:
- `skills/boilerplate-guide/SKILL.md` - boilerplate 선택 가이드 (필수 참조)
- `references/boilerplate.md` - boilerplate 복제 방법
- `references/deploy-types.md` - SSR/SPA 배포 차이
- `references/context.md` - Context 필드 활용
- `references/error-handling.md` - 에러 처리
