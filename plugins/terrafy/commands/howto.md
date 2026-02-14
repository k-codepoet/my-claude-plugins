---
description: Terrafy 사용 가이드. 인자 없이 실행하면 가능한 주제 목록을, 주제를 지정하면 해당 가이드를 표시합니다.
argument-hint: "[topic]"
---

# /terrafy:howto 명령어

사용자가 요청한 주제에 대한 Terrafy 사용 가이드를 제공합니다.

## 사용법

- `/terrafy:howto` - 가능한 주제 목록 표시
- `/terrafy:howto <topic>` - 특정 주제 가이드 표시

## 가능한 주제 (Topics)

### 인프라 프로비저닝
| 주제 | 설명 | 예시 |
|------|------|------|
| `status` | 현재 환경 스캔 및 상태 확인 | `/terrafy:status` |
| `setup` | 대화형 인프라 구성 (6-Phase) | `/terrafy:setup` |
| `init-ssh` | SSH 서버 설정 | `/terrafy:init-ssh` |

### 배포·운영
| 주제 | 설명 | 예시 |
|------|------|------|
| `deploy-stack` | 서비스 스택 배포 (Portainer GitOps) | `/terrafy:deploy-stack` |
| `secrets` | Vault 시크릿 관리 | `/terrafy:secrets` |
| `networking` | 네트워크/라우팅 (Traefik, DNS) | `/terrafy:networking` |
| `cicd` | CI/CD 파이프라인 (GitLab CI) | `/terrafy:cicd` |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.
   - `status` → status 스킬
   - `setup` → setup 스킬
   - `init-ssh` → init-ssh 스킬
   - `deploy-stack` → deploy-stack 스킬
   - `secrets` → secrets 스킬
   - `networking` → networking 스킬
   - `cicd` → cicd 스킬

3. **알 수 없는 주제**: 가능한 주제 목록을 보여주고 올바른 주제를 선택하도록 안내합니다.

## 구성 예시

### 멀티노드
```
외부 → [NAS] 관문 → [Mac] 관제탑 → [Linux] 일꾼
```

### 싱글노드
```
외부 → [Linux] 관문 + 관제탑 + 일꾼 (올인원)
```

## 시작하기

```
[인프라 프로비저닝]
1. /terrafy:status       → 현재 상태 확인
2. /terrafy:setup        → 인프라 구성 (6-Phase)
3. 대화를 따라가며 선택

[배포·운영]
4. /terrafy:deploy-stack → 서비스 배포
5. /terrafy:secrets      → 시크릿 설정
6. /terrafy:networking   → 라우팅 설정
7. /terrafy:cicd         → CI/CD 파이프라인
```
