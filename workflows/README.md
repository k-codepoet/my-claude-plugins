# Workflows

> 반복 가능한 운영 워크플로우 모음. 각 문서는 독립적으로 참고 가능하며, 아래 체크리스트로 전체 흐름을 따라갈 수 있음.

## 새 서비스 배포 (End-to-End 체크리스트)

앱 repo에서 GitLab CI 빌드 → Portainer 스택 배포 → 도메인 접근 설정까지의 전체 흐름.

### Phase 1: 빌드 파이프라인 (앱 repo)
- [ ] `Dockerfile.prod` 작성 (프로덕션 멀티스테이지)
- [ ] `.gitlab-ci.yml` 작성 (멀티플랫폼 buildx)
- [ ] push → CI 파이프라인 성공 확인
- → [상세: GitLab CI 멀티플랫폼 빌드 → Portainer 배포](cicd-deploy/gitlab-ci-multiplatform-portainer.md)

### Phase 2: 인프라 배포 (my-devops repo)
- [ ] `services/{device}/{service}/docker-compose.yml` 작성
  - 외부 접근 필요 시 **처음부터 split-router 패턴** 적용
- [ ] `scripts/portainer-gitops.sh` STACKS 배열에 등록
- [ ] `./scripts/portainer-gitops.sh create {service}` 실행
- → [상세: 위 CI/CD 문서의 3~5단계](cicd-deploy/gitlab-ci-multiplatform-portainer.md#3단계-portainer-스택-compose-작성)

### Phase 3: 외부 인증 (필요 시)
- [ ] htpasswd 해시 생성
- [ ] docker-compose labels에 BasicAuth split-router 적용
- [ ] 스택 재배포 + 내부 200 / 외부 401 / 인증 후 200 검증
- → [상세: Traefik BasicAuth 외부 전용](networking/traefik-basicauth-external-only.md)

### Phase 4: 문서화
- [ ] `my-devops/docs/services/{service}.md` 생성
- [ ] `my-devops/docs/reference/stacks-registry.md` 업데이트
- [ ] `my-devops/docs/reference/deployed-services.md` 업데이트
- [ ] `my-devops/docs/architecture/current-structure.md` 업데이트
- [ ] 앱 repo CLAUDE.md에 Deployment 섹션 추가

## 워크플로우 목록

| 카테고리 | 문서 | 설명 |
|----------|------|------|
| cicd-deploy | [gitlab-ci-multiplatform-portainer.md](cicd-deploy/gitlab-ci-multiplatform-portainer.md) | GitLab CI 멀티플랫폼 빌드 → Portainer 스택 배포 |
| networking | [traefik-basicauth-external-only.md](networking/traefik-basicauth-external-only.md) | 외부만 BasicAuth, 내부 패스 |
