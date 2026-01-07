# Plugin Structure

## 기본 구조

```
plugins/{plugin-name}/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 매니페스트
├── commands/
│   └── *.md                  # 슬래시 커맨드
├── skills/
│   └── {skill-name}/
│       ├── SKILL.md          # 스킬 정의
│       └── references/       # 참조 문서 (선택)
└── agents/                   # 자연어 트리거 (선택)
    └── *.md
```

## plugin.json

```json
{
  "name": "{plugin-name}",
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

agents가 있는 경우:
```json
{
  "agents": ["./agents/agent-name.md"]
}
```

**주의**: agents는 디렉토리가 아닌 개별 파일 경로 사용

## Commands

```yaml
---
description: 커맨드 설명
allowed-tools: Read, Write, Bash
argument-hint: [옵션 설명]
---

# /{plugin}:{command}

커맨드 내용...
```

## Skills

```yaml
---
name: {skill-name}
description: 스킬 설명. "트리거 키워드" 등 요청 시 활성화.
---

# {Skill Name} Skill

스킬 내용...
```

**파일 구조**: `skills/{skill-name}/SKILL.md` (SKILL.md는 대문자)

## Agents

```yaml
---
name: {agent-name}
description: 에이전트 트리거 조건 상세 설명
model: inherit
tools: ["Read", "Write", "Bash"]
---

# {Agent Name}

에이전트 지시사항...

<example>
Context: ...
user: "..."
assistant: "..."
<commentary>트리거 이유</commentary>
</example>
```

**필수**: `<example>` 블록 포함

## 컴포넌트 선택 가이드

| 용도 | 컴포넌트 |
|------|----------|
| 명시적 실행 (`/plugin:cmd`) | Command |
| 자동 컨텍스트 제공 | Skill |
| 자연어 트리거 | Agent |
| 스크립트 실행 | scripts/ + Command |
