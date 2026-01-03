# Changelog

All notable changes to the Gemify plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.7.0] - 2026-01-03

### Changed
- `/gemify:improve-plugin` - 역할 리팩토링
  - 기존: 플러그인 경로를 add-dir로 추가하고 직접 코드 수정
  - 변경: 개선 문서 생성 전용으로 역할 축소
  - 실제 코드 수정은 `/forgeify:improve-plugin`으로 위임
  - 단방향 흐름 구축: gemify(지식 생산) → forgeify(실행)
- `improve-plugin` 스킬 - 문서 생성 전용으로 변경
  - 개선 문서 스키마(frontmatter + body) 적용
  - 출력 위치: `library/engineering/plugin-improvements/`

## [1.6.0] - 2026-01-02

### Added
- `/gemify:view` - Views 레이어 기능
  - library 지식을 주제(subject)별로 조합
  - 도식 + 스토리 구조로 지식을 창문처럼 바라봄
  - views/by-subject/{subject}.md에 저장
  - library 문서에 `views: [subject]` 태그로 양방향 연결

## [1.5.0] - 2026-01-02

### Added
- `/gemify:retro` - 사후처리 기능. 이미 완료된 작업을 역방향으로 library에 기록
  - drafts를 건너뛰는 단축 경로
  - `created_via: retro` 필드로 사후 기록 표시
- `/gemify:capture-pair` - material + thought 쌍으로 한번에 생성
  - 대화에서 외부 기록과 내 생각을 동시에 추출
  - thought의 references에 material 자동 연결

### Changed
- inbox/import 스킬에 파일명 규칙 강조 추가
  - `YYYY-MM-DD-{slug}.md` 형식 필수 명시

## [1.4.0] - 2026-01-02

### Added
- `/gemify:improve-plugin` - 플러그인 개선 워크플로우
  - add-dir로 플러그인 스코프 추가 후 작업

## [1.3.0] - 2025-12-31

### Added
- `/gemify:import` - 외부 재료 가져오기 (inbox/materials/)
- `/gemify:howto` - 사용법 가이드

### Changed
- inbox 구조 분리: thoughts/ (내 생각), materials/ (외부 재료)

## [1.2.0] - 2025-12-31

### Added
- `/gemify:setup` - 지식 파이프라인 구조 초기화
- assets/empty, assets/examples 템플릿

## [1.1.0] - 2025-12-30

### Added
- `/gemify:library` - drafts를 library로 정리
- 6대 Domain 분류 체계

## [1.0.0] - 2025-12-30

### Added
- `/gemify:inbox` - 생각 포착 (inbox/thoughts/)
- `/gemify:draft` - 원석 다듬기 (facet/polish 모드)
- `/gemify:help` - 도움말
