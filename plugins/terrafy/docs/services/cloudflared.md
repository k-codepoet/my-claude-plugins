# Cloudflared (Cloudflare Tunnel)

> 외부 트래픽을 내부 서비스로 전달하는 터널. NAS에서 실행.

## 위치

- **머신**: codepoet-nas (192.168.0.14)
- **라우팅**: `*.codepoet.site` → Mac Mini Traefik (:80)

## 아키텍처

```
User → *.codepoet.site → Cloudflare Edge
                              ↓ Tunnel
                        NAS (DS220+)
                        └── cloudflared
                              ↓ ingress
                        Mac Mini Traefik (.48:80)
                              ↓ chain
                        각 서비스
```

cloudflared는 NAS에서 실행되지만, 모든 트래픽을 Mac Mini Traefik(진입점)으로 전달. Mac Mini에서 TLS 종료 후 체인 라우팅.

## Vault Agent 시크릿 주입

Vault Agent sidecar가 시크릿을 렌더링:

- **Vault 경로**: `secret/data/common/cloudflare`
- **렌더링 파일**: `/secrets/cloudflared.env`
- **주입 값**: TUNNEL_ID, TUNNEL_SECRET, ACCOUNT_TAG

init-config 컨테이너가 렌더링된 값으로 `config.yml`과 `credentials.json` 생성.

## 볼륨

모두 런타임 볼륨 (named volume):

| 볼륨 | 용도 |
|------|------|
| `cloudflared_config` | config.yml + credentials.json (매 시작 시 재생성) |
| `secrets-vol` | Vault Agent 렌더링 파일 |

> 영속 데이터 없음. 재시작 시 Vault에서 다시 가져옴.

## 초기 설정

터널 최초 생성은 cloudflared CLI가 필요 (NAS가 아닌 Mac/Linux에서):

```bash
cloudflared tunnel login
cloudflared tunnel create nas-gateway-codepoet
cloudflared tunnel route dns nas-gateway-codepoet "*.codepoet.site"
```

이후에는 Vault에 credentials 저장 → Vault Agent가 자동 주입.

## 설정 변경

| 변경 대상 | 반영 방법 |
|----------|----------|
| ingress 규칙 | docker-compose.yml의 init-config heredoc 수정 → 재배포 |
| credentials | Vault에서 갱신 → 재배포 시 자동 반영 |

## 관련 문서

- [codepoet-nas 머신 문서](../machines/codepoet-nas.md)
- [Traefik Chain 아키텍처](../../architecture/traefik-chain.md)
