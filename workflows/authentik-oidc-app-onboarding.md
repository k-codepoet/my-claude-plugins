# Authentik OIDC 앱 온보딩 워크플로우

> 새 앱에 Authentik OIDC (Google OAuth) 인증 + 사용자 승인 워크플로우를 연동하는 운영 가이드.
> **인프라 작업**(my-devops repo)과 **앱 작업**(앱 repo)을 하나의 체크리스트로 통합.
>
> 상세 구현 가이드: `my-devops/docs/guides/authentik-oidc-app-integration.md`

## 타임라인

| 날짜 | 내용 |
|------|------|
| 2026-02 | 초기 버전 — OIDC 온보딩 + BasicAuth→OIDC 전환 (Webtoon, Rehab CRM) |
| 2026-03-01 | 사용자 승인 워크플로우 추가 — 4-그룹 역할 체계, 자동 enrollment, 관리자 페이지 |
| 2026-03-02 | banned 그룹 추가 — 정지 사용자 관리, Expression Policy (email→username) 보완 |

## 전제 조건

- Authentik이 Mac Mini 1에 배포되어 있음 (`auth.codepoet.site`)
- Vault가 unseal 상태이고 `secret/services/authentik` 경로에 접근 가능
- 앱 서비스가 이미 배포되어 있거나, 배포 준비가 되어 있음
  - 앱 배포가 안 되어 있다면 먼저 `app-deploy-e2e.md` 워크플로우 수행

## 아키텍처

### 인증 흐름

```
앱 브라우저
  ├─ 앱 접속 → 로그인 필요 → authentik redirect
  ├─ Authentik 로그인 (앱 전용 flow, "Google로 로그인" 버튼)
  ├─ Google OAuth 인증
  ├─ Authentik → 앱 callback (authorization code)
  └─ 앱 백엔드: code → token → userinfo (groups 포함) → 세션 생성
```

### 사용자 승인 + 역할 관리 체계

```
신규 Google 로그인
  ├─ Authentik enrollment flow (자동)
  │   ├─ Expression Policy: email → username 자동 설정
  │   ├─ UserWriteStage: {app}-users-pending 그룹에 자동 추가
  │   └─ UserLoginStage: 세션 생성
  ├─ 앱 callback → userinfo → groups 확인
  │   ├─ {app}-users-pending 만 → /pending 페이지
  │   ├─ {app}-users → 앱 정상 접근
  │   ├─ {app}-admins → 앱 접근 + /admin 접근
  │   └─ {app}-users-banned → /banned 페이지
  └─ 관리자가 /admin에서 역할 변경 (Authentik API 호출)
```

### 4-그룹 역할 체계

| 그룹 | 용도 | 앱 동작 |
|------|------|--------|
| `{app}-users-pending` | 가입 보류 (enrollment 시 자동) | `/pending` 리다이렉트 |
| `{app}-users` | 승인된 사용자 | 앱 정상 접근 |
| `{app}-admins` | 관리자 | `/admin` 접근 가능 |
| `{app}-users-banned` | 정지 | `/banned` 리다이렉트 |

> **원칙:** OIDC 토큰은 모든 그룹에서 발급됨. 역할별 분기는 앱에서 `groups` claim으로 처리.
> admin 역할 사용자는 `{app}-users` + `{app}-admins` 두 그룹 모두 소속.

- 앱은 Google과 직접 통신하지 않음 — authentik이 중간에서 처리
- 앱별로 독립된 Google OAuth Client, 인증 flow, 사용자 그룹, OIDC provider

## 치환 변수

워크플로우 전체에서 사용하는 변수:

| 변수 | 설명 | 예시 |
|------|------|------|
| `{app}` | 앱 식별자 (소문자) | `webtoon`, `rehab` |
| `{APP}` | 환경변수 접두어 (대문자) | `WEBTOON`, `REHAB` |
| `{앱 이름}` | 전체 이름 | `Webtoon Maker`, `Rehab CRM` |
| `{app-slug}` | Application slug | `webtoon-maker`, `rehab-crm` |
| `{app-domain}` | 앱 도메인 | `webtoon-maker.codepoet.site` |

---

## Phase 1: Google Cloud Console (수동)

### 1-1. OAuth Consent Screen (최초 1회)

- [ ] Google Cloud Console → APIs & Services → OAuth consent screen
- [ ] User Type: External, Scopes: `openid`, `email`, `profile`
- 이미 설정되어 있으면 건너뜀

### 1-2. 앱 전용 OAuth Client 생성

- [ ] Credentials → Create Credentials → OAuth client ID

| 항목 | 값 |
|------|-----|
| Application type | Web application |
| Name | `Authentik - {앱 이름}` |
| Authorized JavaScript origins | `https://auth.codepoet.site` |
| Authorized redirect URIs | `https://auth.codepoet.site/source/oauth/callback/google-{app}/` |

