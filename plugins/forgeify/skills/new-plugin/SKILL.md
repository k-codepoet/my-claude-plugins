---
name: new-plugin
description: 새 플러그인 생성. "플러그인 만들기", "new plugin", "plugin 생성" 등 요청 시 활성화.
---

# new-plugin Skill

## 개요

Claude Code 플러그인 전체를 생성합니다. 다른 new-* 스킬들을 조합하여 완전한 플러그인 구조를 만듭니다.

## 인자

```
/forgeify:new-plugin <name> [marketplace-path]

- name: 플러그인 이름 (예: my-awesome-plugin)
- marketplace-path: 마켓플레이스 경로 (기본: 현재 디렉토리)
```

## 워크플로우

### 1단계: 마켓플레이스 확인

1. `marketplace-path` 인자 확인
2. 마켓플레이스 구조 검증:
   ```
   {marketplace-path}/
   ├── .claude-plugin/
   │   └── marketplace.json
   └── plugins/
   ```
3. 구조가 아니면 에러 → references/error-handling.md 참조

### 2단계: 플러그인명 중복 확인

```
{marketplace-path}/plugins/{name}/
```

이미 존재하면 에러 → references/error-handling.md 참조

### 3단계: 플러그인 정보 수집 (대화)

사용자에게 질문:

```
새 플러그인을 생성합니다.

플러그인명: {name}

1. 플러그인 설명 (description):
   > 예: "PDF 문서 처리 자동화 플러그인"

2. 키워드 (keywords):
   > 쉼표로 구분
   > 예: pdf, document, automation

3. 작성자 이름 (author.name):
   > 예: myorg

4. 포함할 컴포넌트 (복수 선택):
   [ ] Commands - 슬래시 커맨드
   [ ] Skills - 자동 활성화 스킬
   [ ] Agents - 서브에이전트
   [ ] Hooks - 이벤트 훅
```

### 4단계: 기본 구조 생성

**디렉토리 생성**:
```
{marketplace-path}/plugins/{name}/
├── .claude-plugin/
│   └── plugin.json
├── commands/          (선택 시)
├── skills/            (선택 시)
├── agents/            (선택 시)
└── hooks/             (선택 시)
```

**plugin.json 생성**:
```json
{
  "name": "{name}",
  "version": "1.0.0",
  "description": "{description}",
  "author": {
    "name": "{author}"
  },
  "keywords": ["{keyword1}", "{keyword2}"],
  "commands": ["./commands/"],
  "skills": ["./skills/"]
}
```

### 5단계: 컴포넌트 생성 (조합)

선택한 컴포넌트별로 해당 스킬 호출:

| 컴포넌트 | 스킬 호출 |
|----------|-----------|
| Commands | Skill 도구로 `forgeify:new-command` 호출 |
| Skills | Skill 도구로 `forgeify:new-skill` 호출 |
| Agents | Skill 도구로 `forgeify:new-agent` 호출 |
| Hooks | Skill 도구로 `forgeify:new-hook` 호출 |

각 스킬 호출 시 `plugin-path`로 생성된 플러그인 경로 전달.

사용자에게 각 컴포넌트별로 이름과 상세 정보 질문.

### 6단계: 마켓플레이스 등록

`marketplace.json`에 플러그인 추가:

```json
{
  "plugins": [
    // ... 기존 플러그인들
    {
      "name": "{name}",
      "source": "./plugins/{name}",
      "description": "{description}"
    }
  ]
}
```

### 7단계: 검증

```
Skill 도구로 forgeify:validate 호출
인자: {plugin-path}
```

검증 실패 시 자동 수정 시도.

### 8단계: 완료 메시지

```
✅ 플러그인 생성 완료

경로: {marketplace-path}/plugins/{name}/
버전: 1.0.0

생성된 컴포넌트:
- Commands: {count}개
- Skills: {count}개
- Agents: {count}개
- Hooks: {count}개

설치:
  /plugin install {name}@{marketplace-name}

다음 단계:
- 각 컴포넌트 내용 검토 및 보강
- README.md 작성 (선택)
- /forgeify:validate로 재검증
```

## 규칙

1. **마켓플레이스 필수**: 독립 플러그인이 아닌 마켓플레이스 내 생성
2. **중복 방지**: 동일 이름 플러그인 존재 시 에러
3. **검증 필수**: 생성 후 반드시 validate 실행
4. **버전 1.0.0**: 새 플러그인은 1.0.0으로 시작

## 에러 처리

상세 에러 메시지는 `references/error-handling.md` 참조.

## 참조

- plugin-guide 스킬의 상세 규격 참조
- new-command, new-skill, new-agent, new-hook 스킬 호출
