---
name: init-ssh
description: SSH 서버를 설정하여 클러스터 참여 준비. "SSH 설정", "연결 안됨", "init-ssh" 등 요청 시 활성화. 클러스터 노드 추가 실패 시 fallback.
allowed-tools: Bash, Read
---

# Init-SSH Skill

이 머신의 SSH 서버를 설정하여 **클러스터에 참여**할 수 있게 합니다.

## 언제 사용하나요?

`/terrafy:setup`에서 다른 머신을 추가할 때 SSH 연결이 실패하면:

```
[!] 192.168.0.14 연결 실패: Connection refused

→ 해당 머신에서 /terrafy:init-ssh 실행 필요
```

이때 해당 머신(192.168.0.14)에 **직접 가서** 이 커맨드를 실행합니다.

## 플로우

```
[마스터] /terrafy:setup
    ↓
"192.168.0.14 연결 실패"
    ↓
[192.168.0.14로 이동] /terrafy:init-ssh
    ↓
SSH 서버 설치/활성화
    ↓
[마스터로 돌아가기] /terrafy:setup
    ↓
"192.168.0.14 추가 재시도"
```

## 실행 내용

### 1. OS 감지

```bash
# OS 타입 확인
uname -s  # Linux, Darwin
```

### 2. SSH 서버 설치/활성화

#### Linux (Debian/Ubuntu)

```bash
if ! command -v sshd &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y openssh-server
fi

sudo systemctl enable ssh
sudo systemctl start ssh
```

#### Linux (RHEL/CentOS/Fedora)

```bash
if ! command -v sshd &>/dev/null; then
    sudo yum install -y openssh-server
fi

sudo systemctl enable sshd
sudo systemctl start sshd
```

#### macOS

```bash
# macOS는 기본 설치됨, 활성화만
sudo systemsetup -setremotelogin on
```

### 3. 방화벽 확인

#### ufw (Ubuntu)

```bash
sudo ufw allow ssh
```

#### firewalld (CentOS/RHEL)

```bash
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
```

### 4. 연결 테스트 정보 출력

```
=== SSH 준비 완료 ===

이 머신 IP: 192.168.0.14
SSH 포트: 22
사용자: admin

마스터 머신에서 다시 연결을 시도하세요:
→ /terrafy:setup
```

## 특수 케이스

### Synology NAS (DSM)

Synology NAS는 CLI 설치가 불가능합니다. 웹 UI로 안내:

```
Synology NAS SSH 활성화 방법:

1. DSM 웹 UI 접속 (http://192.168.0.14:5000)
2. 제어판 → 터미널 및 SNMP
3. "SSH 서비스 활성화" 체크
4. 포트: 22 (또는 원하는 포트)
5. 적용

완료 후 마스터에서 다시 시도:
→ /terrafy:setup
```

### QNAP NAS

```
QNAP NAS SSH 활성화 방법:

1. QTS 웹 UI 접속
2. 제어판 → 네트워크 및 파일 서비스 → Telnet/SSH
3. "SSH 연결 허용" 체크
4. 적용
```

## 보안 참고

설정 완료 후 보안 강화를 권장합니다:
- 비밀번호 인증 비활성화 (키만 사용)
- root 로그인 비활성화
- fail2ban 설치

이는 `/terrafy:setup` 완료 후 자동으로 안내됩니다.

## 규칙

- **OS별 분기** - Linux/macOS/NAS 각각 다른 방법
- **웹 UI 필요 시 안내** - CLI 불가능한 경우 상세 가이드
- **마스터로 돌아가기 안내** - 완료 후 다음 액션 명확히
