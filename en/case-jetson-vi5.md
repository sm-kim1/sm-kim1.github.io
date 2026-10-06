---
layout: case
title: Seven hours to camera failure - debugging the VI5 kernel capture path
period: 2026
role: Autonomous Computing Platform based on NVIDIA Jetson
permalink: /en/case/jetson-vi5/
lang: en
translation_key: case-jetson-vi5
---

## Summary

On a custom board running JetPack 5.1.6 (L4T R35.6.4), streaming five GMSL cameras
for roughly seven hours caused capture to fail. Kernel threads then saturated CPU cores,
eventually leading to a watchdog reboot. I traced the problem into the vendor kernel's
VI5 capture path, patched **two kernel defects: a busy loop and a DMA leak**, and built
a deployment tool to apply the fix in the field without reflashing the boards.

## Symptoms

The failure developed in stages during sustained multi-camera streaming:

1. `uncorr_err: request timed out after 2500 ms` appeared repeatedly as error recovery (`err_rec`) cycled.
2. Hours later, `vi capture setup failed` and `fatal: error recovery failed` appeared.
3. `vi-output` kernel threads consumed **100% of a CPU core each**, accumulating across cameras.
4. Closing the application in this state caused a hard lock, followed by a CCPLEX watchdog reboot after 120 seconds.

Measured behavior: five FHD cameras at 30 fps reached a fatal error after about seven hours,
with three cores at 99.9% and load around 11. One boot recorded **15,268 error recovery cycles**.

## Tracing the cause

### Defect 1: a wait condition that ignored the error state

After `fatal: error recovery failed`, the dequeue kernel thread exited, but `capture_state`
remained `CAPTURE_ERROR`. The enqueue thread's wait condition checked only **whether the queue
contained a buffer**. A queued buffer woke the thread immediately; the error state prevented
it from consuming the buffer, so it returned to the wait and spun indefinitely.

The issue had been acknowledged in NVIDIA forum threads 244257 and 233703, but remained unfixed.
I added **`capture_state != CAPTURE_ERROR` to the wait condition** to stop the loop.

### Defect 2: a DMA leak on each recovery cycle

`capture_setup()` allocated a capture request ring with `dma_alloc_coherent`, without a
matching release path. Error recovery re-entered setup, **leaking one ring on every cycle**.
After thousands of cycles, allocation failure triggered the fatal error.

I adapted NVIDIA's subsequently published patch from forum thread 310963 to R35.6.4 and added
a **guard to release the previous ring when recovery re-entered setup**, which the official
patch did not include. I checked the other three official patches in the thread and found
equivalent changes already present in R35.6.4.

## Validation

Before-and-after soak tests on the same board:

| Measure | Before | After |
|---|---|---|
| Five FHD cameras at 30 fps | Fatal error after about 7 h, then spin and watchdog reboot | **66 hours without failure** |
| Fatal errors / recovery cycles | Present / 15,268 | **0 / 0** |
| vi-output CPU during error cycles | 100% per core | **0.7-1.8% in total** |
| 19 deliberately induced recovery cycles | One DMA ring leaked per cycle | **No change in CmaFree; no remaining threads** |

I deliberately induced 19 errors and confirmed that available DMA memory (`CmaFree`) remained unchanged.

## Field deployment without reflashing

Boards already in the field could not depend on recovery-mode flashing. I built a
**self-contained field patch tool** that replaces `/boot/Image`:

- Check that the host Image contains the fix and the target board runs R35.6.4.
- Automate transfer checksum verification, timestamped backup, replacement, reboot and kernel version verification.
- Provide a one-command rollback to the backup Image if deployment fails.

## Related fixes on the same platform

- **apt upgrades restored the stock kernel and DTB, breaking Ethernet, GPIO and CAN.** I traced the cause and prevented recurrence with kernel/bootloader package holds and a DTB restoration hook.
- **The Ethernet switch had no connectivity.** Four layered causes appeared in boot order: an unloaded expander driver, unapplied MB1 GPIO settings, missing I2C pull-ups and an absent switch driver. I resolved them in sequence.
- **GMSL cameras showed a green image.** I corrected the MCU reset sequence that cleared deserializer CSI settings and applied five other stabilization patches.
- **Three Ethernet switch driver defects surfaced under sustained stress:** an unbounded MIB counter wait, first-frame drops after idle due to EEE, and the DSA header length. I bounded the wait, disabled EEE and corrected the header. A saturated 1 Gbps test ran for 30 minutes (about 386 GB), with no loss across 35,778 pings and average RTT of 2.2-2.4 ms.
- **Camera initialization added 205 seconds to boot.** Eight serial probe operations, an 18-second flash erase and 2,048 boot-data writes at 100 ms each sat on the boot critical path. I moved camera initialization into a separate service.

> Recovery paths in vendor kernels may not have been tested through thousands of repeated
> recoveries. Here, the visible symptom (spinning) and its underlying trigger (a leak) were
> in different places. Both needed a fix.
