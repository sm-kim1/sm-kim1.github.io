---
layout: case
title: Devices that come and go - designing the Component Manager
period: 2024.02 - 2025.12
role: SUGV ROS2 Component Manager
permalink: /en/case/component-manager/
lang: en
translation_key: case-component-manager
---

## Summary

On the small unmanned ground vehicle (SUGV) platform, sensors and devices connect and
disconnect during operation. I designed and developed a ROS2 runtime component manager
around a **Dynamic Device Pool** to handle these hot-plug events. It standardizes
initialization and shutdown across device types. Generic template interfaces reduced
code duplication from 28% to 21% (static analysis; a 23% relative reduction).

![Component Manager architecture]({{ '/assets/diagram-01-component-manager.svg' | relative_url }})

## The problem

- **Devices can connect or disconnect at any time.** The configuration is not fixed at startup; hot-plug is part of normal operation.
- Each device has its own initialization and shutdown steps, leading to similar code being copied for every addition.
- One faulty device must be isolated and recovered without destabilizing the whole system.

## Design decisions

### 1. Manage devices in a Dynamic Device Pool

Devices are managed through **a pool of slots**. A connection event registers a device
in a free slot and starts its lifecycle. A disconnection event runs shutdown and releases
the slot. The pool provides one view of which devices are connected, their states and
the current device count.

### 2. Abstract the lifecycle

Device-specific steps follow a common lifecycle: registration, initialization, activation,
shutdown and removal. A new device implements each stage and inherits the existing pool,
event handling and recovery logic.

### 3. Use generic interfaces to reduce duplication

The service interfaces had the same structure but different types. I designed C++ generic
template interfaces that **reduced code duplication from 28.2% to 21.4%, a 23.9% relative
reduction**, cutting repeated code when integrating new devices.

The measurement used static analysis of repeated lines after normalizing whitespace and
comments. Before templates, 16 files contained 1,068 logical lines of code, including
301 duplicate lines (28.2%). Afterward, 20 files contained 2,071 lines, including 444
duplicate lines (21.4%). Features increased the total line count; the duplication ratio
decreased. This measures maintainability rather than runtime performance.

### 4. Replace polling with a first-connection cache

The initial implementation polled device state periodically. In steady operation, it paid
for repeated calls returning the same response. I changed it to **cache interface information
at the first connection, then update it only on change events**, removing repeated calls
in the steady state.

The tradeoff was stale-cache risk versus polling overhead. Since the architecture already
observed connection and disconnection events, I used those events to keep the cache current.

### 5. Recover on timeouts

A device response that exceeds its timeout triggers recovery or reconnection. The faulty
device is isolated and recovered within its slot while the rest of the pool continues operating.

## Results

- Automatic registration and removal during runtime hot-plug events.
- A common initialization and shutdown process; new devices integrate by implementing lifecycle stages.
- Code duplication reduced from **28% to 21%** (23% relative), with repeated steady-state calls removed.
- Timeout-based recovery isolates device faults.

> The pool handles changes in device count, the lifecycle handles differences between
> device kinds, and templates handle type differences. Adding a device does not require
> changing the manager itself.
