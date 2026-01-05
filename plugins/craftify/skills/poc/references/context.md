# Context 필드 활용 가이드

POC.md의 Context 섹션에는 gemify가 수집한 참조 자료 경로가 포함될 수 있습니다.

## Context 섹션 예시

```markdown
## Context

- `library/specs/auth-flow.md` - 인증 플로우 스펙
- `inbox/materials/competitor-analysis.md` - 경쟁사 분석
- `대화 요약`: "OAuth2 기반 소셜 로그인 필요"
```

## 활용 방법

1. **구현 시작 전**: Context 섹션의 문서 경로 확인
2. **필요시 읽기**: What 구현 중 맥락이 필요할 때 해당 문서 참조
3. **읽지 않아도 되는 경우**: What과 AC만으로 구현이 명확할 때

## Progressive Disclosure 원칙

- Context 문서는 **항상 읽을 필요 없음**
- 구현 중 "왜 이렇게 해야 하지?" 의문이 생길 때 참조
- gemify가 Why/What에 핵심은 이미 포함시킴

## 경로 규칙

| 경로 패턴 | 위치 |
|----------|------|
| `library/...` | gemify ground-truth |
| `inbox/...` | gemify inbox |
| `대화 요약` | POC.md 내 인라인 텍스트 |
