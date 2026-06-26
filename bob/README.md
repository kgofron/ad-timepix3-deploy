# Simplified areaDetector Phoebus screens (site / ASI)

This directory holds a **minimal main-screen layer** — analogous to SNS  
`/epics/GUI/SNS/bob/ADet/.../common` but stripped for a single-detector lab.

## Layering (target architecture)

```text
┌─────────────────────────────────────────────────────────┐
│  bob/main/TimePix3.bob     ← this repo (site / ADViewers) │
│    embeds ADCore subscreens (collect, plugins, PVA)      │
│    links to driver screens below                         │
├─────────────────────────────────────────────────────────┤
│  ADTimePix3_mpx3/tpx3App/op/bob/  ← detector repo        │
│    MediPix3.bob, ConnectionStatus, Acquire/*, …        │
├─────────────────────────────────────────────────────────┤
│  ADCore/ADSupport (no bob) — templates referenced by path│
└─────────────────────────────────────────────────────────┘
```

Upstream pattern today:

- **Detector repo** ships operator screens (`tpx3App/op/bob/` in [ADTimePix3](https://github.com/areaDetector/ADTimePix3)).
- **Facility GUI** (SNS `bob/ADet/R3-11/...`) adds beamline-specific layout and ADCore embed paths.

For Erik / ASI we only need the **main detector screen** plus ADCore collect/plugins — not the full SNS beamline tree.

## ADViewers contribution?

[ADViewers](https://github.com/areaDetector/ADViewers) today hosts ImageJ, Python, and IDL viewers — not Phoebus `.bob` files. Options:

1. **Add `Phoebus/` subtree to ADViewers** — generic `areaDetectorMain.bob` + README (preferred if areaDetector agrees).
2. **Keep site screens here** — `asi-epics-phoebus` deploy repo only.
3. **Upstream into ADTimePix3** — only detector-specific panels (already there); avoid duplicating ADCore embeds.

Screens here should use **relative macros** (`pathADCore`, `pathDriver`) so they work on any install path.

## Status

Placeholder — simplified `TimePix3.bob` to be derived from  
`/epics/GUI/SNS/bob/ADet/R3-11/ADTimePix3/R1-0/TimePix3.bob` with SNS-only paths removed.
