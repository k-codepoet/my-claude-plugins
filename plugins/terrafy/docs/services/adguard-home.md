# AdGuard Home

> 내부 DNS 서버 + Split DNS. NAS에서 실행.

## 위치

- **머신**: codepoet-nas (192.168.0.14)
- **DNS**: 192.168.0.14:53
- **Web UI**: http://192.168.0.14:3080
- **초기 설정**: http://192.168.0.14:3000

## 역할

- **Split DNS**: `*.home.codepoet.site` → NAS Tailscale IP (100.125.241.80)
- 광고 차단 (보너스)
- DHCP DNS 서버로 지정하여 전체 네트워크 적용

## DNS Rewrite 패턴

AdGuard Web UI에서 설정:

```
*.home.codepoet.site → 100.125.241.80 (NAS Tailscale IP)
```

### 왜 Tailscale IP?

| 상황 | 로컬 IP (192.168.0.x) | Tailscale IP (100.x) |
|------|----------------------|---------------------|
| 내부 네트워크 | O | O |
| 외부 + VPN | X (도달 불가) | O |

Tailscale IP를 사용하면 내부/외부 모두 동일하게 접근 가능.

### Tailscale Split DNS도 동일 설정

```
Tailscale Admin → DNS → Split DNS
home.codepoet.site → 100.125.241.80
```

## 포트

| 포트 | 프로토콜 | 용도 |
|------|---------|------|
| 53 | TCP/UDP | DNS |
| 3000 | TCP | 초기 설정 UI |
| 3080 | TCP | Web UI (HTTP) |

## 데이터 저장

절대경로 호스트 마운트 (NAS 볼륨 가이드라인 준수):

```
/volume1/workspaces/k-codepoet/my-devops/infra/codepoet-nas/adguard-home/data/
├── work/  → /opt/adguardhome/work
└── conf/  → /opt/adguardhome/conf
```

## 관련 문서

- [codepoet-nas 머신 문서](../machines/codepoet-nas.md)
- [Traefik Chain 아키텍처](../../architecture/traefik-chain.md) — Split DNS 연동
