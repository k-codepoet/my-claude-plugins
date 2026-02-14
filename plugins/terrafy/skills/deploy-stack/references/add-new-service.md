# Adding New Services

> 새 서비스를 홈랩에 추가하는 방법

## 빠른 시작

1. 인프라: `infra/codepoet-{device}/{service}/docker-compose.yml` 작성
   서비스: `services/codepoet-{device}/{service}/docker-compose.yml` 작성
2. Traefik labels 추가
3. `scripts/portainer-gitops.sh`의 `STACKS` 배열에 추가
4. Git push 후 `./scripts/portainer-gitops.sh create {service}` 실행

## docker-compose.yml 템플릿

### Mac Mini / Linux

```yaml
services:
  myservice:
    image: myimage:latest
    container_name: myservice
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      # 외부 공개
      - "traefik.http.routers.myservice.rule=Host(`myservice.codepoet.site`)"
      - "traefik.http.routers.myservice.entrypoints=web,websecure"
      # 내부 전용
      - "traefik.http.routers.myservice-home.rule=Host(`myservice.home.codepoet.site`)"
      - "traefik.http.routers.myservice-home.entrypoints=web"
      # 서비스 포트
      - "traefik.http.services.myservice.loadbalancer.server.port=8080"
    networks:
      - traefik

networks:
  traefik:
    external: true
```

### NAS

```yaml
services:
  myservice:
    image: myimage:latest
    container_name: myservice
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myservice.rule=Host(`myservice.home.codepoet.site`)"
      - "traefik.http.routers.myservice.entrypoints=web"
      - "traefik.http.services.myservice.loadbalancer.server.port=8080"
    networks:
      - gateway
    volumes:
      # NAS 영속 데이터는 절대경로 호스트 마운트 (Portainer GitOps는 상대경로 불가)
      - /volume1/workspaces/k-codepoet/my-devops/infra/codepoet-nas/myservice/data/config:/etc/myservice
      - /volume1/workspaces/k-codepoet/my-devops/infra/codepoet-nas/myservice/data/data:/var/lib/myservice

networks:
  gateway:
    external: true
```

## Vault 연동 (Secrets 필요 시)

### 1. Vault에 secrets 저장

```bash
ssh codepoet-mac-mini-1 "docker exec -e VAULT_TOKEN=hvs.xxx vault \
  vault kv put secret/services/myservice \
  DB_PASSWORD=xxx \
  API_KEY=yyy"
```

### 2. AppRole 생성

```bash
# Policy
ssh codepoet-mac-mini-1 "echo 'path \"secret/data/services/myservice\" { capabilities = [\"read\"] }' | \
  docker exec -i -e VAULT_TOKEN=hvs.xxx vault vault policy write myservice-policy -"

# AppRole
ssh codepoet-mac-mini-1 "docker exec -e VAULT_TOKEN=hvs.xxx vault \
  vault write auth/approle/role/myservice \
  token_policies=myservice-policy token_ttl=1h token_max_ttl=4h"

# Role ID, Secret ID 확인
ssh codepoet-mac-mini-1 "docker exec -e VAULT_TOKEN=hvs.xxx vault \
  vault read auth/approle/role/myservice/role-id"
ssh codepoet-mac-mini-1 "docker exec -e VAULT_TOKEN=hvs.xxx vault \
  vault write -f auth/approle/role/myservice/secret-id"
```

### 3. docker-compose.yml에 Vault Agent 추가

`docs/architecture/vault-agent.md` 참조

### 4. Portainer Stack Variables 설정

- `VAULT_ROLE_ID`: Role ID
- `VAULT_SECRET_ID`: Secret ID

## 스크립트 등록

`scripts/portainer-gitops.sh`의 `STACKS` 배열에 추가:

```bash
STACKS=(
    # 기존 스택들...

    # 새 서비스 (서비스 스택은 기본 GitLab 소스)
    myservice "mac-mini:services/codepoet-mac-mini-1/myservice/docker-compose.yml"
    # 인프라 스택은 :github 접미사 추가
    # myinfra "mac-mini:infra/codepoet-mac-mini-1/myinfra/docker-compose.yml:github"
)
```

## 배포

```bash
# Vault 토큰 설정
export VAULT_TOKEN='hvs.xxxxx'

# 스택 생성
./scripts/portainer-gitops.sh create myservice
```

## 포트 할당

새 서비스는 20000번대 포트 사용:

| Range | Purpose |
|-------|---------|
| 20000-20999 | SSH/Git |
| 23000-23999 | Monitoring |
| 24000-24999 | Orchestration |
| 25000-25999 | Automation |
| 29000-29999 | Management |

상세: `docs/reference/ports.md`

## 스토리지

### Mac Mini

```
/Volumes/mac-ext-storage/.<service-name>/
```

### NAS

```
/volume1/workspaces/k-codepoet/my-devops/{infra|services}/codepoet-nas/{service}/data/
```

**주의:** Portainer GitOps는 repo를 `/data/compose/`에 clone → 상대경로(`./data/`) 불가, 절대경로 필수.
영속 데이터만 호스트 마운트. 런타임 전용(Vault secrets 등)은 named volume OK.
상세: `docs/reference/stack-notes.md#NAS 볼륨 가이드라인`

## 검증

```bash
# 서비스 상태 확인
docker ps | grep myservice

# 로그 확인
docker logs myservice

# 접속 테스트
curl -I https://myservice.codepoet.site
curl -I https://myservice.home.codepoet.site
```
