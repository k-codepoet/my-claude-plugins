# Terrafy

> "Lay the groundwork for your digital city"

인프라 자동화 Claude Code 플러그인. 서버를 배포 가능한 환경으로 변환합니다.

## The -ify Trilogy

| Plugin | Role | Question |
|--------|------|----------|
| Gemify | 지식/설계 | WHAT - 뭘 만들지 |
| **Terrafy** | 인프라 | WHERE - 어디서 돌릴지 |
| Craftify | 개발 | HOW - 어떻게 만들지 |

## Skills

### k3s
쿠버네티스 환경 구축. Pod 배포, Helm 차트, GitOps가 필요할 때 사용.

### portainer
Portainer 기반 컨테이너 관리. Docker 스택 배포, GitOps 연동.

### terraform
클라우드 인프라 프로비저닝. AWS, GCP, Azure 리소스 관리. (준비 중)

## Commands

- `/terrafy:help` - 도움말
- `/terrafy:bootstrap` - 인프라 환경 초기화
- `/terrafy:status` - 현재 인프라 상태 확인

## Input → Output

```
Raw server IP → Ready-to-deploy cluster
"SSH 접속 가능" → "kubectl 동작, ArgoCD 접속 가능"
```

## Platform

- **Primary**: Linux Ubuntu
- **Partial**: macOS (Docker/Portainer)
- **Not Supported**: Windows
