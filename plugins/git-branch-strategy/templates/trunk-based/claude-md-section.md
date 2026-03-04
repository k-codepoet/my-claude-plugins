## 브랜치 정책 (필수)

- **main(trunk)이 유일한 장수 브랜치** — develop, staging 등 별도 브랜치 없음
- **작업 브랜치 수명 1~2일 이내** — 짧게 만들고 빠르게 머지
- **main은 항상 배포 가능 상태 유지** — CI 통과 필수
- **미완성 기능은 Feature Flag로 숨긴다** — 코드는 머지하되 기능은 비활성화
- **`--no-verify` 사용 금지** — pre-commit hook이 정책을 강제함
- 상세: [branching 스킬](.claude/skills/branching/SKILL.md)
