## 브랜치 정책 (필수)

- **main에 직접 커밋 금지** — upstream 동기화 전용. 반드시 작업 브랜치(feat/*, fix/*, chore/*)에서 작업
- **모든 기여는 Pull Request로** — origin/feat/* → upstream/main PR 생성
- **흐름: feat/* → push origin → PR → upstream/main**
- **`--no-verify` 사용 금지** — pre-commit hook이 정책을 강제함
- 상세: [branching 스킬](.claude/skills/branching/SKILL.md)