> 끝의 `/` 필수. 앱마다 별도 Client ID 생성 (공유하지 않음).

---

## Phase 2: Vault 시크릿 저장

- [ ] Google에서 받은 Client ID / Secret을 Vault에 저장

```bash
ssh codepoet-mac-mini-1 "export PATH=\$PATH:/usr/local/bin && \
  docker exec -e VAULT_TOKEN=hvs.xxx vault \
  vault kv patch -mount=secret services/authentik \
  {APP}_GOOGLE_CLIENT_ID=xxx \
  {APP}_GOOGLE_CLIENT_SECRET=xxx"
```

---

## Phase 3: docker-compose.yml 수정 + 재배포

### 3-1. Vault Agent 템플릿에 env var 추가

- [ ] `services/codepoet-mac-mini-1/authentik/docker-compose.yml` 편집
- [ ] Vault Agent template의 `TMPL` 블록에 추가:

```
{APP}_GOOGLE_CLIENT_ID={{ with secret "secret/data/services/authentik" }}{{ .Data.data.{APP}_GOOGLE_CLIENT_ID }}{{ end }}
{APP}_GOOGLE_CLIENT_SECRET={{ with secret "secret/data/services/authentik" }}{{ .Data.data.{APP}_GOOGLE_CLIENT_SECRET }}{{ end }}
```

> `error_on_missing_key = true`이므로, 반드시 Phase 2 완료 후 진행.

### 3-2. Git push + Portainer 재배포

- [ ] Git push

```bash
git add services/codepoet-mac-mini-1/authentik/docker-compose.yml
git commit -m "feat: add {app} Google OAuth vars to authentik vault template"
git push origin main
```

- [ ] Portainer 스택 재배포 (아래 중 택 1)
  - **Portainer UI** → Stacks → authentik → "Pull and redeploy" (권장, 안전)
  - **CLI**: `./scripts/portainer-gitops.sh update authentik` (DELETE + RECREATE 방식, 주의)

- [ ] Vault Agent 로그 확인

```bash
ssh codepoet-mac-mini-1 "docker logs authentik-vault-agent --tail 5"
# "Secrets file created successfully" 확인
```

---

## Phase 4: Blueprint 작성 + 배포

### 4-1. Blueprint YAML 작성

- [ ] `services/codepoet-mac-mini-1/authentik/blueprints/custom/{순번}-{app-name}.yaml` 생성
- 기존 `10-webtoon-maker.yaml`을 복사하여 변수만 치환
- 순번은 기존 마지막 +1 (현재: 10-webtoon, 11-rehab → 다음 12-xxx)

**포함 리소스:**

| # | 리소스 | ID 패턴 | 설명 |
|---|--------|---------|------|
| 1 | Google OAuth Source | `google-{app}` | enrollment_flow → 자동 가입 flow |
| 2 | 사용자 그룹 (4개) | `{app}-users-pending`, `{app}-users`, `{app}-admins`, `{app}-users-banned` | 4-역할 체계 |
| 3 | Expression Policy | `{app}-set-username-from-email` | Google은 username 미제공 → email을 username으로 설정 |
| 4 | User Write Stage | `{app}-user-write` | `create_users_group: {app}-users-pending`, `user_creation_mode: always_create` |
| 5 | User Login Stage (enrollment) | `{app}-enrollment-login` | 가입 후 세션 생성 |
| 6 | Enrollment Flow | `{app}-enrollment` | Write → Login (prompt 없음, 자동 가입) |
| 7 | Flow-Stage Bindings | - | enrollment flow에 write(10) → login(20) 바인딩 |
| 8 | Policy Binding (expression) | - | expression policy → write stage binding (username 채움) |
| 9 | Identification Stage | `{app}-identification` | `user_fields: []`, `sources: [google-{app}]` → Google 버튼만 표시 |
| 10 | User Login Stage (auth) | `{app}-login` | 인증 후 세션 생성 |
| 11 | Authentication Flow | `{app}-authentication` | Identification → Login |
| 12 | OIDC Provider | `{app}-oauth2` | `authentication_flow: {app}-authentication` |
| 13 | Application | `{app-slug}` | `policy_engine_mode: any` |
| 14 | Policy Bindings (4개) | - | 4개 그룹 모두 OIDC 접근 허용 (앱에서 역할별 분기) |

> `redirect_uris` 기본값: `/api/auth/callback/authentik` (React Router 7 패턴).
> FastAPI 등 다른 프레임워크는 이 URL을 수정하세요.
> 참고 Blueprint 템플릿: `11-rehab-crm.yaml` (가장 최신, 4-그룹 + enrollment + expression policy 포함)

### 4-2. Blueprint 호스트 동기화

- [ ] Blueprint 파일 동기화 (스크립트 사용 권장)

