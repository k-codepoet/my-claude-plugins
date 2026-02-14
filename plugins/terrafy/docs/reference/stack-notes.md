# 스택별 운영 노트

> 각 Portainer 스택의 특이사항, 시크릿 관리 방식, 운영 시 주의점.
> Layer 정합성 점검 시 참조.

---

## NAS 볼륨 가이드라인

### 규칙

| 데이터 성격 | 볼륨 타입 | 예시 |
|------------|----------|------|
| **영속** (DB, 설정, 인증서) | 절대경로 호스트 마운트 | gitlab-ce data, adguard-home conf |
| **런타임** (매 시작 시 재생성) | named volume OK | Vault Agent secrets, traefik init config |

### 왜 절대경로인가?

Portainer GitOps는 Git repo를 NAS의 `/data/compose/{stack-id}/`에 clone한다.
따라서 compose 파일의 상대경로(`./data/`)는 clone 경로 기준으로 해석되어 실제 데이터 위치와 다르다.

```
# Portainer가 실제로 해석하는 경로:
/data/compose/105/infra/codepoet-nas/adguard-home/data/  ← 존재하지 않음

# 의도한 경로:
/volume1/workspaces/k-codepoet/my-devops/infra/codepoet-nas/adguard-home/data/
```

### 왜 named volume이 아닌가? (영속 데이터)

Synology NAS Docker의 named volume 제약:

1. **접근성**: `/volume1/@docker/volumes/`에 root 소유로 저장되어 NAS 사용자가 직접 접근/백업 불가
2. **가시성**: 데이터 위치를 compose 파일만 보고 파악할 수 없음
3. **권한 충돌**: 컨테이너가 root로 생성한 파일을 호스트의 다른 도구(vibe-kanban 등)가 접근 시 Permission denied 발생

### 런타임 볼륨은 왜 OK?

cloudflared의 `secrets-vol`, traefik-nas의 `traefik_config` 등은:
- Vault Agent/init 컨테이너가 매 시작 시 새로 생성
- 보존할 필요 없음 (재시작하면 다시 렌더링)
- 호스트에서 접근할 일 없음

### 현황

| NAS 서비스 | 영속 볼륨 | 런타임 볼륨 |
|-----------|----------|------------|
| gitlab-ce | 절대경로 호스트 마운트 | - |
| adguard-home | 절대경로 호스트 마운트 | - |
| cloudflared | - | named (secrets-vol, cloudflared_config) |
| traefik-nas | - | named (traefik_config, welcome_html) |
| portainer-agent | - | - (Docker socket만) |

---

## Layer 2

### vault (Mac Mini, GitHub 소스)

- **vault-init 컨테이너**: `restart: no`로 매 배포 시 1회 실행. 초기화 또는 auto-unseal 수행
- **credentials.json**: `/Volumes/mac-ext-storage/.vault/init/credentials.json` (chmod 600)
  - unseal keys + root token 저장
  - Vaultwarden에도 백업 보관
- **anonymous volume**: Docker 이미지가 `VOLUME /vault/file` 선언 → 미사용 anonymous volume 자동 생성됨 (무시해도 됨)
- **Portainer Stack Variables**: `VAULT_PORT`, `TZ` (기본값 있어서 미설정이어도 동작)

### vaultwarden (Mac Mini, GitLab 소스)

- **ADMIN_TOKEN 관리**: Portainer Stack Variable이 아닌 `data/config.json`에서 관리
  - admin 패널에서 설정 저장 시 config.json에 기록
  - config.json이 env var보다 우선
  - Portainer의 ADMIN_TOKEN 변수는 빈 값이어도 정상 동작
- **SMTP 크레덴셜**: config.json에 평문 저장 (Gmail 앱 비밀번호)
  - admin 패널에서 설정한 값
  - 파일 위치: `/Volumes/mac-ext-storage/.vaultwarden/data/config.json`
- **Vault 이관 불가**: 부트스트랩 순환 의존성 때문
  - Vaultwarden이 Vault unseal key를 보관하는 "시크릿의 시작점"
  - Vault Agent sidecar를 붙이면 Layer 4로 내려가서 순환 발생
- **시크릿 보호**: 파일시스템 퍼미션 + SSH 접근 제한으로 관리

---

## Layer 3

> 정합성 점검 후 추가 예정

---

## Layer 4

> 정합성 점검 후 추가 예정
