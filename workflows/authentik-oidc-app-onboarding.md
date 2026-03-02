# Authentik OIDC 앱 온보딩 워크플로우

> 새 앱에 Authentik OIDC (Google OAuth) 인증을 연동하는 운영 워크플로우.
> **인프라 작업**(my-devops repo)과 **앱 작업**(앱 repo)을 하나의 체크리스트로 통합.
>
> 상세 구현 가이드: `my-devops/docs/guides/authentik-oidc-app-integration.md`

## 전제 조건

- Authentik이 Mac Mini 1에 배포되어 있음 (`auth.codepoet.site`)
- Vault가 unseal 상태이고 `secret/services/authentik` 경로에 접근 가능
- 앱 서비스가 이미 배포되어 있거나, 배포 준비가 되어 있음
  - 앱 배포가 안 되어 있다면 먼저 `app-deploy-e2e.md` 워크플로우 수행

## 아키텍처

```
앱 브라우저
  ├─ 앱 접속 → 로그인 필요 → authentik redirect
  ├─ Authentik 로그인 (앱 전용 flow, "Google로 로그인" 버튼)
  ├─ Google OAuth 인증
  ├─ Authentik → 앱 callback (authorization code)
  └─ 앱 백엔드: code → token → userinfo → 세션 생성
```

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

**포함 리소스 (9개):**
1. Google OAuth Source (`google-{app}`)
2. 사용자 그룹 (`{app}-users`)
3. Identification Stage (Google 버튼)
4. User Login Stage
5. Authentication Flow (`{app}-authentication`)
6. Flow-Stage Bindings (2개)
7. OIDC Provider (`{app}-oauth2`)
8. Application (`{app-slug}`)
9. Policy Binding (그룹 기반 접근 제어)

> `redirect_uris` 기본값: `/api/auth/callback/authentik` (NextAuth 패턴).
> FastAPI 등 다른 프레임워크는 이 URL을 수정하세요.

### 4-2. Blueprint 호스트 복사 + 적용

- [ ] Blueprint 파일 복사

```bash
scp blueprints/custom/{순번}-{app}.yaml \
  codepoet-mac-mini-1:/Volumes/mac-ext-storage/.authentik/blueprints/custom/
```

- [ ] Blueprint 적용

```bash
ssh codepoet-mac-mini-1 "export PATH=\$PATH:/usr/local/bin && \
  docker exec authentik-worker sh -c '
    export \$(cat /secrets/authentik.env | grep -v \"^#\" | grep -v \"^\$\" | xargs)
    export AUTHENTIK_POSTGRESQL__HOST=postgresql
    export AUTHENTIK_POSTGRESQL__USER=\$PG_USER
    export AUTHENTIK_POSTGRESQL__NAME=\$PG_DB
    export AUTHENTIK_POSTGRESQL__PASSWORD=\$PG_PASS
    export AUTHENTIK_SECRET_KEY=\$AUTHENTIK_SECRET_KEY
    ak apply_blueprint /blueprints/custom/{순번}-{app}.yaml
  '"
```

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

| 프레임워크 | Redirect URI | 핵심 설정 |
|-----------|-------------|-----------|
| **Next.js** (NextAuth) | `/api/auth/callback/authentik` (자동) | `id: "authentik"`, `type: "oidc"`, `issuer` |
| **FastAPI** (Authlib) | `/auth/callback` (커스텀) | `server_metadata_url`, Blueprint redirect_uri 수정 필요 |
| **기타** | 앱 정의 | 표준 OAuth2 Authorization Code Flow 구현 |

> 상세 코드 예시: `my-devops/docs/guides/authentik-oidc-app-integration.md` → "프레임워크별 연동 코드" 섹션

### OIDC Endpoints 참조

| Endpoint | URL |
|----------|-----|
| OpenID Configuration | `https://auth.codepoet.site/application/o/{app-slug}/.well-known/openid-configuration` |
| Authorization | `https://auth.codepoet.site/application/o/authorize/` |
| Token | `https://auth.codepoet.site/application/o/token/` |
| UserInfo | `https://auth.codepoet.site/application/o/userinfo/` |

---

## Phase 6: 검증 + 사용자 관리

### 6-1. 로그인 테스트

- [ ] 앱에서 로그인 시도 → Google 로그인 화면 표시 확인
- [ ] Google 인증 완료 → "access denied" 확인 (그룹 미할당 상태, 정상)

### 6-2. 사용자 그룹 할당

- [ ] Authentik Admin UI → Directory → Groups → `{app}-users` → Add existing user
- [ ] 재로그인 → 앱 정상 접근 확인

### 6-3. Git 정리

- [ ] Blueprint 파일을 Git에 커밋

```bash
git add services/codepoet-mac-mini-1/authentik/blueprints/custom/{순번}-{app}.yaml
git commit -m "feat: add {app} authentik OIDC blueprint"
git push origin main
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
| "access denied" | 사용자가 `{app}-users` 그룹 미소속 | Admin → Groups → 사용자 추가 |
| Google 버튼 안 보임 | Blueprint 미적용 또는 OAuth source 미연결 | `ak apply_blueprint` 재실행 |
| `!Env` 변수 비어있음 | Vault Agent 미재배포 | Phase 3-2 수행 (Portainer 스택 재배포) |
| Provider 조회 안됨 | Blueprint 적용 실패 | `ak apply_blueprint` 출력 확인, 멱등이므로 재적용 |

## 현재 등록 현황

| App | Blueprint 순번 | App Slug | OAuth Source | OIDC Provider |
|-----|---------------|----------|--------------|---------------|
| Webtoon Maker | 10 | `webtoon-maker` | `google-webtoon` | `webtoon-oauth2` |
| Rehab CRM | 11 | `rehab-crm` | `google-rehab` | `rehab-oauth2` |

## 관련 문서

| 문서 | 위치 | 내용 |
|------|------|------|
| OIDC 연동 상세 가이드 | `my-devops/docs/guides/authentik-oidc-app-integration.md` | 프레임워크별 코드, Blueprint 템플릿, OIDC endpoints |
| Authentik 서비스 문서 | `my-devops/docs/services/authentik.md` | 인프라 배포, 접근 제한, Mixed Content 해결 |
| 앱 E2E 배포 | `workflows/app-deploy-e2e.md` | 앱 빌드~Portainer 배포 전체 |
| Vault CLI | `my-devops/docs/guides/vault-cli.md` | Vault 시크릿 관리 |
