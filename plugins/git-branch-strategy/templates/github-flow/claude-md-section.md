## 브랜치 정책 (필수)

- **main에 직접 커밋 금지** — 반드시 작업 브랜치(feature/*, fix/*, chore/*)에서 작업 후 PR 머지
- **작업 브랜치는 main에서 파생**
- **흐름: feature/* → PR → main**
- **PR은 반드시 리뷰를 받는다** — 최소 1명 이상 승인
- **`--no-verify` 사용 금지** — pre-commit hook이 정책을 강제함
- 상세: [branching 스킬](.claude/skills/branching/SKILL.md)
