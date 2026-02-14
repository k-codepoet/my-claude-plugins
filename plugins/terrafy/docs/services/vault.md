# Vault (HashiCorp)

> 시크릿 관리 중앙 서버. Mac Mini 1에서 실행.

## 위치

- **머신**: codepoet-mac-mini-1 (192.168.0.48)
- **접속**: http://192.168.0.48:28200 (내부 전용)
- **Traefik**: https://vault.home.codepoet.site

## vault-init 컨테이너

`restart: no`로 매 배포 시 1회 실행:

- **최초 실행**: 초기화 → unseal keys + root token 저장 → auto-unseal
- **이후 실행**: sealed 여부 확인 → 필요시 auto-unseal (저장된 키 사용)

## credentials.json

- **위치**: `/Volumes/mac-ext-storage/.vault/init/credentials.json`
- **권한**: chmod 600 (owner read/write only)
- **내용**: unseal keys + root token
- **백업**: Vaultwarden에도 보관

## 데이터 저장

```
/Volumes/mac-ext-storage/.vault/
├── data/                    # Vault 데이터 (file backend)
├── logs/                    # Audit 로그
├── init/credentials.json    # 초기화 정보 (chmod 600)
└── config/vault.hcl         # Vault 설정 파일
```

## Anonymous Volume 이슈

Docker 이미지가 `VOLUME /vault/file`을 선언 → 미사용 anonymous volume 자동 생성됨. 무시해도 됨.

## Vaultwarden 순환 의존성

Vault ↔ Vaultwarden 간 순환 의존성 존재:

- Vaultwarden이 Vault unseal key를 보관 ("시크릿의 시작점")
- Vault Agent sidecar를 Vaultwarden에 붙이면 Layer 4로 내려가서 순환 발생
- 따라서 Vaultwarden은 Vault 이관 **불가** — 파일시스템 퍼미션 + SSH 접근 제한으로 보호

## Portainer Stack Variables

| 변수 | 용도 | 비고 |
|------|------|------|
| VAULT_PORT | 호스트 포트 | 기본값 28200 |
| TZ | 타임존 | 기본값 Asia/Seoul |

기본값이 있어 미설정이어도 동작.

## Vault Agent (Sidecar)

여러 서비스에서 Vault Agent를 sidecar로 사용:

| 서비스 | Vault 경로 | 렌더링 파일 |
|--------|-----------|------------|
| Traefik (Mac Mini 1) | `secret/data/common/cloudflare-acme` | `/secrets/cloudflare.env` |
| Cloudflared | `secret/data/common/cloudflare` | `/secrets/cloudflared.env` |
| Grafana | `secret/data/services/grafana` | `/secrets/grafana.env` |
| n8n | `secret/data/services/n8n` | `/secrets/n8n.env` |
| Prefect | `secret/data/services/prefect` | `/secrets/prefect.env` |

## 관련 문서

- [codepoet-mac-mini-1 머신 문서](../machines/codepoet-mac-mini-1.md)
- [Vaultwarden](./vaultwarden.md) — 순환 의존성 관계
- [스택별 운영 노트](../stack-notes.md#layer-2)
