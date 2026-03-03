# React Router 7 — Authentik OIDC 인증 + 사용자 관리 구현

> React Router 7 (SSR) 앱에 Authentik OIDC 인증 + 4-역할 사용자 관리를 구현하는 워크플로우.
> 외부 라이브러리 없이 표준 OAuth2 Authorization Code Flow를 직접 구현한다.
>
> **실제 사례:** rehab-crm (React 19 + React Router 7 + Vite 7)
> **전제:** [authentik-oidc-app-onboarding.md](../authentik-oidc-app-onboarding.md) Phase 1~4 완료 (Blueprint 배포, OIDC 자격증명 확보)

## 타임라인

| 날짜 | 내용 |
|------|------|
| 2026-02 | 초기 버전 — OIDC 인증 구현 (login/callback/logout) |
| 2026-03-01 | Phase 5 추가 — 사용자 승인 워크플로우 (pending/user/admin/banned) |
| 2026-03-02 | Phase 5 보강 — admin 페이지 리디자인 (전체 사용자 목록, 필터, 검색, 역할 변경) |

## 아키텍처

```
브라우저
  ├─ / 접속 → root loader → 세션 없음 → 302 /login
  ├─ /login 페이지 → "Google로 로그인" 버튼 클릭
  ├─ /auth/login → state 생성 + 세션 저장 → 302 Authentik authorize
  ├─ Authentik → Google OAuth → 인증 완료
  │   ├─ 기존 사용자 → default-source-authentication flow
  │   └─ 신규 사용자 → {app}-enrollment flow (자동 가입, pending 그룹)
  ├─ /api/auth/callback/authentik → code+state 검증 → token 교환 → userinfo (groups 포함) → 세션 생성
  └─ root loader → groups 기반 라우팅:
      ├─ {app}-users-banned → 302 /banned
      ├─ {app}-users → 앱 렌더링
      ├─ {app}-admins → 앱 + /admin 접근
      └─ {app}-users-pending only → 302 /pending

관리자 역할 변경:
  /admin → 사용자 목록 (필터/검색) → 역할 변경 버튼
  → POST /api/admin/change-role → Authentik API (그룹 이동)

로그아웃:
  POST /auth/logout → 세션 파괴 → 302 /login (Authentik 화면 안 거침)
```

### 핵심 설계 결정

| 결정 | 선택 | 이유 |
|------|------|------|
| OIDC 라이브러리 | 미사용 (직접 구현) | Authorization Code Flow만 필요, 의존성 최소화 |
| 세션 저장소 | `createCookieSessionStorage` | 서버 사이드 세션 불필요, stateless |
| 서버 코드 분리 | `.server.ts` 접미사 | Vite가 클라이언트 번들에서 자동 제외 |
| 로그아웃 | 세션만 파괴 (앱 → /login) | Authentik end-session 화면 노출 방지 |
| 접근 거부 | callback에서 error 파라미터 감지 → /login 리다이렉트 | Authentik "권한 거부됨" 화면 노출 방지 |
| 역할 관리 | 앱 서버에서 Authentik Admin API 호출 | Admin UI 없이 앱 내에서 완결 |
| 역할 판단 | OIDC `groups` claim으로 앱 root loader에서 분기 | Authentik은 OIDC만 제공, 분기 로직은 앱 책임 |
| 리버스 프록시 URL | `X-Forwarded-Host` + production `https` 강제 | Traefik chain 뒤에서 `request.url`이 내부 주소 반환 문제 해결 |

## 치환 변수

| 변수 | 설명 | 예시 |
|------|------|------|
| `{app-slug}` | Authentik Application slug | `rehab-crm` |
| `{app-domain}` | 앱 프로덕션 도메인 | `rehab-crm.codepoet.site` |
| `{cookie-name}` | 세션 쿠키 이름 | `__rehab_session` |
| `{앱 이름}` | UI 표시용 | `잼잼발달센터` |
| `{앱 설명}` | 로그인 화면 부제 | `스케줄 관리 시스템` |

---

## Phase 1: 타입 정의

- [ ] `types/index.ts`에 `AuthUser` 인터페이스 추가

```typescript
// --- Auth ---

export interface AuthUser {
  sub: string;
  email: string;
  name: string;
  groups: string[];  // Authentik groups (역할 판단용)
}
```

