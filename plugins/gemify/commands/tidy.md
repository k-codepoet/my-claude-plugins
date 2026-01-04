---
description: ground-truth 문서 점진적 정리 (역방향 검증)
allowed-tools: Read, Write, Edit, Glob, Grep
---

# /gemify:tidy - 문서 정리 커맨드

tidy 스킬을 호출하여 ground-truth 문서를 점진적으로 정리한다.

## 사용법

```
/gemify:tidy                    # 불일치 탐색 시작
/gemify:tidy views/             # views 폴더만 검사
/gemify:tidy library/           # library 폴더만 검사
```

## 동작

1. views ↔ artifact 일치 검사
2. 불일치 **하나만** 리포트
3. HITL 판단 요청 (A/B/C/D)
4. 사용자 컨펌 후 수정
5. 다음 tidy 호출 대기

## 탐색 우선순위

1. artifact 필드 누락
2. 깨진 링크
3. used 마킹 누락
4. outdated 감지
5. 중복 view

## HITL 선택지

```
[A] artifact 기준으로 view 업데이트
[B] view 기준으로 artifact 수정 (별도 작업)
[C] 둘 다 반영할 부분 있음 (수동)
[D] 나중에 볼게
```

## triage와의 관계

- **tidy**: 역방향 (기존 것 검증/수정)
- **triage**: 순방향 (새 inbox 연결)

권장 순서: tidy → triage
