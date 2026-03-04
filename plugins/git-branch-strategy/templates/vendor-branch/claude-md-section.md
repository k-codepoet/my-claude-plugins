## 브랜치 정책 (필수)

- **main에 직접 커밋 금지** — 반드시 작업 브랜치(feat/*, fix/*, chore/*) 또는 vendor 브랜치에서 작업 후 머지
- **vendor 코드 수정은 vendor/* 브랜치에서만** — main에서 vendor 코드 직접 수정 금지
- **흐름: feat/* → main, vendor/* → main (subtree merge)**
- **`--no-verify` 사용 금지** — pre-commit hook이 정책을 강제함
- 상세: [branching 스킬](.claude/skills/branching/SKILL.md)
