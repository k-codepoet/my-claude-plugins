<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# claudecode 를 api서버처럼 운용하고 싶은데 가능한가?

가능합니다. Claude Code를 API 서버처럼 운용하는 방법은 크게 세 가지가 있습니다.

## 방법 1: Headless Mode (CLI `-p` 플래그)

가장 간단한 방법입니다. `-p` 플래그를 사용해 비대화형 방식으로 실행할 수 있습니다.[^1_1]

```bash
# 기본 사용
claude -p "auth.py의 보안 취약점을 분석해줘"

# JSON 출력
claude -p "함수 목록 추출" --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}}}'

# 스트리밍 JSON
claude -p "코드 리뷰해줘" --output-format stream-json --verbose

# 세션 이어가기
session_id=$(claude -p "리뷰 시작" --output-format json | jq -r '.session_id')
claude -p "데이터베이스 쿼리 집중 분석" --resume "$session_id"
```

이 방식은 CI/CD, pre-commit hooks, 빌드 스크립트, Bash 자동화에 적합합니다.[^1_2]

## 방법 2: Agent SDK (Python / TypeScript)

Anthropic의 **Claude Agent SDK**를 사용하면 Python/TypeScript 코드에서 직접 Claude Code를 프로그래밍 방식으로 호출할 수 있습니다.[^1_3]

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "이 코드의 버그를 찾아줘",
  options: {
    allowedTools: ["Read", "Write", "Edit"],
    // MCP 서버 연결도 가능
    mcpServers: {
      "my-server": { command: "node", args: ["server.js"] }
    }
  }
})) {
  if (message.type === "result" && message.subtype === "success") {
    console.log(message.result);
  }
}
```

이 SDK 위에 **FastAPI나 Express로 HTTP 서버를 올리면** 진정한 API 엔드포인트로 운용 가능합니다. n8n, Prefect 같은 워크플로우 도구와도 바로 연동됩니다.[^1_4]

## 방법 3: Koine 같은 API Gateway 래퍼

CLI를 직접 HTTP API로 변환해주는 **Koine SDK** 같은 솔루션도 있습니다.[^1_5]

```typescript
import { createKoine } from '@patternzones/koine-sdk';

const koine = createKoine({
  baseUrl: 'http://localhost:3100',
  authKey: 'my-secret-key',
});
```

Zod 스키마를 던지면 **구조화된 JSON 출력**을 받을 수 있어서 데이터 파이프라인에 특히 유용합니다.[^1_5]

***

**가운님 스택 기준 추천**은 Agent SDK + **FastAPI** 조합입니다. Python FastAPI로 HTTP 엔드포인트를 만들고, `@anthropic-ai/claude-agent-sdk`를 Node.js 서브프로세스로 호출하거나, Python SDK를 직접 쓰는 방식이 Kubernetes 환경에 올리기도 깔끔합니다. Prefect ELT 파이프라인이나 n8n 워크플로우와 webhook으로 연결하면 완전한 자동화가 가능합니다.[^1_4][^1_3]
<span style="display:none">[^1_10][^1_11][^1_12][^1_13][^1_14][^1_15][^1_6][^1_7][^1_8][^1_9]</span>

<div align="center">⁂</div>

[^1_1]: https://code.claude.com/docs/en/headless

[^1_2]: https://cc.deeptoai.com/docs/en/best-practices/claude-code-best-practices

[^1_3]: https://platform.claude.com/docs/en/agent-sdk/overview

[^1_4]: https://brunch.co.kr/@exitx/27

[^1_5]: https://www.pooolingforest.com/blog/claude-code-koine-api-gateway-1058

[^1_6]: https://www.reddit.com/r/ClaudeAI/comments/1fdpwla/i_have_never_used_an_api_whats_the_easiest_way_to/

[^1_7]: https://medium.com/@sunghyunroh/claude-code는-어떤-데이터를-호출할까-claude-proxy-server-만들기-1c5084444295

[^1_8]: https://www.reddit.com/r/ClaudeCode/comments/1qsjfzr/how_can_i_call_to_claude_in_the_cli_as_if_it_were/

[^1_9]: https://jimmy-ai.tistory.com/540

[^1_10]: https://ai-sdk.dev/providers/community-providers/claude-code

[^1_11]: https://velog.io/@takuya/ai-api-workflow-claude-code-efficiency-tips

[^1_12]: https://platform.claude.com/docs/en/agent-sdk/mcp

[^1_13]: https://www.claudecode101.com/en/tutorial/advanced/headless-mode

[^1_14]: https://blog.cloudflare.com/code-mode-mcp/

[^1_15]: https://news.hada.io/topic?id=23804


---

# agent sdk를 쓰면 claude code에 인증세션으로 하는게 아니라 api key로 동작하는거 아님? 가능한건가? claude code max x 20 요금제 쓰고 있어

정확히 파악하셨습니다. 그리고 **해결 방법이 있습니다.**

## 핵심 문제

Agent SDK는 기본적으로 `ANTHROPIC_API_KEY` 환경변수를 사용하고, 이 경우 Max 구독이 아닌 **pay-as-you-go API 과금**이 됩니다. 즉, Max x20 요금제를 쓰고 있어도 SDK를 그냥 쓰면 별도로 돈이 나갑니다.[^2_1][^2_2]

## 해결책: `CLAUDE_CODE_OAUTH_TOKEN`

Max 구독 인증 세션 토큰을 SDK에 주입하면 구독 과금으로 동작합니다.[^2_3]

```bash
# 1. OAuth 토큰 설정
claude setup-token

