# Changelog

All notable changes to the Forgeify plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.17.0] - 2026-01-18

### Changed
- **improve-plugin 커맨드 스킬 호출 방식 개선** - Skill 도구 사용 명시
  - `argument-hint`에 `<plugin-name>` 추가
  - `allowed-tools`에 `Skill` 추가
  - 인자 부족 시 사용법 안내 메시지 추가
  - "스킬 참조" → "Skill 도구로 스킬 호출" 명시적 지시로 변경

## [1.16.0] - 2026-01-18

### Added
- **validate changelog 검증** - CHANGELOG.md와 코드 변경 일치 여부 검증
  - plugin.json 버전과 CHANGELOG.md 최신 버전 비교
  - git history 기반 변경 파일 추적 (CHANGELOG 날짜 이후)
  - 불일치 시 Warning 출력 및 권장 조치 안내
  - 의미 없는 파일 필터링 (CHANGELOG.md, .gitignore 등 제외)

## [1.15.0] - 2026-01-18

### Changed
- **help.md 재구성** - 전체 기능 간략 소개로 통일
  - 예시 섹션 제거 (howto로 이동)
  - 카테고리별 정리 (가이드/플러그인 개발/문제 해결)
- **howto.md 재구성** - 주제별 사용법과 예시로 통일
  - 개발 가이드와 플러그인 작업으로 카테고리 분리
  - 모든 주제에 예시 컬럼 추가
  - 플러그인 개발 흐름 다이어그램 추가

### Added
- **boilerplate/plugin-template/** - 플러그인 개발용 boilerplate
  - plugin.json, help.md, howto.md, sample.md, SKILL.md 템플릿
  - README.md (사용 가이드, placeholder 목록)

## [1.14.0] - 2026-01-17

### Added
- **command-guide Command-Skill 1:1 쌍 원칙** - 모든 기능 커맨드는 대응하는 스킬과 1:1 쌍 필수
  - Single Source of Truth, AI Agent 위임, Progressive Disclosure 원칙 설명
- **command-guide 스킬 명시적 로드 규칙** - 커맨드에서 스킬 Read를 명시적으로 지시
  - 잘못된 예 vs 올바른 예 비교
  - 커맨드는 진입점, 스킬이 로직 담당하는 구조 명확화

### Removed
- **Stop hook 제거** - 제대로 동작하지 않아 삭제
  - `hooks/hooks.json`에서 Stop 이벤트 제거
  - `scripts/stop-hook.sh` 삭제

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
