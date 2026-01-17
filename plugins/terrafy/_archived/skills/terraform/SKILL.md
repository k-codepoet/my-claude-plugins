---
name: terraform
description: Terraform 기반 클라우드 인프라 프로비저닝. AWS, GCP, Azure 리소스 관리가 필요할 때 사용합니다. (준비 중)
---

# Terraform Skill

## Overview

Terraform을 통한 클라우드 인프라 프로비저닝. Infrastructure as Code로 클라우드 리소스를 선언적으로 관리합니다.

> **Status**: 준비 중 (Placeholder)

## Trigger Context

사용자가 다음과 같은 맥락일 때 이 스킬 활성화:
- "AWS 인프라 구축해줘"
- "Terraform으로 관리하고 싶어"
- "클라우드 리소스 프로비저닝 해줘"
- "IaC로 인프라 관리하고 싶어"

## Planned Features

### Cloud Providers
- [ ] AWS (EC2, VPC, RDS, S3, EKS)
- [ ] GCP (Compute, GKE, Cloud SQL)
- [ ] Azure (VM, AKS, Storage)

### Core Workflows
- [ ] 프로젝트 초기화 (`terraform init`)
- [ ] 리소스 계획 (`terraform plan`)
- [ ] 리소스 적용 (`terraform apply`)
- [ ] 상태 관리 (remote state)
- [ ] 모듈 구성

### Integration
- [ ] IaC 저장소 연동 (`~/my-iac/terraform/`)
- [ ] GitOps 워크플로우
- [ ] 비용 추정

## Current Directory Structure

```
~/my-iac/terraform/
├── .gitkeep
└── (향후 추가 예정)
    ├── aws/
    ├── gcp/
    └── modules/
```

## Prerequisites (향후)

- Terraform CLI
- 클라우드 provider credentials
- AWS CLI / gcloud / az CLI

## Coming Soon

이 스킬은 현재 개발 중입니다. 다음 버전에서 제공될 예정입니다.

현재는 k3s와 portainer 스킬을 사용하여 로컬/온프레미스 인프라를 구축할 수 있습니다.