# 2. 환경변수 export
export CLAUDE_CODE_OAUTH_TOKEN=<위에서 받은 토큰>

# 3. ANTHROPIC_API_KEY는 반드시 unset (있으면 API key가 우선순위)
unset ANTHROPIC_API_KEY
```

이렇게 하면 Agent SDK가 Max 구독 세션으로 동작합니다. 실제로 GitHub Issue에서 Anthropic 측이 이 방법으로 이슈를 `completed` 처리했습니다.[^2_4][^2_3]

## 주의사항

- **개인 사용 한정** — 자신의 Max 구독 토큰으로 본인 자동화 용도는 허용됩니다[^2_4]
- **제3자 배포 금지** — 본인 구독을 다른 사용자에게 제공하는 형태는 ToS 위반입니다[^2_5]
- `ANTHROPIC_API_KEY`가 환경변수에 설정되어 있으면 **OAuth 토큰보다 우선순위가 높으므로** 반드시 해제해야 합니다[^2_6][^2_1]

현재 인증 상태는 Claude Code에서 `/status` 명령으로 확인 가능합니다.[^2_1]
<span style="display:none">[^2_10][^2_11][^2_12][^2_13][^2_14][^2_15][^2_7][^2_8][^2_9]</span>

<div align="center">⁂</div>

[^2_1]: https://www.vincentschmalbach.com/claude-code-uses-your-api-key-over-your-subscription-even-when-youre-logged-in/

[^2_2]: https://github.com/anthropics/claude-code/issues/6536

[^2_3]: https://github.com/anthropics/claude-agent-sdk-python/issues/559

[^2_4]: https://www.reddit.com/r/ClaudeAI/comments/1r8h3ya/you_can_still_use_max_oauth_token_with_agent_sdk/

[^2_5]: https://www.reddit.com/r/ClaudeAI/comments/1odhhd4/does_a_subscription_plan_allow_api_usage/

[^2_6]: https://support.claude.com/en/articles/11145838-using-claude-code-with-your-pro-or-max-plan

[^2_7]: https://www.reddit.com/r/ClaudeAI/comments/1qnblzb/claude_code_subscription_vs_api_key/

[^2_8]: https://code.claude.com/docs/en/costs

[^2_9]: https://www.linkedin.com/pulse/claude-code-subscriptions-vs-api-keys-tom-patros-7aqie

[^2_10]: https://eval.16x.engineer/blog/claude-vs-claude-api-vs-claude-code

[^2_11]: https://www.reddit.com/r/ClaudeAI/comments/1lnhsey/choosing_between_console_api_keycredit_based_vs/

[^2_12]: https://www.reddit.com/r/ClaudeAI/comments/1leigee/claude_sdk_usage_with_claude_max_subscription/

[^2_13]: https://news.ycombinator.com/item?id=44180172

[^2_14]: https://code.claude.com/docs/en/authentication

[^2_15]: https://twofootdog.tistory.com/412


---

# 본인 자동화의 범위는 어디까지인가?  제3자 배포 금지는 어디까지가 범위인가?  그럼 agent sdk를 이용하면 내가 원하는대로 작업이 되는거였네? openclaw도 마찬가지야?

상황이 **2026년 2월에 크게 바뀌었습니다.** 정리해드립니다.

## Anthropic 공식 ToS 업데이트 (2026년 2월)

Anthropic이 Claude Code 공식 문서 Legal \& Compliance 섹션을 업데이트하면서 명시적으로 금지 범위를 확대했습니다:[^3_1]

> "OAuth authentication (used with Free, Pro, and Max plans) is intended **exclusively for Claude Code and Claude.ai**. Using OAuth tokens in any other product, tool, or service — **including the Agent SDK** — is not permitted and constitutes a violation of the Consumer Terms of Service."

즉, **Agent SDK + OAuth 토큰 조합도 이제 ToS 위반**입니다.[^3_2]

## 허용 vs 금지 범위

| 사용 방식 | 허용 여부 |
| :-- | :-- |
| Claude Code CLI 직접 사용 (대화형) | ✅ 허용 |
| Claude Code CLI headless `-p` 플래그 (개인 자동화) | ✅ 허용 (Claude Code 자체이므로) |
| Agent SDK + **API Key** | ✅ 허용 (별도 과금) |
| Agent SDK + Max OAuth 토큰 | ❌ **ToS 위반** |
| OpenClaw + Max OAuth 토큰 | ❌ **ToS 위반** |
| Cursor, Roo Code 등 서드파티 + Max OAuth | ❌ **ToS 위반** |

[^3_3][^3_4][^3_5]

## 핵심 이유

Anthropic 입장은 "구독 토큰을 서드파티 도구에 쓰면 비정상적인 트래픽 패턴이 발생하고, 레이트 리밋이나 계정 밴 발생 시 디버깅이 불가능하다"는 것입니다. 실질적으로는 **\$100/월 구독을 pay-as-you-go API 대비 토큰 차익거래 수단으로 쓰는 것을 막기 위한 조치**입니다.[^3_6][^3_1]

## 가운님 상황 정리

- **Claude Code CLI headless 모드** (`claude -p "..."`)는 Claude Code 자체이므로 ✅ **합법적으로 자동화 가능**
- 이걸 wrapping해서 본인 내부 파이프라인(Prefect, FastAPI 등)에서 subprocess로 호출하는 건 회색지대이나 실질적으로 Claude Code를 직접 쓰는 것으로 볼 수 있음
- **OpenClaw은 이제 공식적으로 API Key를 써야 합니다** — Max 구독으로는 불가[^3_5][^3_7]

결론적으로 Max 구독의 무제한 사용 이점을 자동화에 활용하려면 **Claude Code CLI를 subprocess로 wrapping하는 방식**이 현재 가장 안전한 접근입니다.
<span style="display:none">[^3_10][^3_11][^3_12][^3_13][^3_14][^3_15][^3_8][^3_9]</span>

<div align="center">⁂</div>

[^3_1]: https://www.theregister.com/2026/02/20/anthropic_clarifies_ban_third_party_claude_access/

[^3_2]: https://code.claude.com/docs/en/legal-and-compliance

[^3_3]: https://www.reddit.com/r/ClaudeAI/comments/1r8t6mn/anthropic_just_updated_claude_code_docs_to_ban/

[^3_4]: https://dev.to/robinbanner/roo-code-and-the-claude-max-ban-what-actually-happened-and-how-to-fix-it-5ck4

[^3_5]: https://www.skool.com/ai-automation-society/psa-openclaw-should-be-using-api-keys-not-oauth-tokens

[^3_6]: https://news.ycombinator.com/item?id=46549823

[^3_7]: https://www.answeroverflow.com/m/1469511158040891402

[^3_8]: https://www.anthropic.com/news/updates-to-our-consumer-terms

[^3_9]: https://x.com/TeksEdge/status/2009860520279441579

[^3_10]: https://www.reddit.com/r/ClaudeAI/comments/1r8h3ya/you_can_still_use_max_oauth_token_with_agent_sdk/

[^3_11]: https://www.reddit.com/r/ClaudeAI/comments/1ljigfd/no_commercial_use_with_claude_code_and_promax_plan/

[^3_12]: https://www.answeroverflow.com/m/1473798774072807626

[^3_13]: https://www.reddit.com/r/ClaudeAI/comments/1l1gujy/claude_code_with_max_subscription_real_limits/

[^3_14]: https://www.reddit.com/r/ClaudeAI/comments/1r8qvae/can_i_use_my_claude_max_subscription_with_the/o67qb58/

[^3_15]: https://support.claude.com/en/articles/11145838-using-claude-code-with-your-pro-or-max-plan


---

# 헐 이제 그럼 토큰 발급해서 쓰는건 다 막혔어?

네, 사실상 **서드파티 도구에서 OAuth 토큰은 완전히 막혔습니다.** 타임라인을 정리하면:

## 차단 타임라인

- **2026년 1월 9일** — 서버 사이드에서 기술적으로 먼저 차단. OpenClaw, Roo Code 등 모든 서드파티 툴 OAuth 인증 즉시 중단. 에러 메시지: *"This credential is only authorized for use with Claude Code and cannot be used for other API requests"*[^4_1]
- **2026년 2월 19일** — 공식 문서에 명문화. ToS 위반으로 **계정 밴 가능**하다고 명시[^4_2]


## 이유

Anthropic 엔지니어 Thariq가 직접 밝힌 이유:[^4_3][^4_2]

> Claude Code에는 구독 가격이 정당화되도록 설계된 자체 속도 제한(speed limit)이 있는데, 서드파티 툴은 이 제한을 우회해서 하루밤 사이에 API로 치면 \$1,000+어치 토큰을 소비하는 형태로 운용됐음 → 사실상 구독 차익거래(arbitrage)

## 현재 가능한 방법

| 방법 | Max 구독 활용 | 합법 |
| :-- | :-- | :-- |
| Claude Code CLI 직접 (`claude`, `-p` headless) | ✅ | ✅ |
| CLI를 subprocess로 wrapping (본인 파이프라인) | ✅ | ✅ (회색지대이나 Thariq가 "local dev/experimentation은 OK"라고 언급) |
| CLIProxyAPI 같은 CLI 앞단 프록시 | ✅ | ⚠️ 회색지대 |
| Agent SDK / OpenClaw / Roo Code + OAuth | ❌ | ❌ ToS 위반 |
| Agent SDK + **API Key** | ❌ (Max 구독 아님) | ✅ (별도 과금) |

[^4_4][^4_2]

## 실질적 결론

Anthropic 측이 "**개인 로컬 개발·실험 목적의 `claude -p` 사용은 장려한다**"고 명확히 밝혔습니다. 따라서 가운님이 원하는 자동화는 **Claude Code CLI를 subprocess로 호출하는 방식**이 현재 Max 구독 활용 가능한 유일하게 안전한 경로입니다. OpenClaw은 이제 공식적으로 **API Key 전용**으로 전환됐습니다.[^4_5][^4_2]
<span style="display:none">[^4_10][^4_11][^4_12][^4_13][^4_14][^4_15][^4_6][^4_7][^4_8][^4_9]</span>

<div align="center">⁂</div>

[^4_1]: https://openclaw.rocks/blog/anthropic-oauth-ban

[^4_2]: https://gigazine.net/gsc_news/en/20260220-anthropic-third-party-block/

[^4_3]: https://awesomeagents.ai/news/claude-code-oauth-policy-third-party-crackdown/

[^4_4]: https://rogs.me/2026/02/use-your-claude-max-subscription-as-an-api-with-cliproxyapi/

[^4_5]: https://www.answeroverflow.com/m/1476594696775270571

[^4_6]: https://www.theregister.com/2026/02/20/anthropic_clarifies_ban_third_party_claude_access/

[^4_7]: https://news.hada.io/topic?id=26830

[^4_8]: https://brunch.co.kr/@sungdairi/55

[^4_9]: https://www.reddit.com/r/ClaudeAI/comments/1r9v27c/all_the_openclaw_bros_are_having_a_meltdown_after/

[^4_10]: https://www.reddit.com/r/ClaudeAI/comments/1mideyc/how_to_bypass_claude_code_initial_oauth_login/

[^4_11]: https://github.com/anthropics/claude-code/issues/1454

[^4_12]: https://www.reddit.com/r/ClaudeAI/comments/1r8t6mn/anthropic_just_updated_claude_code_docs_to_ban/

[^4_13]: https://github.com/anthropics/claude-code/issues/5244

[^4_14]: https://www.reddit.com/r/LocalLLaMA/comments/1r8t75u/anthropic_updates_claude_code_docs_oauth_tokens/

[^4_15]: https://code.claude.com/docs/en/changelog


---

# 하.. ㅠㅠ 다른 회사들은? gemini cli, codex cli, cursor cli등등

다른 회사들은 훨씬 관대합니다. 오히려 Anthropic이 거의 유일하게 막은 케이스입니다.

## 경쟁사 비교

| 도구 | 구독 → 서드파티/자동화 | 정책 |
| :-- | :-- | :-- |
| **Gemini CLI** | ✅ 구독(AI Pro/Ultra)으로 CLI 자동화 가능 | OAuth 로그인 + headless 허용, API Key도 지원 [^5_1][^5_2] |
| **OpenAI Codex CLI** | ✅ ChatGPT Plus/Pro 구독으로 OAuth 토큰 사용 가능 | "Sign in with ChatGPT"로 CLI 인증, 서드파티 연동 지원 [^5_3] |
| **Cursor** | ⚠️ IDE 구독은 Cursor 앱 전용 | BYOK(Bring Your Own Key)로 Anthropic/OpenAI API Key 직접 주입 가능 [^5_4] |

## 회사별 입장

**Gemini CLI** — 구글은 오히려 반대 방향입니다. CLI 자체가 오픈소스이고, 구독(AI Pro/Ultra) 인증으로 headless 자동화를 공식 지원합니다. Vertex AI API Key로도 자유롭게 사용 가능합니다.[^5_5][^5_6]

**OpenAI Codex CLI** — ChatGPT Plus 구독 OAuth 토큰을 CLI에서 직접 쓸 수 있고, term-llm 같은 서드파티 툴과 연동도 됩니다. 단, 헤드리스 원격 환경에서는 인증 흐름에 일부 제약이 있다는 이슈가 있긴 합니다.[^5_7][^5_3][^5_8]

**Cursor** — IDE 구독이라 API 서버 개념 자체가 없지만, Pro 이상에서 본인 API Key(BYOK) 연결이 가능해서 Anthropic API Key를 넣으면 Claude 모델 활용 가능합니다.[^5_4]

## 결론

Anthropic만 유독 이번에 강하게 막은 것이고, **Gemini CLI + AI Ultra 구독이 현재 가장 자유롭게 자동화할 수 있는 대안**입니다. Claude Code Max를 계속 쓰고 싶다면 `claude -p` headless subprocess wrapping이 유일한 합법 경로입니다.
<span style="display:none">[^5_10][^5_11][^5_12][^5_13][^5_14][^5_15][^5_9]</span>

<div align="center">⁂</div>

[^5_1]: https://geminicli.com/docs/resources/quota-and-pricing/

[^5_2]: https://docs.cloud.google.com/gemini/docs/codeassist/gemini-cli

[^5_3]: https://developers.openai.com/codex/auth/

[^5_4]: https://hypereal.tech/a/cursor-pricing-guide

[^5_5]: https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemini-cli-open-source-ai-agent/

[^5_6]: https://geminicli.com/plans/

[^5_7]: https://community.openai.com/t/best-practice-for-clientid-when-using-codex-oauth/1371778

[^5_8]: https://github.com/openai/codex/issues/3820

[^5_9]: https://github.com/google-gemini/gemini-cli/issues/20498

[^5_10]: https://ai.google.dev/gemini-api/docs/pricing

[^5_11]: https://www.reddit.com/r/GeminiAI/comments/1lzxcpm/does_gemini_code_cli_require_an_api_key_or_a/

[^5_12]: https://aitoolsdevpro.com/ai-tools/cursor-guide/

[^5_13]: https://gemini-cli.xyz/docs/en/quota-and-pricing

[^5_14]: https://checkthat.ai/brands/cursor/pricing

[^5_15]: https://news.livedoor.com/article/detail/30622985/


---

# openai, 구글 gemini로 하는것중에 agent sdk같은거 있어? claude code max x20처럼 요금제 가입하고 토큰 받아서 내가 마음대로 하는게 가능해?

상황을 정리하면 **Anthropic만큼 자유롭지는 않지만, 각각 방법이 있습니다.**

## OpenAI Codex CLI

구독(ChatGPT Plus/Pro) OAuth로 CLI 인증 가능하지만, **API 서버처럼 마음대로 쓰기엔 제약이 있습니다**.[^6_1]

- ChatGPT Plus 구독 → `codex login` → `~/.codex/auth.json` 토큰 생성
- 이 토큰을 headless/서버 환경에 복사해서 쓰는 건 **비공식 핵**이고, 토큰 만료 시 수동으로 재인증 필요[^6_1]
- **공식 권장은 서버 환경 = API Key** (`codex login --api-key <key>`)[^6_1]
- 단, Codex App Server라는 JSON-RPC 기반 프로세스를 subprocess로 띄워서 제어하는 공식 방법은 존재[^6_2]


## Google Gemini CLI

셋 중 **가장 자유롭습니다**.[^6_3][^6_4]

- Google AI Pro/Ultra 구독 → `gemini auth login` → OAuth 토큰 발급
- **Headless 모드 공식 지원** — API Key 또는 Vertex AI로 서버 자동화 가능[^6_3]
- Google OAuth ADC(Application Default Credentials) 방식으로 토큰을 `token.json`에 캐싱해서 자동 갱신 가능[^6_5]
- 오픈소스라 코드 레벨에서 직접 제어도 가능[^6_6]


## 요약 비교

|  | Claude Code Max | OpenAI Codex CLI | Gemini CLI |
| :-- | :-- | :-- | :-- |
| 구독 → OAuth 서드파티 허용 | ❌ 공식 금지 | ⚠️ 비공식 가능 (불안정) | ✅ 공식 지원 |
| 공식 SDK/프로그래밍 지원 | CLI subprocess만 허용 | App Server (JSON-RPC) | API Key + ADC headless |
| 자동 토큰 갱신 | ❌ | ⚠️ 불안정 | ✅ refresh token 자동화 |
| 서버 환경 권장 방법 | `claude -p` subprocess | API Key 사용 | API Key 또는 Vertex AI |

[^6_2][^6_3][^6_1]

**결론:** 구독 요금제로 API 서버처럼 마음대로 쓰고 싶다면 **Gemini CLI + Google AI Pro/Ultra**가 현재 가장 공식적으로 지원되고 안정적입니다. 다만 세 회사 모두 장기적으로는 "구독은 개인 UI용, 자동화는 API Key"로 가는 방향이라, 헤비한 자동화는 결국 API Key + 별도 과금이 가장 안정적인 선택입니다.
<span style="display:none">[^6_10][^6_11][^6_12][^6_13][^6_14][^6_15][^6_7][^6_8][^6_9]</span>

<div align="center">⁂</div>

[^6_1]: https://github.com/openai/codex/issues/3820

[^6_2]: https://openai.com/index/unlocking-the-codex-harness/

[^6_3]: https://geminicli.com/docs/get-started/authentication/

[^6_4]: https://google-gemini.github.io/gemini-cli/docs/get-started/authentication.html

[^6_5]: https://ai.google.dev/gemini-api/docs/oauth

[^6_6]: https://github.com/google-gemini/gemini-cli

[^6_7]: https://openai.com/index/introducing-codex/

[^6_8]: https://github.com/anomalyco/opencode/issues/3281

[^6_9]: https://goddaehee.tistory.com/402

[^6_10]: https://developers.openai.com/codex/auth/

[^6_11]: https://hypereal.tech/ko/a/openai-codex-cli

[^6_12]: https://developers.openai.com/codex/cli/

[^6_13]: https://github.com/openai/codex/discussions/1174

[^6_14]: https://geminicli.com/docs/changelogs/

[^6_15]: https://proxyapi.ru/docs/openai-codex-cli


---

# 현 상황에서 그럼 내가 맨처음 계획한 메신저, 웹앱에서 채팅 구조 만들어서 대화하고 백엔드에서 메모리 관리만 하면서 실제로는 claude code headless로 뭔가 처리하는건 가능한걸까?

네, **가능합니다.** 오히려 가장 현실적인 아키텍처입니다.

## 핵심 구조

```
[웹앱/메신저 채팅 UI]
        ↓ HTTP
