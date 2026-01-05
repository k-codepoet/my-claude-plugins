# 배포 트러블슈팅

## 자주 발생하는 에러

| 에러 | 원인 | 해결 |
|------|------|------|
| Build failed | 빌드 명령 오류 | 로컬에서 `pnpm build` 성공 확인 |
| Deploy failed | Git 연결 문제 | Dashboard에서 연결 상태 확인 |
| 404 Not Found | Build output 경로 오류 | `build/client` 확인 |
| Preview URL 미생성 | Git 연결 미완료 | Dashboard에서 연결 확인 |

## 빌드 실패 시

```bash
# 로컬에서 빌드 테스트
pnpm build

# 에러 확인 후 수정
# 다시 push
git push origin main
```

## Dashboard 확인

1. Cloudflare Dashboard → Workers & Pages
2. 해당 프로젝트 선택
3. Deployments 탭에서 상태 확인
4. 실패 시 로그 확인

## Git 연결 재설정

연결이 끊어진 경우:
1. Dashboard → Settings → Builds
2. "Disconnect" 클릭
3. 다시 "Connect to Git" 진행
