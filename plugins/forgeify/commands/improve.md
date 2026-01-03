---
description: ground-truth 개선 문서를 읽고 해당 플러그인을 수정합니다. 지식 생산(gemify)과 실행(forgeify) 분리 원칙에 따라 외부 문서 기반으로 플러그인을 개선합니다.
argument-hint: "<improvement-doc-path>"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /forgeify:improve - 개선 문서 기반 플러그인 수정

ground-truth에서 생성된 개선 문서를 읽고, 해당 내용에 따라 플러그인을 수정합니다.

## 사용법

```
/forgeify:improve <improvement-doc-path>
```

- `<improvement-doc-path>`: ground-truth 개선 문서 경로 (예: `/path/to/library/engineering/plugin-improvements/my-feature.md`)

## 워크플로우

상세 가이드는 **improve-plugin** 스킬을 참조합니다.

1. **개선 문서 파싱**: frontmatter에서 target_plugin, requirements 추출
2. **대상 플러그인 확인**: plugins/{target_plugin}/ 탐색
3. **참조 문서 로드**: references/ 폴더가 있으면 추가 참조
4. **개선 계획 수립**: 변경 계획 목록 작성
5. **사용자 확인**: 변경 계획 승인 요청
6. **변경 적용**: 파일 생성/수정, 버전 업데이트
7. **검증**: `/forgeify:validate` 자동 호출

## 예시

```
/forgeify:improve /path/to/ground-truth/library/engineering/plugin-improvements/forgeify-new-feature.md
```

## 주의사항

- 자동 실행 없음: 모든 변경은 사용자 확인 후 진행
- 개선 문서 형식이 잘못된 경우 에러 표시
- 대규모 변경 시 git status 확인 권장