---

## Phase 2: 서버 인증 모듈 (`lib/auth.server.ts`)

- [ ] `app/lib/auth.server.ts` 생성

```typescript
import { createCookieSessionStorage, redirect } from "react-router";
import type { AuthUser } from "~/types";

interface SessionData {
  user: AuthUser;
  oauth_state: string;
}

// --- Environment ---

function getEnv() {
  const AUTHENTIK_CLIENT_ID = process.env.AUTHENTIK_CLIENT_ID;
  const AUTHENTIK_CLIENT_SECRET = process.env.AUTHENTIK_CLIENT_SECRET;
  const SESSION_SECRET = process.env.SESSION_SECRET || "dev-secret-change-me";
  const APP_URL = process.env.APP_URL || "http://localhost:5173";
  const AUTHENTIK_ISSUER =
    process.env.AUTHENTIK_ISSUER ||
    "https://auth.codepoet.site/application/o/{app-slug}";

  if (!AUTHENTIK_CLIENT_ID || !AUTHENTIK_CLIENT_SECRET) {
    throw new Error(
      "Missing AUTHENTIK_CLIENT_ID or AUTHENTIK_CLIENT_SECRET environment variables"
    );
  }

  return {
    AUTHENTIK_CLIENT_ID,
    AUTHENTIK_CLIENT_SECRET,
    SESSION_SECRET,
    APP_URL,
    AUTHENTIK_ISSUER,
  };
}

// --- OIDC Endpoints (Authentik 공통) ---

const AUTHORIZE_URL =
  "https://auth.codepoet.site/application/o/authorize/";
const TOKEN_URL = "https://auth.codepoet.site/application/o/token/";
const USERINFO_URL = "https://auth.codepoet.site/application/o/userinfo/";

// --- Session Storage ---

type SessionStorage = ReturnType<
  typeof createCookieSessionStorage<SessionData>
>;

let _sessionStorage: SessionStorage | null = null;

function getSessionStorage(): SessionStorage {
  if (_sessionStorage) return _sessionStorage;

  const env = getEnv();
  _sessionStorage = createCookieSessionStorage<SessionData>({
    cookie: {
      name: "{cookie-name}",
      secrets: [env.SESSION_SECRET],
      sameSite: "lax",
      path: "/",
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      maxAge: 60 * 60 * 24 * 7, // 7 days
    },
  });
  return _sessionStorage;
}

export async function getSession(request: Request) {
  const storage = getSessionStorage();
  return storage.getSession(request.headers.get("Cookie"));
}

export async function commitSession(
  session: Awaited<ReturnType<typeof getSession>>
) {
  const storage = getSessionStorage();
  return storage.commitSession(session);
}

export async function destroySession(
  session: Awaited<ReturnType<typeof getSession>>
) {
  const storage = getSessionStorage();
  return storage.destroySession(session);
}

// --- User helpers ---

export async function getUser(request: Request): Promise<AuthUser | null> {
  const session = await getSession(request);
  const user = session.get("user");
  if (!user || !user.sub) return null;
  return user as AuthUser;
}

export async function requireUser(request: Request): Promise<AuthUser> {
  const user = await getUser(request);
  if (!user) throw redirect("/login");
  return user;
}

// --- Reverse Proxy URL ---

/** request에서 origin URL을 추출 (리버스 프록시 + 멀티 도메인 지원) */
function getAppUrl(request: Request): string {
  // production에서는 항상 https (Traefik chain 노드가 X-Forwarded-Proto: http를 보냄)
  const proto =
    process.env.NODE_ENV === "production"
      ? "https"
      : (request.headers.get("X-Forwarded-Proto") ||
          new URL(request.url).protocol.replace(":", ""));
  const host =
    request.headers.get("X-Forwarded-Host") ||
    request.headers.get("Host") ||
    new URL(request.url).host;
  return `${proto}://${host}`;
}

// --- OIDC Flow ---

function generateState(): string {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return Array.from(array, (b) => b.toString(16).padStart(2, "0")).join("");
}

