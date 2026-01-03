---
name: help
description: Terrafy 플러그인 도움말. 사용 가능한 명령어, 스킬, 인프라 설정 방법을 안내합니다.
---

# Terrafy Help

## Overview

Terrafy는 인프라 자동화 플러그인입니다. 서버를 배포 가능한 환경으로 변환합니다.

> "Lay the groundwork for your digital city"

## The -ify Trilogy

| Plugin | Role | Question |
|--------|------|----------|
| Gemify | 지식/설계 | WHAT - 뭘 만들지 |
| **Terrafy** | 인프라 | WHERE - 어디서 돌릴지 |
| Craftify | 개발 | HOW - 어떻게 만들지 |

## Available Skills

### k3s
쿠버네티스 환경이 필요할 때 사용합니다.
- K3s 클러스터 설치
- 워커 노드 추가
- 클러스터 스냅샷/복원
- Helm 차트 배포

**트리거**: "쿠버네티스", "k8s", "k3s", "Pod 배포", "Helm"

### portainer
Docker 컨테이너 관리 환경이 필요할 때 사용합니다.
- Portainer 설치
- Docker Compose 스택 관리
- GitOps 연동

**트리거**: "컨테이너 관리", "Portainer", "Docker 스택"

### terraform
클라우드 인프라 프로비저닝이 필요할 때 사용합니다. (준비 중)
- AWS/GCP/Azure 리소스 관리
- Infrastructure as Code

**트리거**: "클라우드", "AWS", "Terraform"

## Commands

| Command | Description |
|---------|-------------|
| `/terrafy:help` | 이 도움말 표시 |
| `/terrafy:init` | 인프라 환경 초기화 |
| `/terrafy:status` | 현재 인프라 상태 확인 |

## Input → Output

```
Raw server IP → Ready-to-deploy cluster
"SSH 접속 가능" → "kubectl 동작, ArgoCD 접속 가능"
```

## Platform Support

| Platform | k3s | portainer | terraform |
|----------|-----|-----------|-----------|
| Linux Ubuntu | Full | Full | Full |
| macOS | - | Docker only | Full |
| Windows | - | - | Full |
