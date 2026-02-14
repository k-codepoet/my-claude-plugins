# GitLab CE

> Self-hosted GitLab. NAS에서 실행, Traefik Chain을 통해 HTTPS 제공.

## 위치

- **머신**: codepoet-nas (192.168.0.14)
- **접속**: https://gitlab.home.codepoet.site
- **SSH**: `ssh -p 20022 git@codepoet-nas`

## 트래픽 경로

```
Client (HTTPS) → Mac Mini Traefik (TLS 종료)
  → NAS Traefik (:8880, HTTP)
  → GitLab (:80, gateway 네트워크)
```

- `external_url`은 `https://` 사용
- 내부 nginx는 HTTP: `nginx['listen_https'] = false`
- `X-Forwarded-Proto: https` 헤더 전달

## 초기 비밀번호

```bash
# 초기 root 비밀번호 (24시간 유효)
docker compose exec gitlab grep 'Password:' /etc/gitlab/initial_root_password

# 수동 리셋
docker compose exec gitlab gitlab-rails console -e production
# user = User.find_by_username('root')
# user.password = 'newpassword'
# user.password_confirmation = 'newpassword'
# user.save!
```

## SSH 접근

`~/.ssh/config`:

```
Host gitlab-nas
    HostName codepoet-nas   # Tailscale
    Port 20022
    User git
```

SSH는 Mac Mini Traefik의 TCP 포워딩을 통해 NAS로 전달:
`Client → Mac Mini:20022 (TCP) → NAS:20022 → GitLab:22`

## Container Registry

- URL: `https://gitlab-registry.home.codepoet.site`
- 내부 포트: 5050
- 동일한 Traefik Chain 경유

## 리소스 설정

| 설정 | 기본값 | 비고 |
|------|--------|------|
| Puma workers | 2 | ~2GB RAM |
| Sidekiq concurrency | 10 | - |
| Prometheus | disabled | 리소스 절약 |

## 백업/복구

```bash
# 백업
docker compose exec gitlab gitlab-backup create

# 복구 (puma/sidekiq 중지 후)
docker compose exec gitlab gitlab-ctl stop puma
docker compose exec gitlab gitlab-ctl stop sidekiq
docker compose exec gitlab gitlab-backup restore BACKUP=<timestamp>
docker compose exec gitlab gitlab-ctl start
```

## 데이터 저장

절대경로 호스트 마운트 (NAS 볼륨 가이드라인 준수):

```
/volume1/workspaces/k-codepoet/my-devops/infra/codepoet-nas/gitlab-ce/data/
├── config/ → /etc/gitlab
├── logs/   → /var/log/gitlab
└── data/   → /var/opt/gitlab
```

## 관련 문서

- [codepoet-nas 머신 문서](../machines/codepoet-nas.md)
- [Traefik Chain 아키텍처](../../architecture/traefik-chain.md)
- [스택별 운영 노트](../stack-notes.md)