export async function getAuthorizationUrl(request: Request) {
  const env = getEnv();
  const state = generateState();

  const session = await getSession(request);
  session.set("oauth_state", state);

  const appUrl = getAppUrl(request);
  const params = new URLSearchParams({
    client_id: env.AUTHENTIK_CLIENT_ID,
    response_type: "code",
    redirect_uri: `${appUrl}/api/auth/callback/authentik`,
    scope: "openid email profile",
    state,
  });

  return {
    url: `${AUTHORIZE_URL}?${params.toString()}`,
    cookie: await commitSession(session),
  };
}

export async function handleCallback(request: Request) {
  const env = getEnv();
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");

  if (!code || !state) {
    throw new Response("Missing code or state parameter", { status: 400 });
  }

  // Verify state
  const session = await getSession(request);
  const savedState = session.get("oauth_state");
  if (state !== savedState) {
    throw new Response("Invalid state parameter", { status: 400 });
  }
  session.unset("oauth_state");

  // Exchange code for tokens
  const appUrl = getAppUrl(request);
  const tokenResponse = await fetch(TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "authorization_code",
      code,
      redirect_uri: `${appUrl}/api/auth/callback/authentik`,
      client_id: env.AUTHENTIK_CLIENT_ID,
      client_secret: env.AUTHENTIK_CLIENT_SECRET,
    }),
  });

  if (!tokenResponse.ok) {
    const error = await tokenResponse.text();
    console.error("Token exchange failed:", error);
    throw new Response("Authentication failed", { status: 401 });
  }

  const tokens = (await tokenResponse.json()) as {
    access_token: string;
    id_token: string;
  };

  // Fetch user info
  const userInfoResponse = await fetch(USERINFO_URL, {
    headers: { Authorization: `Bearer ${tokens.access_token}` },
  });

  if (!userInfoResponse.ok) {
    console.error("UserInfo fetch failed:", await userInfoResponse.text());
    throw new Response("Failed to fetch user info", { status: 401 });
  }

  const userInfo = (await userInfoResponse.json()) as {
    sub: string;
    email: string;
    name: string;
    groups: string[];
  };

  const user: AuthUser = {
    sub: userInfo.sub,
    email: userInfo.email,
    name: userInfo.name || userInfo.email,
    groups: userInfo.groups || [],
  };

  session.set("user", user);

  return {
    cookie: await commitSession(session),
  };
}
```

### 주요 포인트

| 항목 | 설명 |
|------|------|
| **`SessionData` 인터페이스** | `createCookieSessionStorage<SessionData>`에 제네릭으로 전달해야 `session.get("user")`가 타입 안전 |
| **lazy init 패턴** | `getSessionStorage()`에서 `_sessionStorage`를 lazy init — 모듈 로드 시점에 env 접근 방지 |
| **state 검증** | CSRF 방어. 세션에 저장한 state와 callback의 state 비교 후 `session.unset("oauth_state")` |
| **redirect_uri** | `getAppUrl(request)` 동적 생성 — 멀티 도메인 지원. Authentik Blueprint에 모든 도메인 등록 필요 |
| **getAppUrl()** | 리버스 프록시 환경에서 `request.url`이 내부 주소(localhost) 반환 문제 해결. production은 `https` 강제 |

---

## Phase 3: 라우트 파일 생성

### 3-1. 로그인 페이지 (`routes/login.tsx`)

- [ ] `app/routes/login.tsx` 생성

```typescript
import { redirect } from "react-router";
import type { Route } from "./+types/login";
import { getUser } from "~/lib/auth.server";

export function meta({}: Route.MetaArgs) {
  return [{ title: "로그인 - {앱 이름}" }];
}

export async function loader({ request }: Route.LoaderArgs) {
  const user = await getUser(request);
  if (user) throw redirect("/");

  const url = new URL(request.url);
  const error = url.searchParams.get("error");
  return { error };
}