```bash
# 전체 Blueprint 동기화 (MD5 비교, 변경분만 복사)
./scripts/sync-blueprints.sh

# 변경 사항만 확인 (dry run)
./scripts/sync-blueprints.sh --dry
```

또는 수동 복사:

```bash
scp services/codepoet-mac-mini-1/authentik/blueprints/custom/{순번}-{app}.yaml \
  codepoet-mac-mini-1:/Volumes/mac-ext-storage/.authentik/blueprints/custom/
```

- [ ] Blueprint 적용: Worker가 자동 감지하여 적용 (재시작 시). 즉시 적용하려면:

```bash
# Portainer UI → authentik 스택 → worker 컨테이너만 재시작
# 또는 API 호출로 Blueprint instance 조회 후 sync 실행
```

> **주의:** `ak apply_blueprint`은 Secret Key 미주입 이슈로 실패할 수 있음.
> 상세: `my-devops/docs/services/authentik.md` → "Blueprint IaC 알려진 이슈"
> Blueprint은 멱등 — 수정 후 다시 적용하면 기존 리소스 업데이트됨.

### 4-3. OIDC Client 자격증명 조회

- [ ] `client_id` / `client_secret` 조회

```bash
ssh codepoet-mac-mini-1 "export PATH=\$PATH:/usr/local/bin && \
  docker exec authentik-worker sh -c '
    export \$(cat /secrets/authentik.env | grep -v \"^#\" | grep -v \"^\$\" | xargs)
    export AUTHENTIK_POSTGRESQL__HOST=postgresql
    export AUTHENTIK_POSTGRESQL__USER=\$PG_USER
    export AUTHENTIK_POSTGRESQL__NAME=\$PG_DB
    export AUTHENTIK_POSTGRESQL__PASSWORD=\$PG_PASS
    export AUTHENTIK_SECRET_KEY=\$AUTHENTIK_SECRET_KEY
    ak shell -c \"
from authentik.providers.oauth2.models import OAuth2Provider
p = OAuth2Provider.objects.get(name=\\\"{app}-oauth2\\\")
print(f\\\"client_id:     {p.client_id}\\\")
print(f\\\"client_secret: {p.client_secret}\\\")
\"
  '"
```

- [ ] 이 값을 앱 환경변수에 기록

---

## Phase 5: 앱 OIDC 연동

### 앱 환경변수 설정

- [ ] 앱에 아래 환경변수 설정:

```env
AUTHENTIK_ISSUER=https://auth.codepoet.site/application/o/{app-slug}
AUTHENTIK_CLIENT_ID={Phase 4-3에서 조회한 값}
AUTHENTIK_CLIENT_SECRET={Phase 4-3에서 조회한 값}
```

### 프레임워크별 연동

| 프레임워크 | Redirect URI | 핵심 설정 | 상세 워크플로우 |
|-----------|-------------|-----------|--------------|
| **React Router 7** (SSR) | `/api/auth/callback/authentik` | 직접 구현 (라이브러리 없음) | → [**react-router-7-oidc-implementation.md**](authentik/react-router-7-oidc-implementation.md) |
| **Next.js** (NextAuth) | `/api/auth/callback/authentik` (자동) | `id: "authentik"`, `type: "oidc"`, `issuer` | |
| **FastAPI** (Authlib) | `/auth/callback` (커스텀) | `server_metadata_url`, Blueprint redirect_uri 수정 필요 | |
| **기타** | 앱 정의 | 표준 OAuth2 Authorization Code Flow 구현 | |

> 상세 코드 예시: `my-devops/docs/guides/authentik-oidc-app-integration.md` → "프레임워크별 연동 코드" 섹션

### OIDC Endpoints 참조

| Endpoint | URL |
|----------|-----|
| OpenID Configuration | `https://auth.codepoet.site/application/o/{app-slug}/.well-known/openid-configuration` |
| Authorization | `https://auth.codepoet.site/application/o/authorize/` |
| Token | `https://auth.codepoet.site/application/o/token/` |
| UserInfo | `https://auth.codepoet.site/application/o/userinfo/` |

---

## Phase 6: 검증

### 6-1. 신규 사용자 가입 테스트

- [ ] 앱에서 처음 로그인 시도 → Google 로그인 화면 표시 확인
- [ ] Google 인증 완료 → **자동 가입** → `/pending` 페이지 표시 확인
- [ ] Authentik에서 사용자가 `{app}-users-pending` 그룹에 자동 추가됨 확인

### 6-2. 관리자 승인 테스트

- [ ] 관리자 계정으로 로그인 → `/admin` 접근
- [ ] 사용자 목록에서 pending 사용자 확인 → "사용자" 버튼 클릭 (역할 변경)
- [ ] 해당 사용자 재로그인 → 앱 정상 접근 확인

