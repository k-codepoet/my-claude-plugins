---
name: create
description: 새 프로젝트 생성. turborepo + boilerplate 복제. /craftify:create webapp my-app 형태로 호출.
allowed-tools: Read, Write, Bash, Glob
argument-hint: <type> <name> [--ssr|--spa] [--path <path>]
---

# /craftify:create

새 프로젝트를 **turborepo 기반**으로 생성합니다.

## 사용법

```
/craftify:create <type> <name> [options]
```

### 지원 타입

| 타입 | 설명 | 스택 |
|------|------|------|
| `webapp` | 웹 애플리케이션 | React Router 7 + Cloudflare |

### 옵션

| 옵션 | 설명 | 기본값 |
|------|------|--------|
| `--ssr` | SSR 모드 (Cloudflare Workers) | true |
| `--spa` | SPA 모드 (정적 배포) | false |
| `--path` | 생성 경로 | 현재 디렉토리 |

## 동작

1. **타입과 이름 확인**
   - `webapp` 타입이면 계속 진행
   - 인자 부족 시 setup-wizard 에이전트 호출

2. **boilerplate 복제**
   - SSR: `${CLAUDE_PLUGIN_ROOT}/templates/webapp/` 기반 생성
   - 템플릿 가이드 참조

3. **turborepo 구조 생성**
   ```
   {name}/
   ├── apps/
   │   └── web/          # boilerplate 복제
   ├── packages/         # 공유 패키지 (향후)
   ├── turbo.json
   ├── package.json
   ├── pnpm-workspace.yaml
   ├── CRAFTIFY.md       # 사용법 가이드
   └── .craftify/
       └── guides/       # 단계별 가이드
   ```

4. **CRAFTIFY.md 생성** - 사용법 안내

5. **의존성 설치 안내**
   ```bash
   cd {name} && pnpm install
   ```

## References

상세 형식과 예시는 스킬 참조:
- `skills/create/SKILL.md` - 생성 스킬 상세
- `skills/create/references/project-structure.md` - 프로젝트 구조 상세