export default function LoginPage({ loaderData }: Route.ComponentProps) {
  const { error } = loaderData;

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-lg p-8 w-full max-w-sm text-center">
        <div className="text-4xl mb-4">🏥</div>
        <h1 className="text-xl font-bold text-gray-800 mb-1">
          {앱 이름}
        </h1>
        <p className="text-sm text-gray-500 mb-8">{앱 설명}</p>

        {error && (
          <div className="mb-6 rounded-lg bg-red-50 border border-red-200 p-4 text-left">
            <p className="text-sm font-medium text-red-800">접근 권한이 없습니다</p>
            <p className="mt-1 text-xs text-red-600">
              관리자에게 승인을 요청해 주세요.
            </p>
          </div>
        )}

        <a
          href="/auth/login"
          className="inline-flex items-center justify-center gap-2 w-full rounded-lg bg-blue-600 px-4 py-3 text-sm font-medium text-white hover:bg-blue-700 transition"
        >
          {/* Google 아이콘 SVG */}
          Google로 로그인
        </a>

        <p className="mt-6 text-xs text-gray-400">
          관리자 승인이 필요합니다
        </p>
      </div>
    </div>
  );
}
```

> **UX 핵심:** `?error` 쿼리 파라미터가 있을 때 에러 배너를 표시한다.
> 그룹 미소속 사용자가 Google 인증 후 돌아왔을 때 이 배너가 보인다.

### 3-2. Authentik 리다이렉트 (`routes/auth.login.ts`)

- [ ] `app/routes/auth.login.ts` 생성

```typescript
import { redirect } from "react-router";
import type { Route } from "./+types/auth.login";
import { getAuthorizationUrl } from "~/lib/auth.server";

export async function loader({ request }: Route.LoaderArgs) {
  const { url, cookie } = await getAuthorizationUrl(request);
  throw redirect(url, { headers: { "Set-Cookie": cookie } });
}
```

> `throw redirect()`로 state가 담긴 세션 쿠키를 설정하면서 Authentik authorize URL로 리다이렉트.

### 3-3. OIDC Callback (`routes/auth.callback.ts`)

- [ ] `app/routes/auth.callback.ts` 생성

```typescript
import { redirect } from "react-router";
import type { Route } from "./+types/auth.callback";
import { handleCallback } from "~/lib/auth.server";

export async function loader({ request }: Route.LoaderArgs) {
  // Authentik sends error param when access is denied (e.g. user not in group)
  const url = new URL(request.url);
  const error = url.searchParams.get("error");
  if (error) {
    const desc = url.searchParams.get("error_description") || error;
    throw redirect(`/login?error=${encodeURIComponent(desc)}`);
  }

  const { cookie } = await handleCallback(request);
  throw redirect("/", { headers: { "Set-Cookie": cookie } });
}
```

> **UX 핵심:** Authentik이 접근 거부 시 `?error=access_denied&error_description=...`을 보낸다.
> 이를 감지해서 `/login?error=...`로 리다이렉트하면 Authentik 화면이 사용자에게 노출되지 않는다.

### 3-4. 로그아웃 (`routes/auth.logout.ts`)

- [ ] `app/routes/auth.logout.ts` 생성

```typescript
import { redirect } from "react-router";
import type { Route } from "./+types/auth.logout";
import { getSession, destroySession } from "~/lib/auth.server";

export async function action({ request }: Route.ActionArgs) {
  const session = await getSession(request);
  const cookie = await destroySession(session);

  throw redirect("/login", { headers: { "Set-Cookie": cookie } });
}
```

> **`action` (POST)으로 구현.** 로그아웃은 부작용이므로 GET이 아닌 POST.
> Authentik end-session URL로 가지 **않고** 바로 `/login`으로 리다이렉트 — 사용자가 다른 사이트로 튕기는 느낌 방지.

---

## Phase 4: 라우트 등록 + 인증 가드

### 4-1. `routes.ts`에 인증 라우트 등록

- [ ] `app/routes.ts` 수정

```typescript
import { type RouteConfig, index, route } from "@react-router/dev/routes";

export default [
  index("routes/home.tsx"),
  // ... 기존 라우트 ...
  route("login", "routes/login.tsx"),
  route("auth/login", "routes/auth.login.ts"),
  route("api/auth/callback/authentik", "routes/auth.callback.ts"),
  route("auth/logout", "routes/auth.logout.ts"),
] satisfies RouteConfig;
```

> Callback 경로 `api/auth/callback/authentik`은 Authentik Blueprint의 `redirect_uris`와 일치해야 한다.

### 4-2. `root.tsx`에 글로벌 인증 + 역할 가드

- [ ] `app/root.tsx` loader 수정

```typescript
import { redirect } from "react-router";
import { getUser } from "~/lib/auth.server";

const PUBLIC_PATHS = ["/login", "/auth/", "/api/auth/"];
const APPROVAL_EXEMPT_PATHS = [...PUBLIC_PATHS, "/pending", "/banned"];