### 6-3. 역할 변경 테스트

- [ ] `/admin`에서 각 역할(보류/사용자/관리자/정지) 변경 확인
- [ ] 정지 사용자 로그인 시 `/banned` 페이지 표시 확인
- [ ] 검색 및 필터 기능 동작 확인

### 6-4. 초기 관리자 설정

- [ ] Authentik Admin API로 초기 관리자 그룹 할당

```bash
# 관리자 유저를 {app}-admins + {app}-users 두 그룹에 추가
curl -X POST -H "Authorization: Bearer $TOKEN" \
  "https://auth.codepoet.site/api/v3/core/groups/{admins-pk}/add_user/" \
  -d '{"pk": USER_PK}'
curl -X POST -H "Authorization: Bearer $TOKEN" \
  "https://auth.codepoet.site/api/v3/core/groups/{users-pk}/add_user/" \
  -d '{"pk": USER_PK}'
```

### 6-5. Git 정리

- [ ] Blueprint 파일을 Git에 커밋

```bash
git add services/codepoet-mac-mini-1/authentik/blueprints/custom/{순번}-{app}.yaml
git commit -m "feat: add {app} authentik OIDC blueprint"
git push origin main
```

- [ ] Blueprint 호스트 동기화

```bash
./scripts/sync-blueprints.sh
```

---

## Phase 7: 문서 업데이트

- [ ] `docs/services/authentik.md` → "현재 등록된 앱" 테이블에 추가
- [ ] `docs/guides/authentik-oidc-app-integration.md` → "현재 등록된 앱별 정보"에 추가
- [ ] `docs/reference/secrets-structure.md` → Vault 키 추가

---

## 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| Google "redirect_uri_mismatch" | Google Console의 redirect URI 불일치 | `https://auth.codepoet.site/source/oauth/callback/google-{app}/` (끝 `/` 필수) |
| Authentik "redirect URI not valid" | Blueprint redirect_uri ≠ 앱 callback URL | `matching_mode: strict` — 정확히 일치 필요 |
| Google 버튼 안 보이고 ID/PW 입력창 표시 | Identification Stage `user_fields` 비어있지 않음 | `user_fields: []` + `sources: [google-{app}]` 설정 확인 |
| "Aborting write to empty username" | Google은 username 미제공 → UserWriteStage 실패 | Expression Policy로 `email → username` 자동 설정 필요 (Blueprint 참조) |
| 가입 후 /pending 대신 "access denied" | Policy Binding에 pending 그룹 누락 | 4개 그룹 모두 OIDC 접근 허용 필요 (앱에서 분기) |
| `ak apply_blueprint` "Secret key missing" | `docker exec`가 Vault Agent 환경변수 미상속 | API 직접 호출 또는 worker 재시작으로 대체 |
| `!Env` 변수 비어있음 | Vault Agent 미재배포 | Phase 3-2 수행 (Portainer 스택 재배포) |
| 리버스 프록시 뒤 `redirect_uri=http://localhost` | SSR 앱에서 `request.url`이 컨테이너 내부 주소 반환 | `X-Forwarded-Host`/`Host` 헤더 사용, production에서 `https` 강제 |
| Blueprint 호스트 파일과 Git 불일치 | 수동 편집 후 sync 안 함 | `./scripts/sync-blueprints.sh` 실행 |

## 현재 등록 현황

| App | Blueprint 순번 | App Slug | OAuth Source | OIDC Provider | 역할 체계 |
|-----|---------------|----------|--------------|---------------|----------|
| Webtoon Maker | 10 | `webtoon-maker` | `google-webtoon` | `webtoon-oauth2` | 단일 그룹 (legacy) |
| Rehab CRM | 11 | `rehab-crm` | `google-rehab` | `rehab-oauth2` | 4-그룹 (pending/user/admin/banned) |

> Webtoon Maker는 아직 4-그룹 체계 미적용. `11-rehab-crm.yaml`을 참조하여 마이그레이션 가능.

## 관련 문서

| 문서 | 위치 | 내용 |
|------|------|------|
| React Router 7 OIDC 구현 | `workflows/authentik/react-router-7-oidc-implementation.md` | 앱 코드 구현 (auth + 역할 관리 + admin 페이지) |
| OIDC 연동 상세 가이드 | `my-devops/docs/guides/authentik-oidc-app-integration.md` | 프레임워크별 코드, Blueprint 템플릿, OIDC endpoints |
| Authentik 서비스 문서 | `my-devops/docs/services/authentik.md` | 인프라 배포, Blueprint IaC 이슈, 드리프트 관리 |
| 앱 E2E 배포 | `workflows/app-deploy-e2e.md` | 앱 빌드~Portainer 배포 전체 |
| Vault CLI | `my-devops/docs/guides/vault-cli.md` | Vault 시크릿 관리 |
