---
layout: case
title: From JetPack BSP to Yocto - porting strategy and design decisions
period: 2025.03 - Present
role: Jetson BSP Port to Yocto and Minimal Images
permalink: /en/case/yocto/
lang: en
translation_key: case-yocto
---

## Summary

I ported an Ubuntu-based JetPack BSP to a Yocto build based on meta-tegra. A single custom
layer defines both Orin NX and AGX Orin machines. Compared with JetPack, the resulting image
uses **67% less disk space, 86% fewer packages and 79% less idle memory**, with recipes that
produce the same image across the team.

## Why move to Yocto?

Operating the Ubuntu-based BSP in the field exposed several recurring problems:

- **Inconsistent systems:** each board had its own apt history, so the same version label did not mean the same system.
- **apt overwrote custom kernels and DTBs:** this had caused real failures, as described in the [VI5 case study]({{ '/en/case/jetson-vi5/' | relative_url }}). Prevention measures helped, but the package manager and custom BSP still conflicted.
- **Unnecessary packages:** desktop-oriented images were large, slow to boot and had a wider attack surface.

Yocto addresses these issues together. Recipes define what goes into the image, making
the build reproducible and limiting it to the required packages.

## Design decisions

### Match versions to retain validated patches

I kept the existing BSP combination: L4T R35.6.4, JetPack 5.1.6 and kernel 5.10,
paired with Yocto **scarthgap** (5.0 LTS, with support planned through about 2028).
Keeping the kernel version allowed the already validated BSP patches, including the
VI5 fixes, to carry over.

### Manage two machines in one layer

```text
layers/meta-<board>/          <- one custom layer
  machines: <board>-nx / <board>-agx
```

The NX and AGX build trees share the layer through symlinks. Board differences use
`SRC_URI:append:<machine>` and `do_install:append:<machine>` overrides.
**One layer change reaches both machines**, avoiding duplicate maintenance.
Shared `downloads/` and `sstate-cache/` directories let the second machine reuse most build artifacts.

### Establish boot first, then add the platform

I staged the port so that failures could be isolated:

1. **Validate the unmodified machine:** build a stock image to check the build chain.
2. **Define the custom machine:** bring in the existing pinmux configuration, BCT, DTB and UEFI.
3. **Port the kernel:** apply existing local patches through bbappend files.
4. **Add runtime setup:** package GPIO and CAN initialization as systemd service recipes.
5. Validate in order: boot, Ethernet, CAN, then GPU.

Each stage had to work before the next began, keeping the source of a failure within one step.

## A host environment issue

On an Ubuntu 24.04 host, every BitBake task failed immediately. AppArmor restricted
unprivileged user namespaces, which BitBake uses for task network isolation through
`disable_network` in `bitbake-worker`. Writing `uid_map` failed with `EPERM`.
For that build host, I changed `kernel.apparmor_restrict_unprivileged_userns` to `0`
and documented the requirement in the host setup guide.

## Results

- **67% less disk use, 86% fewer packages and 79% less idle memory**, measured on the same board and kernel: 7.9 to 2.6 GB, 1,942 to 271 packages and 1,430 to 296 MB.
- Recipes define the system, producing a consistent image across builders.
- Build output includes the tegraflash package and `doflash.sh`, connecting the build and flashing workflows.
- Systemd startup fell from 62 to 6.2 seconds; power-on to login from about 30 to 18.8 seconds.
- NVMe detection succeeded in 19/19 boots, including 10/10 cold power cycles.

## Boot time and flashing reliability

The first working minimal image still took 62 seconds to start according to systemd.
Three delays stood out: `networkd-wait-online` waited 21.6 seconds; kernel logs took
3.3 seconds to transmit over a 115,200 bps serial console; and UEFI waited 5.2 seconds
for keyboard input. I masked the network wait, set `quiet loglevel=4` and injected
`Timeout=0` through a DTBO. The final measured systemd startup time was 6.2 seconds.

Intermittent detection of `nvme0n1` came from PCIe link training. I restored the custom
UEFI, increased `nvidia,link_up_to` and extended the initrd wait from 15 to 90 seconds.
Validation passed all 10 cold power cycles and all 19 boots including warm restarts.

A separate latent defect dropped the board into the UEFI Shell after three reboots.
The image lacked `/etc/nv_boot_control.conf` and `xxd`, preventing `nvbootctrl verify`
from running. Once the UEFI retry counter was exhausted, the slot became invalid.
The old image had the same defect, but flashing erased QSPI and reset the counter,
masking it. I added configuration generation and `xxd` to the tarball, then verified
five reboots.

## Documentation

I handled the port, but the team needed to operate it. I wrote an onboarding guide
that takes an engineer with no Yocto experience through a complete build, explains
recipes, layers and BitBake with concrete comparisons, and links to further reading.
