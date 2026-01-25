# Changelog

All notable changes to the Gemify plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.30.0] - 2026-01-25

### Added
- **멀티 도메인 지원** - 도메인별 독립적인 지식 파이프라인 운영
  - `~/.gemify/{domain}/` 구조로 도메인 분리 (builder, leader, planner 등)
  - 각 도메인은 별도 git repo로 독립 관리 가능
  - config.json 기반 도메인 설정 관리
- **domain 스킬/명령어 추가** - 도메인 관리 기능
  - `/gemify:domain` - 현재 도메인 확인
  - `/gemify:domain list` - 도메인 목록 조회
  - `/gemify:domain set <name>` - 도메인 전환 (세션 시작 시 한 번 설정)
  - `/gemify:domain add <name>` - 새 도메인 추가

### Changed
- **scope 스킬 전면 개편** - 멀티 도메인 지원을 위한 경로 결정 로직 변경
  - 경로 결정 우선순위: 환경변수 → cwd 기반 → config.json current → 기본값
  - 최종 경로: `~/.gemify/{domain}/`
  - 도메인 전환 정책: 세션 시작 시 한 번만 설정 권장

## [1.29.0] - 2026-01-18

### Added
- **실행 문서 역제안 기능** - retro/library 스킬에 추가
  - library 저장 직후 실행 필요 여부 자동 판단
  - 플러그인 개선 → improvement 문서 제안
  - 신규 아이디어 → poc 문서 제안
  - 버그 해결 → bugfix 문서 제안
  - 사용자 승인 후 실행 문서 자동 생성

## [1.28.0] - 2026-01-18

### Changed
- Minor internal improvements

## [1.27.0] - 2026-01-18

### Changed
- **poc 스킬 파이프라인 재설계** - 라우터 + 하위 스킬 4개로 분리
  - poc: 상황 판단 → 하위 스킬로 라우팅 (라우터 역할)
  - poc-idea: 본질 질문으로 아이디어 정제 → inbox/thoughts 저장
  - poc-shape: ~/.gemify 재료 탐색 + 무의식 도출 → drafts 저장
  - poc-proto: HTML 즉시 생성 + 로컬 서버 실시간 미리보기
  - poc-pack: git repo 생성 + craftify/forgeify 핸드오프

### Added
- **실시간 피드백 루프** - poc-proto에서 로컬 개발 서버로 미리보기
  - python http.server 기반 (포트 8080)
  - 수정 → 새로고침으로 즉시 확인
  - shape ↔ proto 자유로운 전환
- **3가지 핵심 원칙 도입**
  - 실시간 피드백 루프
  - 본질 집중 (부차적인 것 잘라내기)
  - 무의식 끄집어내기 (계속 되묻기)

## [1.26.0] - 2026-01-18

### Changed
- **세션 리포트 파일명에 시분초 추가** - 같은 날 여러 세션 시 시간순 정렬 가능
  - 파일명: `YYYY-MM-DD-{slug}.md` → `YYYYMMDD-HHMMSS-{slug}.md`
  - frontmatter에 `created_at` 필드 추가 (ISO 8601 전체 타임스탬프)
  - 마이그레이션 스크립트 추가 (`scripts/migrate-sessions.sh`)

## [1.25.0] - 2026-01-18

### Changed
- **help.md 재구성** - 전체 기능 간략 소개로 통일
  - 예시 섹션 제거 (howto로 이동)
  - 누락 커맨드 추가 (vision, vision-review, troubleshoot, bugfix, poc, sync, triage, map)
  - 카테고리별 정리 (가이드/지식 파이프라인/비전 관리/문제 해결/세션·설정)
- **howto.md 재구성** - 주제별 사용법과 예시로 통일
  - 모든 주제에 예시 컬럼 추가
  - 누락 주제 추가 (vision, vision-review, troubleshoot, bugfix, poc, sync, triage, map)
  - 스킬 매핑 최신화

## [1.24.0] - 2026-01-17

### Changed
- **goals → visions 리네이밍** - 메타포 제거, 기능적 네이밍으로 통일
  - `/gemify:goal` → `/gemify:vision`
  - `/gemify:goal-review` → `/gemify:vision-review`
  - `goals/` → `visions/`
  - `north-star.md` → `definition.md`
  - `north-star.history/` → `definition.history/`
- gemify 파이프라인과 일관된 네이밍 (inbox, draft, library, view, vision)

## [1.23.0] - 2026-01-17

