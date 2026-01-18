---
title: "Session Report Viewer - GitHub API Rate Limit"
project: session-report-viewer
bug_type: integration
severity: high
status: resolved
symptom: "GitHub API error: Too Many Requests"
root_cause: "인증 없이 GitHub API 호출 시 60 req/hour 제한"
created: "2025-01-13"
updated: "2025-01-13"
revision: 1
sources:
  - "https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api"
history:
  - rev: 1
    date: 2025-01-13
    summary: "초기 생성 및 해결"
---

# Session Report Viewer - GitHub API Rate Limit

## Symptom - 증상

**에러 메시지:**
```
GitHub API error: Too Many Requests
```

**재현 단계:**
1. Session Report Viewer에서 대상 repo URL 접속 (예: `https://sessionview.k-codepoet.workers.dev/{owner}/{repo}`)
2. 페이지 로드 시 에러 발생

**발생 조건:**
- Cloudflare Workers에서 실행될 때 (공유 IP 사용)
- 여러 사용자가 동시 접근 시 빠르게 rate limit 도달

## Analysis - 분석

**관련 코드:**
- `apps/web/app/lib/github.ts:26-31`

**조사 내용:**
GitHub API는 인증 없이 호출 시 IP 기반으로 60 requests/hour 제한.
Cloudflare Workers는 공유 IP를 사용하므로 다른 사용자와 rate limit을 공유.
인증된 요청은 5,000 requests/hour 허용.

---

## Track A: Workaround (빠른 해결)

**예상 소요**: 10분
**적용 범위**: 영구 해결 (이 경우 workaround가 곧 해결책)
**부작용**: 없음

### 해결책

GitHub Personal Access Token을 환경변수로 추가하여 인증된 요청으로 전환

### 적용 방법

1. `github.ts`에 Authorization 헤더 추가
2. `repo.tsx` loader에서 환경변수 토큰 전달
3. Cloudflare에 secret 등록: `wrangler secret put GITHUB_TOKEN`

---

## Track B: Root Cause Fix (근본 해결)

**예상 소요**: 10분
**적용 범위**: 영구 해결

### 가설 (우선순위순)

1. **[HIGH] 인증 없는 API 호출**
   - **근거**: GitHub API 문서에 따르면 인증 없이 60 req/hour 제한
   - **검증 방법**: response headers에서 X-RateLimit-Remaining 확인
   - **해결책**: GitHub Token으로 인증하여 5,000 req/hour 확보

2. **[LOW] 캐싱 미적용**
   - **근거**: 같은 요청을 반복 호출
   - **검증 방법**: 요청 로그 확인
   - **해결책**: KV 또는 Cache API로 응답 캐싱

---

## Resolution - 해결 결과

**상태**: resolved
**적용된 해결책**: Track A/B 가설 1 - GitHub Token 인증 추가
**검증**: 로컬에서 typecheck 통과, 배포 후 정상 동작 확인 필요
**후속 조치**:
- `wrangler secret put GITHUB_TOKEN` 실행 필요
- 선택적: 캐싱 추가로 API 호출 최소화
