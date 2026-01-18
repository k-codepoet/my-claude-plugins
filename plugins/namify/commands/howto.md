---
description: Namify 사용 가이드. 인자 없이 실행하면 가능한 주제 목록을, 주제를 지정하면 해당 가이드를 표시합니다.
argument-hint: "[topic]"
---

# /namify:howto 명령어

사용자가 요청한 주제에 대한 Namify 사용 가이드를 제공합니다.

## 사용법

- `/namify:howto` - 가능한 주제 목록 표시
- `/namify:howto <topic>` - 특정 주제 가이드 표시

## 가능한 주제 (Topics)

### 네이밍
| 주제 | 설명 | 예시 |
|------|------|------|
| `name` | 기본 네이밍 | `/namify:name "생각을 정제해서 지식으로 만드는 도구"` |
| `pattern` | 패턴 지정 네이밍 | `/namify:name "인프라 자동화 도구" --pattern "-ify"` |
| `series` | 시리즈 일관성 네이밍 | `/namify:name "코드 AI 도구" --series "Gemify"` |
| `naming-guide` | 네이밍 가이드라인 | `/namify:howto naming-guide` |

## 동작

1. **인자가 없는 경우**: 위 주제 목록을 사용자에게 보여주세요.

2. **인자가 있는 경우**: 해당 주제의 스킬을 로드하여 안내합니다.
   - `name`, `pattern`, `series` → name 커맨드 사용
   - `naming-guide` → naming-guide 스킬

3. **알 수 없는 주제**: 가능한 주제 목록을 보여주고 올바른 주제를 선택하도록 안내합니다.

## 메타포 종류

| 메타포 | 적합한 경우 | 예시 |
|--------|-------------|------|
| 광물/보석 | 정제, 가치 상승 | Gem, Crystal, Diamond |
| 식물 | 성장, 육성 | Seed, Bloom, Garden |
| 건축 | 구축, 기반 | Foundation, Scaffold, Tower |
| 도구 | 제작, 장인정신 | Craft, Forge, Workshop |
| 과학 | 실험, 연구 | Lab, Studio, Reactor |

## 패턴 종류

| 패턴 | 의미 | 예시 |
|------|------|------|
| `-ify` | 변환/생성 | Shopify, Spotify, Gemify |
| `Craft` | 장인정신 | Minecraft, Warcraft |
| `Lab` | 실험/연구 | GitLab, Hashlab |
| `Hub` | 중심/연결 | GitHub, DockerHub |
| 단일어 | 강렬함 | Notion, Slack, Figma |

## 검증 체크리스트

| 항목 | 체크 |
|------|------|
| 발음 | 쉽게 발음되는가? |
| 기존 의미 | 부정적 의미, 슬랭 아닌가? |
| 검색 가능성 | 기존 유명 제품과 혼동 없는가? |
| 문화적 적합성 | 타겟 문화권에서 자연스러운가? |
