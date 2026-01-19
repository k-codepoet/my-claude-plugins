---
name: boilerplate-guide
description: boilerplate 선택 가이드. 프로젝트 요구사항에 맞는 boilerplate 추천. "boilerplate 선택", "어떤 템플릿", "SSR vs SPA" 등 질문 시 활성화.
---

# Boilerplate Guide Skill

프로젝트 요구사항에 맞는 **boilerplate 선택을 가이드**합니다.

## 선택 기준 매트릭스

| 요구사항 | 권장 렌더링 | 권장 플랫폼 |
|----------|------------|------------|
| SEO 필요 | SSR | - |
| 동적 데이터 많음 | SSR | - |
| 정적 콘텐츠 위주 | SPA | - |
| 글로벌 배포, 엣지 | - | Cloudflare |
| 기존 인프라 (k8s, VM) | - | Docker |
| 빠른 배포, 무료 | - | Cloudflare |
| 커스텀 서버 설정 | - | Docker |

## 의사결정 플로우차트

```
SEO 또는 동적 메타태그 필요?
├── 예 → SSR
│        └── 배포 환경?
│            ├── Cloudflare (엣지, 글로벌) → react-router-ssr-cloudflare
│            └── Docker (k8s, VM, 온프레미스) → react-router-ssr
└── 아니오 → SPA
         └── 배포 환경?
             ├── Cloudflare (Pages, CDN) → react-router-spa-cloudflare
             └── Docker (nginx, 정적 호스팅) → react-router-spa
```

## Boilerplate Pool

| boilerplate | 렌더링 | 플랫폼 | 장점 | 단점 |
|-------------|--------|--------|------|------|
| `react-router-ssr-cloudflare` | SSR | Cloudflare Workers | 엣지 SSR, 글로벌 CDN, 무료 티어 | Workers 제한 (CPU, 메모리) |
| `react-router-spa-cloudflare` | SPA | Cloudflare Pages | 빠른 배포, 글로벌 CDN, 무료 | SEO 제한, 동적 데이터 어려움 |
| `react-router-ssr` | SSR | Docker/Node.js | 유연한 서버 설정, k8s 호환 | 인프라 관리 필요 |
| `react-router-spa` | SPA | Docker/nginx | 단순, 어디서나 호스팅 | SEO 제한 |

## 복제 명령

```bash
# Cloudflare SSR
npx degit k-codepoet/craftify-boilerplates/web/react-router-ssr-cloudflare apps/web

# Cloudflare SPA
npx degit k-codepoet/craftify-boilerplates/web/react-router-spa-cloudflare apps/web

# Docker SSR
npx degit k-codepoet/craftify-boilerplates/web/react-router-ssr apps/web

# Docker SPA
npx degit k-codepoet/craftify-boilerplates/web/react-router-spa apps/web
```

## 사용자 대화 가이드

boilerplate 선택 시 다음 순서로 질문:

### 1단계: 렌더링 방식

```
프로젝트에 SEO나 동적 메타태그가 필요한가요?

1. 예 - SSR (서버 사이드 렌더링)
   • 검색엔진 최적화 필요
   • 소셜 미리보기 (OG 태그)
   • 사용자별 다른 콘텐츠

2. 아니오 - SPA (싱글 페이지 앱)
   • 로그인 후 사용하는 앱
   • 대시보드, 어드민
   • SEO 불필요
```

### 2단계: 배포 플랫폼

```
어디에 배포할 계획인가요?

1. Cloudflare (권장)
   • 글로벌 엣지 배포
   • 무료 티어 충분
   • 빠른 배포 (Git 연동)

2. Docker / Self-hosted
   • 기존 k8s 클러스터
   • 온프레미스 서버
   • 커스텀 서버 설정 필요
```

### 3단계: 확인

```
선택: {렌더링} + {플랫폼}
→ boilerplate: {boilerplate-name}

이대로 진행할까요? (y/n)
```

## craftify 권장 사항

> **craftify는 Cloudflare + SSR을 기본 권장합니다.**

이유:
1. **엣지 SSR**: 사용자와 가까운 곳에서 렌더링
2. **무료 티어**: 대부분의 PoC에 충분
3. **Git 연동 배포**: 푸시만 하면 자동 배포
4. **글로벌 CDN**: 별도 설정 없이 전 세계 빠른 응답

단, 다음 경우는 예외:
- 기존 k8s 인프라 활용 필요 → Docker
- Workers 제한 초과 예상 → Docker SSR
- 극도로 단순한 정적 사이트 → SPA

## 외부 참조

- https://github.com/k-codepoet/craftify-boilerplates - Boilerplate 저장소