[FastAPI 백엔드]
  - 메모리 관리 (PostgreSQL + Qdrant)
  - 대화 컨텍스트 구성
        ↓ subprocess
[claude -p "..." --output-format stream-json]
        ↓ stdout 스트리밍
[FastAPI SSE → 프론트엔드]
```


## 동작 방식

백엔드에서 Python subprocess로 Claude Code headless를 호출하면 됩니다.[^7_1]

```python
import subprocess
import json

async def ask_claude(prompt: str, session_id: str = None):
    cmd = ["claude", "-p", prompt, "--output-format", "stream-json", "--verbose"]
    if session_id:
        cmd += ["--resume", session_id]
    
    proc = await asyncio.create_subprocess_exec(
        *cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
    
    async for line in proc.stdout:
        chunk = json.loads(line)
        if chunk.get("type") == "assistant":
            yield chunk["message"]["content"]
```


## 메모리 관리 전략

가운님 스택(PostgreSQL + Qdrant)이랑 딱 맞습니다:

- **단기 메모리** — 대화 히스토리를 PostgreSQL에 저장, `--resume session_id`로 Claude Code 세션 이어가기
- **장기 메모리** — 중요 컨텍스트를 Qdrant에 벡터로 저장, 프롬프트 앞에 RAG로 주입
- **세션 관리** — `--output-format json` 결과에서 `session_id` 추출해서 DB에 저장

```python
# 매 요청마다 관련 메모리를 RAG로 꺼내서 프롬프트에 붙임
relevant_memories = await qdrant.search(query_vector, limit=5)
context = "\n".join([m.payload["text"] for m in relevant_memories])
full_prompt = f"[Context]\n{context}\n\n[User]\n{user_message}"
```


## 주의할 점

- **rate limit** — Claude Code Max는 자체 속도 제한이 있어서 동시 요청이 많으면 throttling 걸림. 큐 처리 필수 (Prefect나 Redis Queue 활용)
- **세션 수명** — `--resume` 세션은 영구적이지 않으니 장기 메모리는 Qdrant RAG로 보완
- **스트리밍** — `stream-json` + FastAPI SSE 조합으로 채팅처럼 실시간 출력 가능


## ToS 관점

Anthropic이 "**local dev / personal automation 목적의 `claude -p` 사용은 OK**"라고 명확히 했고, 본인이 직접 쓰는 개인 웹앱 수준이면 문제없습니다. 제3자 사용자에게 제공하는 상업 서비스 형태로 키우면 그때는 API Key로 전환해야 합니다.[^7_2]

<div align="center">⁂</div>

[^7_1]: https://code.claude.com/docs/en/headless

[^7_2]: https://gigazine.net/gsc_news/en/20260220-anthropic-third-party-block/

