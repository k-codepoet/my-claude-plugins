# Changelog

All notable changes to the Craftify plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.1] - 2026-01-18

### Changed
- **poc 스킬 필수 규칙 추가** - 워크플로우 진행 전 반드시 준수할 규칙 상단 배치
  - How는 craftify가 판단 (POC.md 기술 스택 무시)
  - 대화 없이 진행 금지 (사용자 선택 전 코드 작성 금지)
  - boilerplate 필수 사용 (npx create-* 직접 실행 금지)
- **워크플로우 단계 수정** - 5단계 → 6단계 (실제 단계와 일치)

## [0.4.0] - 2026-01-18

### Added
- **help.md 신규 생성** - 전체 기능 간략 소개
  - 태그라인 + 한줄 설명
  - 커맨드 테이블 (가이드/프로젝트 개발)
  - 워크플로우 개요

### Changed
- **howto.md 재구성** - 주제별 사용법과 예시로 통일
  - 프로젝트 개발 카테고리
  - 예시 컬럼 추가 (poc, deploy)

## [0.3.0] - 2026-01-05

### Added
- poc 스킬 Progressive Disclosure 적용
- deploy 스킬 Cloudflare Dashboard Git 연결 방식으로 통일

## [0.2.0] - 2026-01-03

### Added
- 초기 릴리즈
- POC.md 기반 프로젝트 구현
- Cloudflare 배포 자동화
