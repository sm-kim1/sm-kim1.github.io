---
layout: case
title: JetPack BSP를 Yocto로 — 왜 옮겼고 어떻게 설계했나
period: 2025.03 — 현재
role: Jetson BSP의 Yocto 포팅 및 최소화 이미지 빌드
permalink: /case/yocto/
---

## 요약

Ubuntu 기반 JetPack BSP를 meta-tegra 기반 Yocto 빌드로 이식했다.
커스텀 레이어 하나로 Orin NX · AGX Orin 두 머신을 정의하고,
JetPack 대비 **디스크·패키지 91% 축소**, 누가 빌드해도 같은 이미지가 나오는 체계를 만들었다.

## 왜 옮겼나

Ubuntu 기반 BSP를 현장에서 운영하며 누적된 문제들:

- **재현성 없음** — 보드마다 apt 이력이 달라 "같은 버전"이 같은 시스템이 아니었다
- **apt가 커스텀 커널·DTB를 덮어씀** — 실제 장애로 이어진 적이 있다 ([VI5 케이스](/case/jetson-vi5/) 참조). 방지 처리를 했지만, 근본적으로는 패키지 매니저와 커스텀 BSP의 충돌 구조 자체가 문제
- **불필요한 것이 너무 많음** — 데스크톱용 패키지가 가득한 이미지는 부팅도 느리고 공격 표면도 넓다

Yocto로 옮기면 이 세 가지가 같이 해결된다. 레시피에 적힌 대로만 이미지가 만들어지니
재현이 되고, apt 자체가 없으니 커널이 덮어써질 일도 없고, 필요한 패키지만 들어간다.

## 설계 결정

### 버전 1:1 매칭 — 검증 결과를 이월하기 위해

기존 BSP와 정확히 같은 조합(L4T R35.6.4 / JetPack 5.1.6 / kernel 5.10)에
Yocto **scarthgap**(4.0 LTS, ~2028 지원)을 맞췄다. 커널 버전이 같아야 기존 BSP에서
검증한 커널 패치들(VI5 픽스 등)을 그대로 가져올 수 있기 때문이다.

### 단일 레이어로 두 머신 관리

```
layers/meta-a1driver/        ← 실제 산출물 (커스텀 레이어 하나)
  machines: a1-driver-nx / a1-driver-agx
```

NX·AGX 두 빌드 트리가 같은 레이어를 공유(심링크)하고, 보드별 차이는
`SRC_URI:append:<machine>` / `do_install:append:<machine>` override 구문으로만 분기한다.
**레이어를 한 번 수정하면 두 머신에 다 반영** — 두 벌 유지보수를 구조적으로 차단.
`downloads/`와 `sstate-cache/`도 공유해 두 번째 머신 빌드는 산출물 대부분을 재사용한다.

### 부팅 최우선 이식 전략

한 번에 다 옮기지 않고, 실패 지점을 격리할 수 있는 순서로:

1. **vanilla 검증** — 순정 머신으로 이미지 빌드, 빌드 체인 자체를 먼저 검증
2. **커스텀 머신** — 기존 BSP의 pinmux cfg / BCT / DTB / UEFI를 레이어로 주입
3. **커널** — 기존 BSP의 로컬 패치를 bbappend 패치로 이식
4. **런타임** — 하드웨어 초기화 스크립트(GPIO, CAN)를 systemd 서비스 레시피로
5. 검증 순서: 부팅 → 이더넷 → CAN → GPU

각 단계가 끝나야 다음 단계로 — 어디서 깨졌는지 항상 한 단계 안에서 찾을 수 있다.

## 부딪힌 문제 하나

Ubuntu 24.04 호스트에서 bitbake의 모든 태스크가 즉시 실패했다.
원인: 24.04가 비특권 user namespace를 AppArmor로 제한하는데, bitbake는 태스크
네트워크 격리에 userns를 쓴다(`bitbake-worker`의 `disable_network`). 제한 상태에서
uid_map 기록이 EPERM으로 죽는 것. `kernel.apparmor_restrict_unprivileged_userns=0`
sysctl로 해제하고 재발 방지를 위해 호스트 요구사항 문서에 박아뒀다.

## 결과

- JetPack 대비 **디스크 사용량 · 패키지 수 91% 감소**
- 레시피 = 시스템 정의: 누가 빌드해도 같은 이미지
- 산출물에 tegraflash 패키지(`doflash.sh` 포함)까지 — 빌드에서 플래시까지 한 흐름

## 문서화

포팅은 혼자 했지만 운영은 팀이 같이 하게 되기 때문에, Yocto를 한 번도 안 써본 팀원이
혼자 빌드까지 갈 수 있는 온보딩 가이드를 함께 작성했다. recipe/layer/bitbake 개념을
비유로 풀고, 더 공부할 사람을 위한 링크를 곳곳에 넣어뒀다.
