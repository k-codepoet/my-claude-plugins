---
name: marketplace-guide
description: Claude Code 마켓플레이스 구축 가이드. 마켓플레이스 만들기, marketplace.json 작성, 플러그인 배포에 대해 질문할 때 사용합니다.
---

# Marketplace (마켓플레이스) 가이드

## 개념

**플러그인 카탈로그를 관리하는 저장소**입니다. GitHub에 `.claude-plugin/marketplace.json` 파일이 있으면 **24시간 내 자동 등록**됩니다.

## 필수 구조

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json   # 필수 위치
└── plugins/
    ├── plugin-1/
    │   ├── .claude-plugin/
    │   │   └── plugin.json
    │   └── ...
    └── plugin-2/
        └── ...
```

## marketplace.json 작성법

```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "author-name"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./plugins/my-plugin",
      "description": "Plugin description"
    },
    {
      "name": "another-plugin",
      "source": "./plugins/another-plugin",
      "description": "Another plugin"
    }
  ]
}
```

## 필수 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 마켓플레이스 이름 (kebab-case, 공백 불가) |
| `owner.name` | string | 소유자 이름 |
| `plugins[].name` | string | 플러그인 이름 |
| `plugins[].source` | string | 플러그인 경로 (상대 경로) |
| `plugins[].description` | string | 플러그인 설명 |

## 마켓플레이스 전용 필드

plugin manifest 필드 외에 마켓플레이스에서만 사용하는 필드:

| 필드 | 타입 | 설명 |
|------|------|------|
| `source` | string | 플러그인 소스 경로 (필수) |
| `category` | string | 플러그인 카테고리 |
| `tags` | string[] | 검색용 태그 |
| `strict` | boolean | `false`면 자체 plugin.json 불필요 (marketplace가 정의) |

## 고급 옵션

```json
{
  "name": "advanced-marketplace",
  "owner": { "name": "author" },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./",
      "description": "Plugin with custom paths",
      "commands": ["./plugins/my-plugin/commands/"],
      "agents": ["./plugins/my-plugin/agents/"],
      "strict": false
    }
  ]
}
```

## 마켓플레이스 추가 및 사용

```bash
# GitHub에서 추가
/plugin marketplace add owner/repo
/plugin marketplace add anthropics/skills

# GitLab에서 추가
/plugin marketplace add https://gitlab.com/company/plugins.git

# 로컬 디렉토리에서 추가
/plugin marketplace add ./my-marketplace

# 마켓플레이스 목록 확인
/plugin marketplace list

# 특정 마켓플레이스에서 플러그인 설치
/plugin install plugin-name@marketplace-name

# 마켓플레이스 업데이트
/plugin marketplace update my-marketplace

# 플러그인 탐색
# Claude Code UI에서 "Browse and install plugins" 선택
```

## 팀 설정 (extraKnownMarketplaces)

프로젝트의 `.claude/settings.json`에 추가하면 팀원이 폴더 신뢰 시 자동으로 마켓플레이스 설치 프롬프트:

```json
{
  "extraKnownMarketplaces": [
    "owner/repo"
  ]
}
```
