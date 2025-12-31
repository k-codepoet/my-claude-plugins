---
name: update
description: 플러그인 내용을 최신 가이드라인으로 갱신합니다. 기존 기능 개선, 최신 규격 반영, 문서 업데이트가 필요할 때 사용합니다.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, WebFetch
argument-hint: [plugin-path] [--check-only]
---

# Plugin Update to Latest Guidelines

기존 플러그인의 내용을 최신 Claude Code 가이드라인으로 갱신합니다.

## 사용법

```
/ced:update                       # 현재 디렉토리 플러그인 업데이트
/ced:update ./plugins/my-plugin   # 특정 플러그인 업데이트
/ced:update --check-only          # 변경 필요 사항만 확인 (수정 없음)
```

## 업데이트 영역

### 1. Frontmatter 최신화

**Commands** - 최신 필드 추가/수정:
- `allowed-tools`: 필요한 도구만 명시적으로 선언
- `argument-hint`: 사용법 힌트 추가

**Agents** - 최신 필드 추가/수정:
- `model`: inherit → 구체적 모델 지정 검토
- `permissionMode`: 권한 모드 명시
- `skills`: 연관 스킬 자동 로드 설정

**Skills** - 최신 필드 추가/수정:
- `license`: 라이선스 정보 추가
- `compatibility`: 환경 요구사항 명시
- `metadata`: 버전, 작성자 정보 추가

### 2. 본문 내용 개선

**Description 품질 향상**:
- 무엇을 하는지 + 언제 사용하는지 포함
- 트리거 키워드 명확화
- 한/영 일관성 유지

**Example 블록 추가** (Agents):
```markdown
<example>
Context: ...
user: "..."
assistant: "..."
<commentary>...</commentary>
</example>
```

**Progressive Disclosure 적용** (Skills):
- 본문 5000 토큰 이하로 압축
- 상세 내용은 `references/` 폴더로 분리
- 핵심 워크플로우만 SKILL.md에 유지

### 3. 구조 현대화

**네이밍 컨벤션**:
- 플러그인명: 짧은 prefix 권장 (예: `ced`, `sc`)
- 커맨드명: `{prefix}:{action}` 형식
- 스킬명: 소문자+하이픈, 디렉토리명 일치

**스크립트 현대화**:
- `${CLAUDE_PLUGIN_ROOT}` 환경변수 활용
- 색상 출력 표준화 (green/yellow/red)
- 멱등성 패턴 적용

### 4. 문서 업데이트

**README.md 갱신**:
- 새로운 커맨드 목록 반영
- 설치 방법 최신화
- 사용 예시 추가

**CHANGELOG.md 추가/갱신**:
- 버전별 변경사항 기록
- 주요 변경점 하이라이트

## 업데이트 프로세스

1. **현재 상태 분석**
   - 모든 구성요소 스캔
   - 버전 및 최종 수정일 확인
   - 사용 중인 패턴 파악

2. **최신 가이드라인 대조**
   - ced 스킬들의 최신 규격 참조
   - 차이점 목록화

3. **변경 계획 수립**
   - 필수 변경 (Breaking)
   - 권장 변경 (Enhancement)
   - 선택 변경 (Nice-to-have)

4. **사용자 확인**
   - 변경 계획 표시
   - 항목별 승인 요청

5. **변경 적용**
   - 승인된 항목만 수정
   - 백업 없이 직접 수정 (git으로 관리 가정)

6. **버전 업데이트**
   - plugin.json 버전 증가
   - CHANGELOG 갱신

## 출력 형식

```
## Update Plan: {plugin-name} (v1.0.0 → v1.1.0)

### Breaking Changes (필수)
None

### Enhancements (권장)
1. [commands/help.md] Add argument-hint field
2. [agents/setup.md] Add example blocks (currently 0)
3. [skills/guide/SKILL.md] Split references to separate files

### Nice-to-have (선택)
1. [plugin.json] Add homepage field
2. [README.md] Add usage examples

Apply updates? [A]ll / [S]elect / [N]one
```

## 주의사항

- 기존 기능이 손상되지 않도록 주의
- 변경 전 git status 확인 권장
- 대규모 변경 시 별도 브랜치에서 작업 권장