export async function loader({ request }: Route.LoaderArgs) {
  const url = new URL(request.url);
  const isPublic = PUBLIC_PATHS.some((p) => url.pathname.startsWith(p));

  if (isPublic) {
    return { user: null };
  }

  const user = await getUser(request);
  if (!user) {
    throw redirect("/login");
  }

  // 정지 사용자 → /banned
  const isBanned = user.groups.includes("{app}-users-banned");
  if (isBanned && !url.pathname.startsWith("/banned")) {
    throw redirect("/banned");
  }

  // 미승인 사용자 → /pending
  const isApproved = user.groups.includes("{app}-users");
  const isExempt = APPROVAL_EXEMPT_PATHS.some((p) =>
    url.pathname.startsWith(p)
  );
  if (!isApproved && !isExempt) {
    throw redirect("/pending");
  }

  // 관리자 전용 경로
  if (url.pathname.startsWith("/admin")) {
    if (!user.groups.includes("{app}-admins")) {
      throw redirect("/");
    }
  }

  return { user };
}
```

> **역할 분기 순서:** banned → approved → admin (우선순위 순).
> banned 체크를 먼저 하여 banned이면서 다른 그룹에도 속한 경우를 처리.

### 4-3. 페이지 loader에서 `requireUser` 사용

- [ ] 인증이 필요한 페이지의 loader 수정

```typescript
import { requireUser } from "~/lib/auth.server";

export async function loader({ request }: Route.LoaderArgs) {
  const user = await requireUser(request);
  return { user };
}
```

### 4-4. 헤더에 사용자 정보 + 로그아웃 버튼

- [ ] 앱 헤더 컴포넌트에 추가

```tsx
{user && (
  <div className="flex items-center gap-2 text-sm text-gray-600">
    <span className="hidden sm:inline">{user.name}</span>
    <form method="post" action="/auth/logout">
      <button
        type="submit"
        className="px-2 py-1 rounded text-gray-500 hover:text-gray-700 hover:bg-gray-100 transition text-xs"
      >
        로그아웃
      </button>
    </form>
  </div>
)}
```

> `<form method="post">`로 logout action을 트리거. `<a>` 태그가 아닌 form submit.

---

## Phase 5: 사용자 관리 (역할 변경 + 관리자 페이지)

### 5-1. Authentik Admin API 서버 모듈 (`lib/authentik-admin.server.ts`)

- [ ] `app/lib/authentik-admin.server.ts` 생성 — Authentik Admin API 래퍼

```typescript
const AUTHENTIK_API_BASE = "https://auth.codepoet.site/api/v3";

// API 토큰은 Portainer Stack Variables로 주입
function getApiToken(): string {
  const token = process.env.AUTHENTIK_API_TOKEN;
  if (!token) throw new Error("Missing AUTHENTIK_API_TOKEN");
  return token;
}

export type UserRole = "pending" | "user" | "admin" | "banned";

const ROLE_GROUPS: Record<UserRole, string> = {
  pending: "{app}-users-pending",
  user: "{app}-users",
  admin: "{app}-admins",
  banned: "{app}-users-banned",
};

