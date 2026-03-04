## 브랜치 정책 (필수)

- **main, develop에 직접 커밋 금지** — 반드시 작업 브랜치(feature/*, release/*, hotfix/*)에서 작업 후 머지
- **feature 브랜치는 develop에서 파생** — main에서 파생하지 않음
- **흐름: feature/* → develop, release/* → main+develop, hotfix/* → main+develop**
- **main에 머지 시 태그 생성** (시맨틱 버전)
- **`--no-verify` 사용 금지** — pre-commit hook이 정책을 강제함
- 상세: [branching 스킬](.claude/skills/branching/SKILL.md)
