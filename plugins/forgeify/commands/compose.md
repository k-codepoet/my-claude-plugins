---
description: 여러 플러그인을 분석하여 필요한 부분만 추출하고 새로운 플러그인으로 조립합니다.
argument-hint: "<topic> <plugin1> [plugin2] [plugin3] ..."
---

# /forgeify:compose

compose 스킬을 사용하여 여러 플러그인을 조립합니다.

## 사용법

```
/forgeify:compose <topic> <plugin1> [plugin2] [plugin3] ...
```

- `<topic>`: 새로 만들 플러그인 주제/이름
- `<plugin1,2,3...>`: 소스로 사용할 플러그인 경로들

## 예시

```
/forgeify:compose my-devops ./plugins/homeserver-gitops ./plugins/ubuntu-dev-setup
```
