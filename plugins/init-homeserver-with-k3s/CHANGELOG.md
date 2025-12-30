# Changelog

## [2.0.0] - 2024-12-30

### 🎯 Major Changes: IaC Repository Restructure

기존 `~/k3s` 구조에서 확장 가능한 `~/my-iac` 구조로 전면 개편되었습니다.

### ✨ New Features

#### 1. 새로운 IaC 디렉토리 구조
```
~/my-iac/                         # 기본 경로 (사용자 지정 가능)
├── k3s/
│   ├── manifest/                 # K8s 매니페스트 (선언형)
│   └── helm/                     # Helm 차트 및 values
├── {hostname}/                   # Docker Compose 서비스 (호스트명 자동 감지)
│   └── .gitkeep
├── terraform/                    # Terraform 인프라 (placeholder)
│   └── .gitkeep
├── argocd/                       # ArgoCD GitOps (placeholder)
│   └── .gitkeep
├── .gitignore
└── README.md
```

#### 2. 새로운 커맨드
- `/init-homeserver-with-k3s:init-iac` - IaC 저장소만 초기화 (K3s 없이)

#### 3. 새로운 스크립트
- `scripts/init-iac.sh` - IaC 저장소 초기화 스크립트

#### 4. Hostname 자동 감지
- Docker Compose 디렉토리가 사용자 머신의 hostname으로 자동 생성됨
- Portainer GitOps와 호환되는 구조

#### 5. 확장 가능한 구조
- Terraform, ArgoCD placeholder 디렉토리 제공
- 향후 기능 추가 용이

#### 6. 사용자 지정 디렉토리 지원
- 모든 스크립트에 `-d` / `--directory` 또는 `--dir` 옵션 추가
- 기본값: `~/my-iac`
- 사용자가 원하는 경로 지정 가능

```bash
# 기본 경로 사용
/init-homeserver-with-k3s:init-iac

# 사용자 지정 경로
/init-homeserver-with-k3s:init-iac -d ~/projects/my-infrastructure
/init-homeserver-with-k3s:snapshot -d ~/projects/my-infrastructure
/init-homeserver-with-k3s:restore --dir ~/projects/my-infrastructure
```

### 🔄 Changed

#### 경로 변경
| 이전 | 이후 |
|------|------|
| `~/k3s` | `~/my-iac` |
| `~/k3s/k3s/manifest/` | `~/my-iac/k3s/manifest/` |
| `~/k3s/k3s/helm/` | `~/my-iac/k3s/helm/` |
| `$PLUGIN_ROOT/snapshots/` | `~/my-iac/k3s/snapshots/` |

#### 스크립트 업데이트
- `snapshot-k3s.sh` - 새 경로 사용, IaC 디렉토리 존재 확인 추가
- `restore-k3s.sh` - 새 경로 사용, IaC 디렉토리 존재 확인 추가

#### 커맨드 업데이트
- `init.md` - IaC 초기화 → K3s 설치 순서로 변경
- `snapshot.md` - 새 경로 참조
- `restore.md` - 새 경로 참조

#### 문서 업데이트
- `README.md` - 새 구조 반영
- `SKILL.md` - 새 구조 및 워크플로우 반영
- `agents/homeserver-setup.md` - 새 트리거 및 구조 반영
- `plugin.json` - 버전 2.0.0, 새 키워드 추가

### 📁 Files Changed

```
plugins/init-homeserver-with-k3s/
├── .claude-plugin/
│   └── plugin.json              # 버전 2.0.0
├── agents/
│   └── homeserver-setup.md      # 새 트리거 추가
├── commands/
│   ├── init.md                  # IaC 초기화 포함
│   ├── init-iac.md              # [NEW] IaC만 초기화
│   ├── snapshot.md              # 경로 업데이트
│   └── restore.md               # 경로 업데이트
├── scripts/
│   ├── init-iac.sh              # [NEW] IaC 초기화 스크립트
│   ├── snapshot-k3s.sh          # 경로 업데이트
│   └── restore-k3s.sh           # 경로 업데이트
├── skills/
│   └── k3s-homeserver/
│       └── SKILL.md             # 새 구조 반영
├── README.md                    # 새 구조 반영
└── CHANGELOG.md                 # [NEW] 이 파일
```

---

## [1.1.0] - Previous Version

- K3s 설치 및 클러스터 관리
- 워커 노드 조인 기능
- 스냅샷/복원 기능
- `~/k3s` 구조 사용
