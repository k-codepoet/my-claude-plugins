## 브랜치 정책 (필수)

- **main, release/* 에 직접 커밋 금지** — 반드시 작업 브랜치(feat/*, fix/*, chore/*)에서 작업 후 머지
- **릴리스 브랜치에서는 버그 수정만** — 새 기능은 main에서만 개발
- **흐름: feat/* → main → release/x.y → tag vx.y.z**
- **릴리스 수정사항은 main에 역머지** — 수정 누락 방지
- **`--no-verify` 사용 금지** — pre-commit hook이 정책을 강제함
- 상세: [branching 스킬](.claude/skills/branching/SKILL.md)
