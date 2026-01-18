---
name: poc-proto
description: PoC 즉시 프로토타입. HTML + Tailwind + vanilla JS로 바로 생성하고 로컬 개발 서버로 실시간 미리보기. "화면 만들어봐", "이거 보여줘" 등 요청 시 활성화.
---

# PoC Proto Skill

작은 요청을 **즉시 HTML로 생성**하고 **로컬 서버로 실시간 미리보기**합니다. 실시간 피드백 루프의 핵심.

## 언제 사용

- "이것만 만들어봐", "화면 보여줘" 등 작은 요청
- 바로 확인하고 싶은 단일 화면/컴포넌트
- shape ↔ proto 반복 중
- 한 번에 만들어낼 정도로 작은 것

## 핵심 역할

### 1. HTML + Tailwind + vanilla JS 즉시 생성

- 단일 HTML 파일로 완결
- Tailwind CDN 사용
- vanilla JS로 인터랙션 (프레임워크 없음)
- 바로 동작하는 수준

### 2. 로컬 개발 서버 실시간 미리보기

**Python http.server 사용 (간단/범용):**

```bash
# 작업 디렉토리에서 서버 시작
cd {proto_dir}
python3 -m http.server 8080
```

**사용자 안내:**
```
프로토타입이 생성되었습니다!

미리보기: http://localhost:8080/prototype.html
(서버가 백그라운드에서 실행 중)

수정하면서 브라우저 새로고침하면 바로 확인 가능합니다.
"이거 맞아?" / "수정해줘" / "다시 만들어봐"
```

### 3. 빠른 반복 (피드백 루프)

```
사용자: "만들어봐"
    ↓
HTML 생성 → 서버 시작 → URL 안내
    ↓
사용자: (브라우저에서 확인)
    ↓
"이거 맞아?" or "이 부분 수정해"
    ↓
수정 → 새로고침 안내
    ↓
(반복)
```

## 워크플로우

```
입력: 만들어볼 화면/컴포넌트 설명
    ↓
작업 디렉토리 결정:
├── ~/.gemify/proto/{date}-{slug}/ (기본)
└── 사용자 지정 경로
    ↓
HTML 파일 생성 (prototype.html)
    ↓
로컬 서버 시작 (백그라운드)
    ↓
URL 안내 + 서버 상태 표시
    ↓
피드백 루프 대기
    ↓
수정 요청 시 → 파일 수정 → 새로고침 안내
```

## 프로토타입 템플릿

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{프로젝트명} - Prototype</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    /* 커스텀 스타일 */
  </style>
</head>
<body class="bg-gray-50 min-h-screen">
  <!-- 프로토타입 내용 -->

  <script>
    // 인터랙션 로직
  </script>
</body>
</html>
```

## 서버 관리

### 서버 시작

```bash
# 작업 디렉토리로 이동
cd ~/.gemify/proto/2026-01-18-gemify-pipeline/

# 백그라운드 서버 시작 (포트 8080)
python3 -m http.server 8080 &

# PID 저장 (나중에 종료용)
echo $! > .server.pid
```

### 서버 상태 확인

```bash
# 서버 실행 중인지 확인
lsof -i :8080
```

### 서버 종료

```bash
# PID로 종료
kill $(cat .server.pid)
```

### 포트 충돌 시

```bash
# 다른 포트 사용
python3 -m http.server 8081 &
```

## 대화 예시

```
사용자: "파이프라인 뷰 화면 만들어봐"

Claude: 파이프라인 뷰 프로토타입을 만들게요.

[생성 중...]
├── ~/.gemify/proto/2026-01-18-pipeline-view/
└── prototype.html

[서버 시작]
http://localhost:8080/prototype.html

브라우저에서 확인해보세요!
수정이 필요하면 말씀해주세요.

---

사용자: (브라우저에서 확인 후)
"inbox 부분이 왼쪽에 있으면 좋겠어"

Claude: inbox를 왼쪽으로 옮길게요.

[수정 완료]
브라우저 새로고침(F5)하면 바로 확인됩니다.

---

사용자: "이 느낌 맞아!"

Claude: 좋아요! 이 프로토타입을 패키징할까요?
→ /gemify:poc (poc-pack으로 라우팅)
```

## 작업 디렉토리 구조

```
~/.gemify/proto/
└── 2026-01-18-pipeline-view/
    ├── prototype.html    # 메인 프로토타입
    ├── .server.pid       # 서버 PID (관리용)
    └── assets/           # 추가 리소스 (선택)
        ├── sample.json
        └── mockup.png
```

## 완료 후 안내

### 수정 요청 시
```
[수정 완료]
브라우저 새로고침(F5)하면 바로 확인됩니다.

계속 수정할까요? 아니면 이대로 진행할까요?
```

### 확정 시
```
프로토타입이 확정되었습니다!

파일 위치: ~/.gemify/proto/2026-01-18-pipeline-view/prototype.html

다음 단계:
  패키징하려면 → /gemify:poc "패키징해줘"
  (poc-pack이 git repo 생성 + craftify 핸드오프 준비)

서버 종료하려면:
  kill $(cat ~/.gemify/proto/2026-01-18-pipeline-view/.server.pid)
```

## 규칙

- **작은 것만**: 한 번에 만들 수 있는 단일 화면/컴포넌트
- **부차적 요구 잘라내기**: "그건 나중에, 지금은 X에 집중하자"
- **shape ↔ proto 자유롭게**: 형태 다듬기로 돌아가기 OK
- **서버 관리**: 세션 종료 시 서버 종료 안내
- **단일 HTML 원칙**: 프레임워크 없이 바로 동작

## 고급: Live Reload (선택)

더 빠른 피드백을 원하면 live-server 사용:

```bash
# 설치 (npm 필요)
npm install -g live-server

# 실행 (자동 새로고침)
live-server --port=8080
```

live-server가 없으면 기본 python http.server 사용.
