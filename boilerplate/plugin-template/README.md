# Plugin Template

Claude Code 플러그인 boilerplate입니다.

## 사용법

1. `plugin-template/` 폴더를 복사
2. `{{placeholder}}`를 실제 값으로 교체
3. `plugins/` 폴더로 이동
4. `marketplace.json`에 등록

## 구조

```
plugin-template/
├── .claude-plugin/
│   └── plugin.json       # 플러그인 메타데이터
├── commands/
│   ├── help.md           # 전체 기능 간략 소개
│   ├── howto.md          # 주제별 사용법과 예시
│   └── sample.md         # 커맨드 템플릿
├── skills/
│   └── sample/
│       └── SKILL.md      # 스킬 템플릿
└── README.md
```

## Placeholder 목록

| Placeholder | 설명 | 예시 |
|-------------|------|------|
| `{{plugin-name}}` | 플러그인 이름 (kebab-case) | `gemify` |
| `{{Plugin Name}}` | 플러그인 표시 이름 | `Gemify` |
| `{{tagline}}` | 한 줄 태그라인 | `Turn your thoughts into gems` |
| `{{description}}` | 설명 | `개인 지식 파이프라인` |
| `{{author}}` | 작성자 | `choigawoon` |
| `{{keyword1}}`, `{{keyword2}}` | 키워드 | `knowledge`, `pipeline` |
| `{{command}}`, `{{command1}}` | 커맨드 이름 | `inbox`, `draft` |
| `{{topic1}}`, `{{topic2}}` | howto 주제 | `inbox`, `draft` |

## help/howto 규칙

### help.md (전체 기능 간략 소개)
- 태그라인 + 한 줄 설명
- 커맨드 테이블 (카테고리별)
- 예시는 howto로 위임

### howto.md (주제별 사용법과 예시)
- 주제 테이블에 **예시 컬럼 필수**
- 스킬 매핑 명시
- 필요시 개념 설명 추가

## 참고

- forgeify의 `skills/*/SKILL.md` 가이드 참조
- gemify를 실제 적용 예시로 참조
