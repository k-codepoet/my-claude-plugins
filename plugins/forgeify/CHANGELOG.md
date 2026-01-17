# Changelog

All notable changes to the Forgeify plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.13.0] - 2026-01-17

### Added
- **principles/ 디렉토리** - forgeify 설계 원칙 문서
  - `script-repetitive-tasks.md`: 정형화된 작업은 스크립트로 원칙
- **plugin-guide scripts/ 섹션** - 스크립트 작성 가이드라인 추가
  - 스크립트화 판단 기준
  - 작성 원칙 (exit code, 출력 형식, 권한)

## [1.12.0] - 2026-01-17

### Added
- **validate-plugin.sh 스크립트** - 플러그인 기본 검증 자동화
  - plugin.json 필수 필드 검증
  - commands/skills/agents/hooks 구조 검증
  - Exit code로 결과 반환 (0: 통과, 1: 실패, 2: 경로 오류)
- **improve-plugin 8단계 CHANGELOG 업데이트** - 변경 적용 후 CHANGELOG.md 수정 단계 추가
  - improvement_type에 따라 Added/Fixed/Changed 섹션 자동 결정

### Changed
- **validate 스킬 프로세스 개선** - 스크립트 우선 실행 후 상세 검증
  - 1단계: validate-plugin.sh 실행
  - 2단계: 상세 검증 (필요시 가이드 스킬 참조)
  - 3단계: 리팩토링

## [1.11.0] - 2026-01-14

### Added
- **bugfix 스킬** - gemify:bugfix 문서 기반 버그 수정 실행
  - 2-track 병렬 전략 지원 (Workaround + Root Cause)
  - views/by-bugfix/ 문서 파싱

## [1.10.0] - 2026-01-14

### Fixed
- **marketplace-guide 소스 저장소 검증** - source 필드 URL 유효성 검사 추가
