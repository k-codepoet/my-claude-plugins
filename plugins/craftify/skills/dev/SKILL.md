---
name: dev
description: 로컬 개발 환경 관리. 개발 서버 시작, 상태 확인 등. /craftify:dev 형태로 호출.
---

# Dev Skill

**로컬 개발 환경**을 관리합니다.

## 사용법

```
/craftify:dev [command]
```

### 명령어

| 명령어 | 설명 |
|--------|------|
| (없음) | 개발 서버 시작 |
| `start` | 개발 서버 시작 |
| `stop` | 개발 서버 중지 안내 |
| `status` | 프로젝트 상태 확인 |

## 동작

### 1. 프로젝트 감지

현재 디렉토리에서 Craftify 프로젝트인지 확인:
- `CRAFTIFY.md` 존재 여부
- `turbo.json` 존재 여부
- `apps/web/` 구조 확인

### 2. 개발 서버 시작

```bash
pnpm dev
```

- turborepo가 모든 앱의 dev 서버를 병렬 실행
- 기본 포트: http://localhost:5173

### 3. 상태 확인

`/craftify:dev status` 실행 시:
- 프로젝트 구조 표시
- 의존성 설치 상태
- 개발 서버 실행 가능 여부

## 출력 예시

### 성공 시
```
🔨 Craftify Dev Server

프로젝트: my-app
타입: webapp (SSR)
포트: http://localhost:5173

pnpm dev 실행 중...
```

### 프로젝트 미감지 시
```
⚠️ Craftify 프로젝트가 아닙니다.

새 프로젝트를 생성하려면:
/craftify:create webapp my-app
```

## 트러블슈팅

### 의존성 미설치
```bash
pnpm install
```

### 포트 충돌
```bash
# 다른 포트로 실행
pnpm dev -- --port 5174
```

## 규칙

- 개발 서버는 사용자가 직접 Ctrl+C로 종료
- Craftify 프로젝트가 아니면 안내 메시지 표시
- 의존성 미설치 시 `pnpm install` 안내
