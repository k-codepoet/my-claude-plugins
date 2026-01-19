# Error Handling

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

## 필수 정보 누락

```
플러그인 생성에 필요한 정보가 누락되었습니다:
- [ ] 플러그인명
- [ ] 설명
- [ ] 작성자

누락된 정보를 입력해주세요.
```

## validate 실패

```
플러그인 검증에 실패했습니다:
{error-details}

자동 수정을 시도합니다...
```

## 컴포넌트 생성 실패

```
'{component-type}' 컴포넌트 생성에 실패했습니다:
{error-details}

해당 컴포넌트를 건너뛰고 계속할까요? [Y/n]
```

## 마켓플레이스 등록 실패

```
marketplace.json 업데이트에 실패했습니다:
{error-details}

수동으로 다음 내용을 추가해주세요:
{
  "name": "{name}",
  "source": "./plugins/{name}",
  "description": "{description}"
}
```
