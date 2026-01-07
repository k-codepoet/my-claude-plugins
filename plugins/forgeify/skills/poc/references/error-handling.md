# Error Handling

## POC.md 없음

```
POC.md가 없습니다.

gemify:poc으로 먼저 POC.md를 생성하세요:
/gemify:poc "플러그인 아이디어"
```

## POC.md 필수 섹션 누락

```
POC.md에 필수 섹션이 누락되었습니다:
- [ ] Why
- [ ] Hypothesis
- [ ] What
- [ ] Acceptance Criteria

gemify:poc으로 다시 생성하거나 수동으로 추가하세요.
```

## 마켓플레이스 경로 오류

```
지정된 경로가 마켓플레이스가 아닙니다.

마켓플레이스 구조:
{path}/
├── .claude-plugin/
│   └── marketplace.json
└── plugins/

올바른 마켓플레이스 경로를 입력하세요.
```

## 플러그인명 중복

```
'{plugin-name}' 플러그인이 이미 존재합니다:
{existing-path}

다른 이름을 사용하거나 기존 플러그인을 수정하세요.
```

## validate 실패

```
플러그인 검증에 실패했습니다:
{error-details}

자동 수정을 시도합니다...
```