export interface UserWithRole {
  pk: number;
  username: string;
  name: string;
  email: string;
  is_active: boolean;
  role: UserRole;
}
```

**핵심 함수:**

| 함수 | 설명 |
|------|------|
| `getAllUsers()` | 4개 그룹 조회 → 중복 제거 → 역할 결정 → `UserWithRole[]` |
| `changeUserRole(userPk, newRole)` | 모든 그룹에서 제거 → 대상 그룹에 추가 |

**역할 결정 우선순위:** banned > admin > user > pending

**admin 역할 특수 처리:** admin으로 변경 시 `{app}-users` + `{app}-admins` 두 그룹 모두에 추가.
(admin은 승인된 사용자이기도 하므로)

### 5-2. 역할 변경 API (`routes/api.admin.change-role.ts`)

- [ ] `app/routes/api.admin.change-role.ts` 생성

```typescript
// POST /api/admin/change-role
// body: { userPk: number, newRole: UserRole }
// → changeUserRole(userPk, newRole) → { success: true }
```

- admin 그룹 체크로 권한 검증
- fetcher.Form으로 호출 (페이지 새로고침 없음)

### 5-3. 관리자 페이지 (`routes/admin.tsx`)

- [ ] `app/routes/admin.tsx` 생성

**UI 구성:**
- 상단: 제목 + 새로고침 버튼 + 돌아가기
- 검색: 이름/이메일 실시간 필터
- 필터 탭: 전체 | 보류 | 사용자 | 관리자 | 정지 (각 카운트 표시)
- 사용자 테이블: 이름/이메일 | 역할 배지 | 변경 버튼들
- 본인은 역할 변경 불가 ("본인" 표시)
- Optimistic UI: 변경 중 즉시 새 역할 배지 표시

### 5-4. 보류/정지 페이지

- [ ] `app/routes/pending.tsx` — "가입 보류중" 안내 + 승인 상태 확인 링크
- [ ] `app/routes/banned.tsx` — "이용 정지" 안내 + 로그아웃 버튼

### 5-5. 라우트 등록 (`routes.ts`)

```typescript
route("pending", "routes/pending.tsx"),
route("banned", "routes/banned.tsx"),
route("admin", "routes/admin.tsx"),
route("api/admin/approve", "routes/api.admin.approve.ts"),
route("api/admin/change-role", "routes/api.admin.change-role.ts"),
```

---

## Phase 6: 환경변수 + docker-compose 수정

### 6-1. 앱에 필요한 환경변수

| 변수 | 출처 | 예시 |
|------|------|------|
| `AUTHENTIK_ISSUER` | 고정값 | `https://auth.codepoet.site/application/o/{app-slug}` |
| `AUTHENTIK_CLIENT_ID` | Authentik Provider 조회값 | `u0AHlbvhoW...` |
| `AUTHENTIK_CLIENT_SECRET` | Authentik Provider 조회값 | `j5II03IFg9...` |
| `SESSION_SECRET` | 랜덤 생성 | `openssl rand -hex 32` |
| `AUTHENTIK_API_TOKEN` | Authentik Admin API 토큰 | 역할 변경 API용 |

> `APP_URL` 불필요 — `getAppUrl(request)`가 동적으로 생성.

### 6-2. Vault에 시크릿 저장

```bash
ssh codepoet-mac-mini-1 "export PATH=\$PATH:/usr/local/bin && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault \
  vault kv put -mount=secret portainer/{app-slug} \
  AUTHENTIK_CLIENT_ID=xxx \
  AUTHENTIK_CLIENT_SECRET=xxx \
  SESSION_SECRET=\$(openssl rand -hex 32) \
  AUTHENTIK_API_TOKEN=xxx"
```

### 6-3. docker-compose.yml 수정

```yaml
services:
  {app}:
    environment:
      - AUTHENTIK_ISSUER=https://auth.codepoet.site/application/o/{app-slug}
      - AUTHENTIK_CLIENT_ID=${AUTHENTIK_CLIENT_ID}
      - AUTHENTIK_CLIENT_SECRET=${AUTHENTIK_CLIENT_SECRET}
      - SESSION_SECRET=${SESSION_SECRET}
      - AUTHENTIK_API_TOKEN=${AUTHENTIK_API_TOKEN}
    labels:
      # 내부 접근 (인증은 앱에서 처리)
      - "traefik.http.routers.{app}-internal.rule=Host(`{app-slug}.home.codepoet.site`)"
      - "traefik.http.routers.{app}-internal.entrypoints=web"
      - "traefik.http.routers.{app}-internal.service={app}"
      # 외부 접근 (BasicAuth 제거, 앱 레벨 OIDC로 대체)
      - "traefik.http.routers.{app}-external.rule=Host(`{app-domain}`)"
      - "traefik.http.routers.{app}-external.entrypoints=web"
      - "traefik.http.routers.{app}-external.service={app}"
      # Service
      - "traefik.http.services.{app}.loadbalancer.server.port=3000"
```

> `${AUTHENTIK_CLIENT_ID}` 등은 Portainer Stack Variables로 주입된다.
> `portainer-gitops.sh`가 Vault에서 자동 로드: `secret/portainer/{app-slug}`

### 6-4. Portainer 스택 재배포

```bash
# GitLab CI 파이프라인 완료 후 (새 이미지 빌드 대기)
./scripts/portainer-gitops.sh update {app-slug}
```

