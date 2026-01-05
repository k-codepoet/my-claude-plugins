# 에러 처리

## 에러 유형별 대응

| 상황 | 에러 메시지 | 대응 |
|------|------------|------|
| POC.md 없음 | "POC.md가 없습니다. /gemify:poc으로 먼저 생성하세요." | gemify:poc 실행 안내 |
| What 섹션 없음 | "POC.md에 What 섹션이 없습니다." | POC.md 수정 안내 |
| AC 섹션 없음 | "Acceptance Criteria가 없습니다." | POC.md 수정 안내 |
| boilerplate 없음 | "boilerplate 경로를 확인하세요." | 경로 확인: `~/k-codepoet/.../boilerplates/web/` |
| 빌드 실패 | (빌드 에러 메시지) | 에러 수정 후 `pnpm build` 재시도 |
| 배포 실패 | (배포 에러 메시지) | `/craftify:deploy` 트러블슈팅 참조 |

## 복구 플로우

```
[에러 발생]
    ↓ 에러 메시지 확인
    ↓ 위 테이블에서 대응 방법 찾기
    ↓ 수정 후 재시도
[계속 진행]
```

## 자주 발생하는 빌드 에러

| 에러 | 원인 | 해결 |
|------|------|------|
| `Module not found` | 의존성 미설치 | `pnpm install` |
| `Type error` | TypeScript 타입 오류 | 해당 파일 수정 |
| `Port already in use` | 포트 충돌 | 다른 프로세스 종료 또는 포트 변경 |
