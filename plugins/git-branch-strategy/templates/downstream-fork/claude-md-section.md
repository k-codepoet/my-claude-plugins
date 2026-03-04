## 브랜치 정책 (필수)

- **main, {{INTEGRATION_BRANCH}}에 직접 커밋 금지** — 반드시 작업 브랜치(feat/*, fix/*, chore/*)에서 작업 후 머지
- **작업 브랜치는 {{INTEGRATION_BRANCH}}에서 파생** — main에서 파생하지 않음
- **흐름: feat/* → {{INTEGRATION_BRANCH}} → main**
- **`--no-verify` 사용 금지** — pre-commit hook이 정책을 강제함
- 상세: [branching 스킬](.claude/skills/branching/SKILL.md)
