# 하이브리드 GitOps 운영 가이드

> my-devops repo의 GitHub ↔ GitLab CE 하이브리드 GitOps 구조 운영 지침

## 개요

하나의 repo(my-devops)를 GitHub과 GitLab CE 양쪽에서 관리하며, Portainer 스택의 git 소스를 용도에 따라 분리:

| 폴더 | Portainer 소스 | 이유 |
|------|---------------|------|
| `infra/` | **GitHub** | 순환 의존성 해소 — GitLab/NAS 다운에도 배포 가능 |
| `services/` | **GitLab CE** | GitLab CI 빌드/배포 자동화 연동 |

## 단계별 운영 모드

### Phase 1: 구조 안정화 (현재)

GitHub에 직접 push가 필요할 수 있는 기간. 양쪽 remote에 동시 push.

**설정:**
```bash
# origin에 push URL 2개 등록 (GitLab + GitHub 동시 push)
git remote set-url --add --push origin gitlab-nas:k-codepoet/my-devops.git
git remote set-url --add --push origin git@github.com:k-codepoet/my-devops.git

# 확인
git remote -v
# origin  gitlab-nas:k-codepoet/my-devops.git (fetch)
# origin  gitlab-nas:k-codepoet/my-devops.git (push)
# origin  git@github.com:k-codepoet/my-devops.git (push)
```

**운영:**
```bash
git push origin main   # GitLab + GitHub 동시 push
```

**주의:**
- `git push`만 하면 양쪽에 동시 반영됨
- Portainer 인프라 스택이 GitHub에서 즉시 polling 가능
- 이 단계에서 GitLab Push Mirror는 설정하지 않음 (충돌 방지)

**Phase 1 완료 조건:**
- [ ] 모든 인프라 스택이 GitHub 소스로 정상 배포됨 (`portainer-gitops.sh update`)
- [ ] 모든 서비스 스택이 GitLab 소스로 정상 배포됨
- [ ] Vault 자격증명 (`secret/common/git`) 정상 동작 확인
- [ ] 최소 1주일 안정 운영

### Phase 2: Mirror 전환 (안정화 후)

구조가 안정되면 GitLab Push Mirror로 전환하여 자동 동기화.

**전환 절차:**

1. GitHub push URL 제거:
```bash
# 현재 dual push 제거
git remote set-url --push origin gitlab-nas:k-codepoet/my-devops.git
# GitHub은 upstream으로만 유지 (수동 pull/push용)
```

2. GitLab Push Mirror 설정:
   - GitLab CE → Settings → Repository → Mirroring repositories
   - URL: `https://k-codepoet@github.com/k-codepoet/my-devops.git`
   - Direction: **Push**
   - Password: GitHub PAT (Vault `secret/common/git`의 TOKEN)

3. Mirror 동기화 확인:
```bash
# GitLab에 push
git push origin main

# ~5분 후 GitHub 반영 확인
git fetch upstream
git log origin/main --oneline -1
git log upstream/main --oneline -1
# 두 커밋이 동일해야 함
```

**운영:**
```bash
git push origin main   # GitLab에만 push → Mirror가 자동으로 GitHub 반영
```

**주의:**
- GitHub에 직접 push 금지 (diverge 방지)
- Mirror 지연: ~5분
- 긴급 시 수동 push 가능: `git push upstream main`

### Phase 3: 정상 운영

**일상 워크플로우:**
```bash
# 개발 → GitLab push → Mirror → Portainer polling → 배포
git add . && git commit -m "message"
git push origin main
# 끝. 나머지는 자동.
```

**Portainer 배포 흐름:**
```
개발자 push → GitLab CE (SSOT)
                │
        Push Mirror (~5분)
                │
            GitHub (mirror)
                │
          Portainer polling
          ├── infra/ → GitHub에서 clone
          └── services/ → GitLab에서 clone
```

## Git Remote 구성

| Remote | URL | 용도 |
|--------|-----|------|
| `origin` | `gitlab-nas:k-codepoet/my-devops.git` | 개발 primary (fetch + push) |
| `upstream` | `git@github.com:k-codepoet/my-devops.git` | Mirror 확인, 긴급 수동 push |

## 트러블슈팅

### GitHub과 GitLab이 diverge된 경우

```bash
# GitLab 기준으로 GitHub 강제 동기화
git push upstream main --force
```

### Mirror가 동작하지 않을 때

```bash
# 수동 동기화
git push upstream main

# GitLab Mirror 상태 확인
# GitLab CE → Settings → Repository → Mirroring → "Update now" 클릭
```

### Portainer가 새 경로를 인식하지 못할 때

```bash
# 스택 재생성 (delete + create)
./scripts/portainer-gitops.sh update <stack-name>
```
