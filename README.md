# my-claude-plugins

Personal collection of Claude Code plugins by k-codepoet.

## Available Plugins

| Plugin | Description | Platform |
|--------|-------------|----------|
| [homeserver-gitops](./plugins/homeserver-gitops/) | K3s homeserver & GitOps setup with extensible IaC | Linux |
| [ubuntu-dev-setup](./plugins/ubuntu-dev-setup/) | Zsh + Oh My Zsh + Powerlevel10k + NVM 개발환경 설정 | Linux |
| [ced](./plugins/claude-extension-dev/) | Claude Code 확장 개발 가이드 (한국어) | All |
| [distill](./plugins/distill/) | 개인 지식 증류 파이프라인 (seed → grow → digest) | All |
| [gemify](./plugins/gemify/) | 원석을 보석으로 - 개인 지식 파이프라인 (capture → develop → file) | All |

## Installation

### Add Marketplace (Recommended)

```bash
# Add marketplace from GitHub
/plugin marketplace add k-codepoet/my-claude-plugins

# Install plugin
/plugin install homeserver-gitops@k-codepoet-plugins
```

### Local Installation

```bash
# Clone and add as local marketplace
git clone https://github.com/k-codepoet/my-claude-plugins.git
/plugin marketplace add ./my-claude-plugins

# Install plugin
/plugin install homeserver-gitops@k-codepoet-plugins
```

## Plugin Details

### homeserver-gitops (v1.0.0)

Linux Ubuntu homeserver K3s & GitOps initialization plugin:

- **Commands**:
  - `/homeserver-gitops:init` - Install K3s and initialize IaC environment
  - `/homeserver-gitops:init-iac` - Initialize IaC repository only (no K3s)
  - `/homeserver-gitops:join-node` - Join as worker node to existing cluster
  - `/homeserver-gitops:snapshot` - Export cluster state to YAML manifests
  - `/homeserver-gitops:restore` - Restore cluster from saved snapshot
  - `/homeserver-gitops:help` - Show help and usage

- **Features**:
  - Extensible IaC structure at `~/my-iac`
  - Hostname-based Docker Compose for Portainer GitOps
  - Terraform and ArgoCD placeholders
  - Custom directory support (`-d` option)

- **Natural Language Triggers**:
  - "Set up homeserver", "Install K3s"
  - "Add worker node", "Join K3s cluster"
  - "Initialize IaC", "GitOps setup"

- **Prerequisites**: Linux Ubuntu 18.04+, sudo access, curl, git

### ubuntu-dev-setup (v1.0.0)

Ubuntu Linux 개발 환경 자동 설정 플러그인:

- **Commands**:
  - `/ubuntu-dev-setup:setup-all` - 전체 설치 (common + zsh + nvm)
  - `/ubuntu-dev-setup:setup-common` - 기본 패키지만 설치
  - `/ubuntu-dev-setup:setup-zsh` - Zsh + Oh My Zsh + Powerlevel10k 설치
  - `/ubuntu-dev-setup:setup-nvm` - NVM 설치
  - `/ubuntu-dev-setup:help` - 도움말 표시

- **Features**:
  - Essential packages (curl, wget, git, net-tools 등)
  - Zsh + Oh My Zsh + Powerlevel10k + 생산성 플러그인
  - NVM (Node Version Manager)
  - Idempotent (이미 설치된 항목 건너뜀)

- **Natural Language Triggers**:
  - "우분투 개발환경 셋업해줘"
  - "zsh 설치해줘", "터미널 꾸며줘"

- **Prerequisites**: Linux Ubuntu/Debian, sudo access

### ced (v1.2.0)

Claude Code 확장 개발 한국어 가이드 플러그인:

- **Commands**:
  - `/ced:howto` - 가능한 가이드 주제 목록
  - `/ced:howto <topic>` - 특정 주제 가이드 표시
  - `/ced:create <path> <topic>` - 경로 내용 기반 플러그인 생성
  - `/ced:compose <topic> <plugins...>` - 여러 플러그인 조립
  - `/ced:validate [path]` - 가이드라인 준수 검증
  - `/ced:update [path]` - 최신 가이드라인으로 갱신
  - `/ced:help` - 도움말 표시

- **Topics**: `plugin`, `command`, `agent`, `skill`, `hook`, `marketplace`, `workflow`

- **Features**:
  - Skills, Commands, Agents, Hooks, Plugins, Marketplace 작성법
  - 대화 컨텍스트에 따른 스킬 자동 활성화
  - 플러그인 생성/검증/조립 도구

### distill (v1.0.0)

개인 지식 증류 파이프라인 플러그인:

- **Commands**:
  - `/distill:seed [내용]` - 내 생각의 씨앗을 seed/에 저장
  - `/distill:grow [파일]` - seed와 materials를 대화로 확장 (branch/ripen 모드)
  - `/distill:digest [파일]` - growing 파일을 소화시켜 corpus로 분류/저장

- **Pipeline**:
  ```
  seed/ + materials/ → growing/ → corpus/
  ```

- **Features**:
  - seed: 생각의 씨앗 빠르게 저장
  - grow: branch(넓게 탐색) / ripen(깊이 응축) 모드
  - digest: 익은 지식을 corpus로 정리
  - 대화 히스토리 스냅샷 (.history/)

- **Natural Language Triggers**:
  - "이거 저장해줘", "메모해", "씨앗으로"
  - "이 생각 키워보자", "확장해봐"
  - "정리해줘", "digest 해줘"

### gemify (v1.0.0)

원석을 다듬어 보석으로 만드는 개인 지식 파이프라인:

- **Commands**:
  - `/gemify:capture [내용]` - 내 생각을 inbox/thoughts/에 빠르게 저장
  - `/gemify:develop [파일]` - inbox의 원석을 대화로 다듬기 (facet/polish 모드)
  - `/gemify:file [파일]` - drafts를 정리하여 library로 분류/저장

- **Pipeline**:
  ```
  inbox/ → drafts/ → library/
  (capture)  (develop)  (file)
  ```

- **Features**:
  - capture: 생각의 원석을 빠르게 포착
  - develop: facet(넓게 탐색) / polish(깊이 연마) 모드
  - file: 소크라테스식 질문으로 6대 domain 분류
  - 대화 히스토리 스냅샷 (.history/)

- **Natural Language Triggers**:
  - "저장해", "메모해", "포착"
  - "다듬어봐", "연마해봐"
  - "정리해", "분류해", "file 해줘"

## Contributing

Feel free to submit issues or pull requests.

## License

MIT
