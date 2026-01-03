# my-claude-plugins

Personal collection of Claude Code plugins by k-codepoet.

## Available Plugins

| Plugin | Description | Platform |
|--------|-------------|----------|
| [homeserver-gitops](./plugins/homeserver-gitops/) | K3s homeserver & GitOps setup with extensible IaC | Linux |
| [ubuntu-dev-setup](./plugins/ubuntu-dev-setup/) | Zsh + Oh My Zsh + Powerlevel10k + NVM 개발환경 설정 | Linux |
| [forgeify](./plugins/forgeify/) | Forge your ideas into Claude extensions - 플러그인 개발 도구 | All |
| [gemify](./plugins/gemify/) | 원석을 보석으로 - 개인 지식 파이프라인 (capture → develop → file) | All |
| [namify](./plugins/namify/) | Name it right - 제품/서비스 네이밍 도구 | All |
| [craftify](./plugins/craftify/) | Craft your products - turborepo + Cloudflare 기반 개발환경 자동화 | All |
| [terrafy](./plugins/terrafy/) | Lay the groundwork - 인프라 자동화 (K3s, Portainer, Terraform) | Linux |

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

### forgeify (v1.3.0)

*Forge your ideas into Claude extensions*

Claude Code 플러그인 개발 도구:

- **Commands**:
  - `/forgeify:howto` - 가능한 가이드 주제 목록
  - `/forgeify:howto <topic>` - 특정 주제 가이드 표시
  - `/forgeify:create <path> <topic>` - 경로 내용 기반 플러그인 생성
  - `/forgeify:compose <topic> <plugins...>` - 여러 플러그인 조립
  - `/forgeify:validate [path]` - 가이드라인 준수 검증
  - `/forgeify:update [path]` - 최신 가이드라인으로 갱신
  - `/forgeify:help` - 도움말 표시

- **Topics**: `plugin`, `command`, `agent`, `skill`, `hook`, `marketplace`, `workflow`

- **Features**:
  - Skills, Commands, Agents, Hooks, Plugins, Marketplace 작성법
  - 대화 컨텍스트에 따른 스킬 자동 활성화
  - 플러그인 생성/검증/조립 도구

### gemify (v1.6.0)

원석을 다듬어 보석으로 만드는 개인 지식 파이프라인:

- **Commands**:
  - `/gemify:inbox [내용]` - 내 생각을 inbox/thoughts/에 빠르게 저장
  - `/gemify:import [URL/내용]` - 외부 재료를 inbox/materials/에 저장
  - `/gemify:capture-pair` - material + thought를 쌍으로 동시에 저장
  - `/gemify:draft [파일]` - inbox의 원석을 대화로 다듬기 (facet/polish 모드)
  - `/gemify:library [파일]` - drafts를 정리하여 library로 분류/저장
  - `/gemify:view [주제]` - library 지식을 주제별로 조합하여 views/에 저장
  - `/gemify:retro` - 이미 완료된 작업을 역방향으로 library에 기록
  - `/gemify:setup [경로]` - Gemify 지식 파이프라인 구조 생성
  - `/gemify:help` - 도움말 표시

- **Pipeline**:
  ```
  /inbox   → /draft → /library
  /import ↗    ↓         ↓
  inbox/    drafts/   library/
  ```

- **Features**:
  - inbox: 생각의 원석을 빠르게 포착
  - import: 외부 재료 가져오기 (article, document, conversation, snippet)
  - draft: facet(넓게 탐색) / polish(깊이 연마) 모드
  - library: 소크라테스식 질문으로 6대 domain 분류
  - 대화 히스토리 스냅샷 (.history/)

- **Natural Language Triggers**:
  - "저장해", "메모해", "포착"
  - "가져와", "이 기사", "이 문서"
  - "다듬어봐", "연마해봐"
  - "정리해", "분류해", "library 해줘"

### namify (v1.0.0)

*Name it right*

제품/서비스 네이밍을 도와주는 플러그인:

- **Commands**:
  - `/namify:name <설명>` - 제품/서비스 이름 생성

- **Options**:
  - `--pattern`: 적용할 이름 패턴 (-ify, Craft, Lab, Hub 등)
  - `--series`: 기존 이름으로부터 패턴 추출하여 일관성 유지

- **Workflow**:
  1. 핵심 가치 추출
  2. 메타포 탐색
  3. 후보 생성
  4. 문화적 검증
  5. 최종 추천

### craftify (v0.1.0)

*Craft your products with AI*

turborepo + Cloudflare 기반 개발환경 자동화:

- **Commands**:
  - `/craftify:create <type> <name>` - 새 프로젝트 생성 (turborepo 기반)
  - `/craftify:dev [start|stop|status]` - 로컬 개발 환경 관리
  - `/craftify:deploy [setup|run|status]` - Cloudflare 배포
  - `/craftify:status` - 프로젝트 상태 표시
  - `/craftify:help` - 도움말 표시

- **Features**:
  - Turborepo monorepo 구조
  - Cloudflare Workers/Pages 배포
  - SSR/SPA 옵션 지원

### terrafy (v1.0.0)

*Lay the groundwork for your digital city*

인프라 자동화 플러그인:

- **Commands**:
  - `/terrafy:init` - 인프라 환경 초기화 (IaC 저장소 생성)
  - `/terrafy:status` - 현재 인프라 상태 확인
  - `/terrafy:help` - 도움말 표시

- **Skills**:
  - K3s 클러스터 구축
  - Portainer 기반 컨테이너 관리
  - Terraform 클라우드 인프라 (준비 중)

- **Prerequisites**: Linux Ubuntu, sudo access

## Contributing

Feel free to submit issues or pull requests.

## License

MIT
