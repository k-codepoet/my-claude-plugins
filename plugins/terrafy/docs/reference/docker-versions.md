# Docker 환경 버전 현황

> 각 디바이스별 Docker 런타임 버전. compose 작성 시 API 호환성 참고용.
>
> 최종 확인: 2026-02-14

## 버전 매트릭스

| Device | Docker Engine | API Version | Compose | OS/Arch | Platform |
|--------|--------------|-------------|---------|---------|----------|
| **Mac Mini 1** (M1) | 29.1.3 | 1.52 | v5.0.1 | linux/arm64 | Docker Desktop |
| **Mac Mini 2** (M4) | 28.4.0 | 1.51 | v5.0.2 | linux/arm64 | Docker Desktop |
| **Linux** (Ubuntu 24.04) | 29.1.3 | 1.52 | v5.0.0 | linux/amd64 | Docker CE |
| **NAS** (DS220+) | 24.0.2 | 1.43 | v2.20.1 | linux/amd64 | Synology Container Manager |

## 주의사항

### NAS (Synology)

- Docker Engine이 24.0.2로 가장 낮음 (API 1.43)
- Compose v2.20.1 (다른 머신은 v5.x)
- compose 파일 작성 시 API 1.43 호환성 확인 필요
- `docker compose` 명령 사용 가능 (v2 plugin 방식)

### Mac Mini (Docker Desktop)

- non-interactive SSH에서 `docker` 명령이 PATH에 없음
- SSH 실행 시 `/usr/local/bin/docker` 전체 경로 사용 필요
- 또는 `PATH=/usr/local/bin:$PATH` 설정 후 실행

### 멀티플랫폼 빌드

- Mac Mini 1/2: arm64 네이티브, amd64는 QEMU 에뮬레이션
- Linux/NAS: amd64 네이티브
- buildx 멀티플랫폼 빌드는 Mac Mini (arm64 네이티브)에서 실행 권장
