---
description: 제품/서비스 이름을 생성합니다. 메타포 탐색 → 후보 생성 → 검증 → 추천 흐름으로 진행합니다.
argument-hint: "<제품 설명> [--pattern <패턴>] [--series <기존 이름>]"
---

# /name - 제품/서비스 이름 생성

제품 설명을 기반으로 이름 후보를 생성하고 추천합니다.

## 사용법

```
/namify:name <제품 설명>
/namify:name <제품 설명> --pattern "-ify"
/namify:name <제품 설명> --series "Gemify"
```

## 옵션

- `--pattern`: 적용할 이름 패턴 (-ify, Craft, Lab, Hub 등)
- `--series`: 기존 이름으로부터 패턴 추출하여 일관성 유지

## 워크플로우

사용자 입력을 받으면 다음 5단계로 진행:

### 1단계: 핵심 가치 추출

제품 설명에서 핵심 동작과 가치를 한 문장으로 정리:
- "이 제품이 하는 일은?"
- 핵심 동사 추출 (변환, 생성, 연결, 자동화 등)

### 2단계: 메타포 탐색

핵심 가치에 맞는 메타포 후보 3-5개 제안:

| 메타포 | 적합한 경우 | 예시 |
|--------|-------------|------|
| 광물/보석 | 정제, 가치 상승 | Gem, Crystal, Diamond |
| 식물 | 성장, 육성 | Seed, Bloom, Garden |
| 건축 | 구축, 기반 | Foundation, Scaffold, Tower |
| 도구 | 제작, 장인정신 | Craft, Forge, Workshop |
| 과학 | 실험, 연구 | Lab, Studio, Reactor |

### 3단계: 이름 생성

선택된 메타포 + 패턴으로 이름 후보 5-10개 생성:

**패턴 종류**:
- `-ify`: 변환/생성 (Shopify, Spotify, Gemify)
- `Craft`: 장인정신 (Minecraft, Warcraft)
- `Lab`: 실험/연구 (GitLab, Hashlab)
- `Hub`: 중심/연결 (GitHub, DockerHub)
- 단일어: 강렬함 (Notion, Slack, Figma)

**--series 옵션 시**:
기존 이름에서 패턴 추출하여 동일 패턴 적용

### 4단계: 검증

각 후보에 대해 간단 검증:

| 항목 | 체크 |
|------|------|
| 발음 | 쉽게 발음되는가? |
| 기존 의미 | 부정적 의미, 슬랭 아닌가? |
| 검색 가능성 | 기존 유명 제품과 혼동 없는가? |
| 문화적 적합성 | 타겟 문화권에서 자연스러운가? |

### 5단계: 추천 + 이유

상위 3개 추천과 선택 이유 제시:

```
추천 1: [이름]
- 메타포: [선택 메타포]
- 패턴: [적용 패턴]
- 태그라인 제안: "[동사] your [대상] into [결과]"
- 선택 이유: [간단한 이유]
```

## 예시

### 기본 사용

```
/namify:name "생각을 정제해서 지식으로 만드는 도구"

→ 핵심 가치: 정제, 변환, 가치 상승
→ 메타포: 광물/보석 (정제 과정과 일치)
→ 후보: Gemify, Refinery, Polisher, MindGem, ThoughtCraft
→ 추천:
  1. Gemify - "-ify" 변환 패턴, 보석 메타포
  2. Refinery - 정제 의미 직접 표현
  3. ThoughtCraft - 장인정신 + 생각
```

### 패턴 지정

```
/namify:name "인프라 자동화 도구" --pattern "-ify"

→ 핵심 가치: 기반 구축, 자동화
→ 메타포: 건축/땅 (인프라와 연결)
→ 후보: Terrafy, Infrafy, Groundify, Baseify
→ 추천:
  1. Terrafy - Terra(땅) + ify, Terraform 연상
```

### 시리즈 일관성

```
/namify:name "코드를 작성하는 AI 도구" --series "Gemify"

→ 패턴 인식: -ify (변환)
→ 핵심 가치: 제작, 개발
→ 후보: Craftify, Codeify, Buildify, Devify
→ 추천:
  1. Craftify - 장인정신 + ify, 시리즈 일관성
```

## 안티패턴 (피해야 할 것)

| 피해야 할 것 | 이유 |
|-------------|------|
| 메타포 혼재 | 이미지 혼란 (Capture + Cultivate) |
| 설명이 필요한 이름 | 첫인상 실패 |
| 기존 유명 제품과 유사 | 검색 어려움, 법적 이슈 |
| 문화적 맹점 | 특정 문화권에서 부정적 의미 |
