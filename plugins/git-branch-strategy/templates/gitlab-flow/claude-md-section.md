## 브랜치 정책 (필수)

- **main, pre-production, production에 직접 커밋 금지** — 반드시 작업 브랜치(feat/*, fix/*, chore/*)에서 작업 후 머지
- **코드 흐름은 단방향** — main → pre-production → production
- **main에서 먼저 수정 후 downstream 전파** — 역방향 머지 금지
- **`--no-verify` 사용 금지** — pre-commit hook이 정책을 강제함
- 상세: [branching 스킬](.claude/skills/branching/SKILL.md)
