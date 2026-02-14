# Vaultwarden

> Bitwarden 호환 패스워드 매니저. Mac Mini 1에서 실행. 시크릿 체인의 시작점.

## 위치

- **머신**: codepoet-mac-mini-1 (192.168.0.48)
- **접속**: https://vaultwarden.home.codepoet.site
- **직접**: http://192.168.0.48:28888

## 역할

- 마스터 패스워드 매니저 (유일하게 수동 관리)
- Vault root token, unseal keys 보관
- 이후 모든 자동화는 Vault를 통해 진행

## ADMIN_TOKEN 관리

Portainer Stack Variable이 **아닌** `data/config.json`에서 관리:

- admin 패널에서 설정 저장 시 config.json에 기록
- **config.json이 env var보다 우선**
- Portainer의 ADMIN_TOKEN 변수는 빈 값이어도 정상 동작

## SMTP 크레덴셜

`config.json`에 평문 저장 (Gmail 앱 비밀번호):

- admin 패널에서 설정한 값
- 위치: `/Volumes/mac-ext-storage/.vaultwarden/data/config.json`

## Vault 이관 불가

부트스트랩 순환 의존성:

1. Vaultwarden이 Vault unseal key를 보관 ("시크릿의 시작점")
2. Vault Agent sidecar를 붙이면 Layer 4로 내려가서 순환 발생
3. 파일시스템 퍼미션 + SSH 접근 제한으로 보호

## Secure Cookie

`N8N_SECURE_COOKIE`처럼, Vaultwarden도 Cloudflare Tunnel 환경에서:
- `DOMAIN=https://vaultwarden.home.codepoet.site` 설정으로 HTTPS URL 사용
- 내부는 HTTP (:80) → Traefik이 TLS 종료

## 데이터 저장

```
/Volumes/mac-ext-storage/.vaultwarden/data/
├── db.sqlite3       # 비밀번호 데이터
├── config.json      # ADMIN_TOKEN, SMTP 설정
└── ...
```

## 관련 문서

- [Vault](./vault.md) — 순환 의존성 관계
- [codepoet-mac-mini-1 머신 문서](../machines/codepoet-mac-mini-1.md)
- [스택별 운영 노트](../stack-notes.md#layer-2)
