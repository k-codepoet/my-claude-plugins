# Changelog

## [1.1.0] - 2026-03-04

### Added
- git-flow 스킬: Git Flow 패턴 레퍼런스 (main/develop/feature/release/hotfix)
- github-flow 스킬: GitHub Flow 패턴 레퍼런스 (main + feature → PR)
- gitlab-flow 스킬: GitLab Flow 패턴 레퍼런스 (환경별/릴리스 브랜치)
- trunk-based 스킬: Trunk-Based Development 레퍼런스 (짧은 수명 브랜치 + feature flag)
- release-branch 스킬: Release Branch 패턴 레퍼런스 (다중 버전 유지보수)
- forking-workflow 스킬: Forking Workflow 패턴 레퍼런스 (fork → upstream PR)
- 6개 신규 전략별 templates (pre-commit.sh, claude-md-section.md, branching-skill.md)

### Changed
- strategy-select 스킬: 8개 전략 전체를 진단 질문으로 커버
- setup 스킬: 8개 전략 전체의 스캐폴딩 지원
- help 커맨드: 범용/특수 전략 분류하여 12개 스킬 목록 표시
- plugin.json description 업데이트

## [1.0.0] - 2026-03-04

### Added
- strategy-select 스킬: 프로젝트 상황 진단 후 브랜치 전략 추천
- setup 스킬: 선택된 전략의 스캐폴딩 자동 생성
- downstream-fork 스킬: Downstream Fork 패턴 레퍼런스
- upstream-sync 스킬: upstream 동기화 절차
- vendor-branch 스킬: Vendor Branch 패턴 레퍼런스
- vendor-update 스킬: vendor 브랜치 업데이트 절차
- PreToolUse 훅: 보호 브랜치 직접 커밋 방지
- help 커맨드: 플러그인 도움말
