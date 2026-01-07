---
name: map
description: 지식 클러스터 맵 생성/관리 - library/views 분석하여 대주제/소주제 구조화. triage에서 참조됨.
---

# Map Skill

library/views를 분석하여 **클러스터 맵**을 생성하고 관리합니다.

## 사전 확인 (필수)

**스킬 실행 전 반드시 확인:**

```
~/.gemify/ 존재?
├── 예 → 스킬 실행 계속
└── 아니오 → setup 안내 후 중단
```

Setup 안내:
```
~/.gemify/가 설정되지 않았습니다.

설정하기:
  /gemify:setup              # 새로 시작
  /gemify:setup --clone URL  # 기존 repo 가져오기
```

## 핵심 개념

클러스터 맵은 지식 체계의 **기준점**:
- 대주제 / 소주제 관계
- 기존 지식 분류 구조
- inbox 편입 판단 기준

## 저장 위치

```
meta/
└── cluster/
    ├── current.md          # 최신 버전 (항상 이걸 참조)
    └── .history/
        ├── 2026-01-04-v1.md
        └── ...
```

## current.md 포맷

```yaml
---
created: 2026-01-04
updated: 2026-01-04
version: 1
---

clusters:
  - name: "gemify 생태계"
    subjects: [gemify, forgeify]
    keywords: [지식, 플러그인, draft, library]

  - name: "-ify 트릴로지"
    subjects: [gemify, terrafy, craftify]
    keywords: [what, where, how]

  - name: "인프라"
    subjects: [terrafy]
    keywords: [docker, k8s, infra]
```

## 동작 흐름

### 1. library/views 분석

```
library/views 분석 중...

## 발견된 클러스터 (3개)

1. gemify 생태계
   - subjects: gemify, forgeify
   - views: 2개
   - library: 15개

2. -ify 트릴로지
   - subjects: gemify, terrafy, craftify
   - views: 3개
   - library: 8개

3. 인프라
   - subjects: terrafy
   - views: 1개
   - library: 3개

이대로 저장할까요?
[Y] 저장  [n] 취소  [c] 커스텀 수정
```

### 2. 커스텀 수정

```
> c

어떻게 수정할까요?
(예: "gemify, forgeify는 지식 생산 도구로 묶어줘")
(예: "인프라 클러스터에 devops 키워드 추가")

> namify는 gemify 생태계에 넣어줘

수정된 클러스터:
1. gemify 생태계
   - subjects: gemify, forgeify, namify  ← 추가됨
   ...

저장할까요? [Y/n/c]
```

### 3. 저장

저장 시:
1. 기존 `current.md` → `.history/YYYY-MM-DD-vN.md` 이동
2. 새 버전 `current.md` 저장
3. version 필드 증가

## triage와의 관계

triage가 map을 **선행 스킬로 참조**:

```
/gemify:triage 요청
    ↓
meta/cluster/current.md 있나?
    ├─ 있음 → triage 본체 실행
    └─ 없음 → "클러스터 맵이 없습니다. 먼저 생성할까요? [Y/n]"
                ├─ Y → map 스킬 호출 → 저장 → triage 이어가기
                └─ n → 종료
```

## 규칙

- **HITL 필수**: 자동 저장 없음, 항상 사용자 확인
- **버전 관리**: 변경 시 `.history/`에 스냅샷
- **단일 진입점**: 직접 호출보다 triage에서 참조되는 것이 일반적
