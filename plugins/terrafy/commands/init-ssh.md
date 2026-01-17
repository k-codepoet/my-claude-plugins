---
description: SSH 서버를 설정합니다 (클러스터 참여 준비)
allowed-tools: ["Bash", "Read"]
---

# /terrafy:init-ssh

이 머신의 SSH 서버를 설정하여 클러스터에 참여할 수 있게 합니다.

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/init-ssh/SKILL.md
```

스킬의 OS별 설정 방법을 따라 진행하세요.

## 언제 사용하나요?

`/terrafy:setup`에서 노드 추가 시 SSH 연결이 실패하면:

```
[!] 192.168.0.14 연결 실패: Connection refused

→ 해당 머신에서 /terrafy:init-ssh 실행 필요
```

## 사용법

```
/terrafy:init-ssh    # 이 머신에서 SSH 서버 설정
```

## 다음 단계

설정 완료 후 마스터 머신으로 돌아가서:
- `/terrafy:setup` - 노드 추가 재시도
