---
name: workflow-guide
description: Claude Code 플러그인 개발 실전 워크플로우 가이드. Skill, Agent, Plugin, Marketplace를 처음부터 만드는 단계별 예시가 필요할 때 사용합니다.
---

# 실전 워크플로우 가이드

## 1. Skill 만들기

```bash
mkdir pdf-processor
cd pdf-processor
```

**SKILL.md 작성:**

```markdown
---
name: pdf-processor
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF documents.
license: MIT
---

# PDF Processor

[지침 내용...]
```

```bash
# 검증
skills-ref validate ./pdf-processor
```

## 2. Agent 만들기

### 프로젝트용 Agent

```bash
mkdir -p .claude/agents
```

**.claude/agents/code-reviewer.md 작성:**

```markdown
---
name: code-reviewer
description: 코드 품질 검토 전문가. 코드 변경 후 PROACTIVELY 사용하세요.
tools: Read, Grep, Glob, Bash
model: inherit
---

당신은 시니어 코드 리뷰어입니다.

## 호출 시 수행할 작업
1. `git diff`로 최근 변경사항 확인
2. 수정된 파일에 집중하여 리뷰

## 검토 체크리스트
- 코드 가독성과 명확성
- 에러 처리 적절성
- 보안 (노출된 시크릿, API 키)
- 테스트 커버리지

## 피드백 형식
- **Critical**: 반드시 수정
- **Warnings**: 권장 수정
- **Suggestions**: 개선 고려
```

### 디버거 Agent

**.claude/agents/debugger.md 작성:**

```markdown
---
name: debugger
description: 에러와 테스트 실패 전문가. 문제 발생시 PROACTIVELY 사용하세요.
tools: Read, Edit, Bash, Grep, Glob
---

당신은 근본 원인 분석 전문가입니다.

## 디버깅 프로세스
1. 에러 메시지와 스택 트레이스 캡처
2. 재현 단계 파악
3. 실패 위치 격리
4. 최소 수정 구현
5. 솔루션 검증

## 각 문제마다 제공할 사항
- 근본 원인 설명 (증거 포함)
- 구체적인 코드 수정
- 재발 방지 권장사항
```

### Agent 사용

```bash
# /agents 명령어로 관리
/agents

# 대화에서 명시적 호출
> code-reviewer subagent로 최근 변경사항 검토해줘
> debugger subagent로 이 에러 분석해줘
```

## 3. Plugin으로 패키징 (Agents 포함)

```bash
mkdir my-plugin
cd my-plugin

# 디렉토리 구조 생성
mkdir -p .claude-plugin skills commands agents scripts
```

**.claude-plugin/plugin.json 작성:**

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "My custom plugin",
  "author": { "name": "Your Name" }
}
```

```bash
# Skill 복사
cp -r ../pdf-processor skills/

# Agent 복사
cp ../.claude/agents/code-reviewer.md agents/
cp ../.claude/agents/debugger.md agents/

# Git 저장소로 만들기
git init
git add .
git commit -m "Initial plugin"
```

## 4. Marketplace 만들기

```bash
mkdir my-marketplace
cd my-marketplace

# 구조 생성
mkdir -p .claude-plugin plugins
```

**.claude-plugin/marketplace.json 작성:**

```json
{
  "name": "my-marketplace",
  "owner": { "name": "your-name" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "My custom plugin"
    }
  ]
}
```

```bash
# 플러그인을 서브모듈로 추가 (또는 직접 복사)
git submodule add https://github.com/your-name/my-plugin plugins/my-plugin

# GitHub에 푸시
git init
git add .
git commit -m "Initial marketplace"
git remote add origin https://github.com/your-name/my-marketplace
git push -u origin main
```

## 5. 마켓플레이스 사용

```bash
# Claude Code에서
/plugin marketplace add your-name/my-marketplace
/plugin install my-plugin@my-marketplace
```