### Added
- **visions/ 시스템** - 비전(지향점) 관리 기능
  - `/gemify:vision [vision-name]` - 비전 생성/조회
  - `/gemify:vision-review [vision-name]` - 비전 대비 현재 상태 평가 + 리뷰 기록
  - `visions/{vision-name}/definition.md` - 비전 정의
  - `visions/{vision-name}/definition.history/` - 피보팅 이력
  - `visions/{vision-name}/current.md` - 현재 상태 스냅샷
  - `visions/{vision-name}/reviews/` - 평가 이력
- **scope 스킬 업데이트** - visions/ 경로 규칙 추가

## [1.22.0] - 2026-01-17

### Added
- **wrapup 자동 sync push** - 세션 리포트 저장 후 자동으로 remote에 push
  - git remote 설정 여부에 따른 조건부 실행
  - 성공/스킵/실패 상태 메시지 표시

### Changed
- **SessionStart hook 메시지 개선** - 동기화 성공 시 git short sha와 commit date 표시
  - 예: `✅ [gemify] ~/.gemify/ 동기화 완료 (abc1234 @ 2026-01-17 12:00:00 +0900)`

### Fixed
- **improve-plugin 핸드오프 버그 수정** - y 입력 시 직접 코드 수정하던 문제
  - Skill 도구로 `forgeify:improve-plugin` 호출 명시
  - 경고 문구 추가로 단방향 원칙 강조

### Removed
- **Stop hook 제거** - 제대로 동작하지 않아 삭제
  - `hooks/hooks.json`에서 Stop 이벤트 제거
  - `scripts/stop-hook.sh` 삭제

## [1.21.0] - 2026-01-17

### Changed
- **Views 폴더 구조 개편** - `by-subject` deprecated, 목적별로 명확한 분리
  - `by-plugin/` 신규: Claude Code 플러그인 전용 (gemify, forgeify, craftify 등)
  - `by-product/` 신규: 사용자용 제품/서비스 (tetritime, ai-company 등)
  - `by-essay/` 확장: 철학/에세이 (design-philosophy 등)
  - `by-subject/` deprecated: 플러그인/제품/에세이 혼재 문제 해결

### Added
- `by-plugin/_template.md` - 플러그인 view 템플릿
- `by-product/_template.md` - 제품 view 템플릿
- View 타입 선택 가이드 - 타입 미지정 시 분기 질문 추가

### Migration
- 기존 `by-subject/` 파일들은 `~/.gemify/` 저장소에서 수동 마이그레이션 필요
  - 플러그인 → `by-plugin/`
  - 제품/서비스 → `by-product/`
  - 철학/에세이 → `by-essay/`

## [1.20.0] - 2026-01-14

### Fixed
- **retro/triage Legacy Schema 버그 수정**
  - `library/{domain}/` → `library/{type}s/` 경로 체계 마이그레이션
  - retro가 과거 domain 기반 경로(library/ai-automation/ 등) 제안하던 문제 해결
  - 영향 파일: retro SKILL.md, retro.md, help.md, howto.md, CLAUDE.md (examples/empty)

### Changed
- **retro 사상 재정의**: "무조건 library 직행" → "밀도 평가 후 적절한 단계 제안"
  - inbox/draft/library 수준별 역방향 추적
  - 밀도 낮은 대화는 inbox부터 채우기 제안
- **triage 밀도 평가 추가**: 승격 제안 시 밀도 근거 제시 규칙

### Added
- `principles/` 디렉토리 - 공통 사상 문서
  - `pipeline-density.md`: 밀도 기반 파이프라인 사상
  - `classification-system.md`: type vs domain 분류 체계 설명
- 각 스킬(inbox, draft, library, retro, triage)에서 principles 참조 (Progressive Disclosure)

## [1.19.0] - 2025-01-13

### Added
- `/gemify:troubleshoot` - 버그/문제 분석 스킬
  - 증상 수집, 관련 코드 탐색, 가설 도출
  - inbox/materials/에 분석 기록 저장
  - bugfix 스킬과 연계 가능
- `/gemify:bugfix` - 버그 수정 문서 생성 스킬
  - 2-track 병렬 전략: Workaround(빠른 해결) + Root Cause(근본 해결)
  - 가설 우선순위 나열하여 순차 검증
  - views/by-bugfix/에 저장
  - forgeify/craftify로 핸드오프 시 병렬 실행 옵션
- `views/by-bugfix/` 카테고리 및 템플릿 추가

## [1.9.0] - 2026-01-03

### Changed
- `/gemify:capture-pair` → `/gemify:sidebar` 리네임
  - "let's sidebar this" - 본론 아닌 걸 옆으로 빼둠
  - 기능 변경 없음 (이름만 변경)

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
- `/gemify:sidebar` - material + thought 쌍으로 한번에 생성 (원명: capture-pair)
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
