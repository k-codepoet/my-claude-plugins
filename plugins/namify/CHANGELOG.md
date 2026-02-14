# Changelog

All notable changes to the Namify plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-02-14

### Changed
- **commands → skills 통합** - action commands를 삭제하고 skills로 일원화
  - `commands/name.md` 삭제 → `skills/name/SKILL.md`로 통합
  - `commands/help.md`, `commands/howto.md`만 유지 (문서)
- **plugin.json commands 경로 변경** - `["./commands/name.md"]` → `["./commands/"]`
- **help.md 용어 변경** - "커맨드" → "기능"

## [1.1.0] - 2026-01-18

### Added
- **help.md 신규 생성** - 전체 기능 간략 소개
  - 태그라인 + 한줄 설명
  - 커맨드 테이블 (가이드/네이밍)
  - 네이밍 흐름 다이어그램
- **howto.md 신규 생성** - 주제별 사용법과 예시
  - 네이밍 주제 (name, pattern, series, naming-guide)
  - 메타포 종류, 패턴 종류, 검증 체크리스트

## [1.0.0] - 2026-01-03

### Added
- 초기 릴리즈
- 제품/서비스 네이밍 워크플로우
- 메타포 탐색, 이름 생성, 문화적 검증
- naming-guide 스킬