---

## Phase 7: 검증

### 7-1. 신규 사용자 가입 테스트

- [ ] 신규 Google 계정으로 로그인 시도 → 자동 가입 → `/pending` 표시 확인
- [ ] Authentik에서 `{app}-users-pending` 그룹에 자동 추가됨 확인

### 7-2. 관리자 역할 변경 테스트

- [ ] `/admin` 접근 → 사용자 목록 확인
- [ ] pending → 사용자 승인 → 재로그인 시 앱 정상 접근
- [ ] 정지 처리 → 재로그인 시 `/banned` 표시
- [ ] 필터/검색 동작 확인

### 7-3. 로그인/로그아웃 테스트

- [ ] 정상 로그인 + 로그아웃
- [ ] 멀티 도메인 (`codepoet.site` / `home.codepoet.site`) 모두 동작 확인

---

## 파일 구조 요약

```
app/
├── lib/
│   ├── auth.server.ts              # 세션 + OIDC (서버 전용)
│   └── authentik-admin.server.ts   # Authentik Admin API (역할 관리)
├── routes/
│   ├── login.tsx                   # 로그인 UI + 에러 표시
│   ├── pending.tsx                 # 가입 보류 안내
│   ├── banned.tsx                  # 이용 정지 안내
│   ├── admin.tsx                   # 사용자 관리 (목록/필터/역할변경)
│   ├── auth.login.ts               # → Authentik authorize 리다이렉트
│   ├── auth.callback.ts            # ← Authentik callback 처리
│   ├── auth.logout.ts              # 세션 파괴 + /login 리다이렉트
│   ├── api.admin.approve.ts        # POST 사용자 승인 (legacy)
│   └── api.admin.change-role.ts    # POST 역할 변경
├── types/
│   └── index.ts                    # AuthUser 인터페이스 (groups 포함)
└── root.tsx                        # 글로벌 인증 + 역할 가드
```

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| `session.get("user")` 타입 에러 (`never`) | `createCookieSessionStorage`에 제네릭 미지정 | `createCookieSessionStorage<SessionData>()` |
| Callback에서 "Invalid state" | 쿠키 `sameSite` 설정 또는 도메인 불일치 | `sameSite: "lax"`, `secure: true` (프로덕션) |
| `redirect_uri=http://localhost:5173` | SSR에서 `request.url`이 컨테이너 내부 주소 | `getAppUrl(request)` 사용 — `X-Forwarded-Host` + production `https` 강제 |
| `redirect_uri=http://` (https 아님) | Traefik chain 노드가 `X-Forwarded-Proto: http` 전달 | production 환경에서 `https` 강제 (`getAppUrl()` 참조) |
| 로그인 후 다시 /login으로 | 쿠키가 설정 안 됨 | `Set-Cookie` 헤더가 redirect 응답에 포함되는지 확인 |
| Authentik "권한 거부됨" 화면 노출 | callback에서 error 파라미터 미감지 | `url.searchParams.get("error")` 체크 추가 |
| "Aborting write to empty username" | Google은 username 미제공 | Expression Policy로 `email → username` 자동 설정 (Blueprint) |
| 관리자 역할 변경 실패 | `AUTHENTIK_API_TOKEN` 미설정 | Vault에 토큰 저장 + docker-compose에 주입 |

## 현재 적용 현황

| App | 프레임워크 | Callback URI | 역할 체계 |
|-----|-----------|-------------|----------|
| Rehab CRM | React Router 7 (SSR) | `/api/auth/callback/authentik` | 4-그룹 (pending/user/admin/banned) |

## 관련 문서

| 문서 | 위치 | 내용 |
|------|------|------|
| Authentik OIDC 앱 온보딩 | `workflows/authentik-oidc-app-onboarding.md` | 인프라 측 (Google Console, Vault, Blueprint, 4-그룹 체계) |
| OIDC 연동 상세 가이드 | `my-devops/docs/guides/authentik-oidc-app-integration.md` | OIDC endpoints, Blueprint 템플릿 |
| Authentik 서비스 문서 | `my-devops/docs/services/authentik.md` | Blueprint IaC 이슈, 드리프트 관리 |
| 앱 E2E 배포 | `workflows/app-deploy-e2e.md` | 앱 빌드~Portainer 배포 전체 |
