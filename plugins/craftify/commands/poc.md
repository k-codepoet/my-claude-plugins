---
name: poc
description: POC.md 기반 프로젝트 구현
allowed-tools: Read, Write, Bash, Glob
argument-hint: [POC.md 경로]
---

# /craftify:poc

POC.md를 읽고 프로젝트를 구현합니다.

## 사용법

```
/craftify:poc [POC.md 경로]
```

## 인자 처리

```
$ARGUMENTS 있음?
├── 예 → 해당 경로의 POC.md 읽기
└── 아니오 → 사용자에게 경로 요청 또는 gemify:poc 안내
```

**ARGUMENTS**: $ARGUMENTS

## 동작

1. POC.md 읽기 (인자로 받은 경로 또는 사용자 입력)
2. 문서 분석 (Why/What/AC + 기술스택 지정 여부 확인)
3. How 판단 (boilerplate-guide 스킬 활용)
4. boilerplate 복제 + 빌드 확인 + 배포
5. What 기반 코드 구현
6. AC 검증

## References

상세 워크플로우는 스킬 참조:
- `skills/poc/SKILL.md` - PoC 구현 스킬 상세
- `skills/boilerplate-guide/SKILL.md` - boilerplate 선택 가이드
