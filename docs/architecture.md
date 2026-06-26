# Screen and deployment architecture

## EPICS stack

| Component | Path | Notes |
|-----------|------|-------|
| EPICS Base | `/epics/epics-base` | 7.0.x |
| asyn | `/epics/support/asyn` | **≥ R4-45** (destructible drivers) |
| autosave, busy, calc, seq, sscan | `/epics/support/...` | Required for areaDetector IOCs |
| iocStats | `/epics/support/iocStats` | Optional but useful |
| ADSupport | `.../areaDetector/ADSupport` | Builds TIFF, HDF5, XML2, GraphicsMagick, … |
| ADCore | `.../areaDetector/ADCore` | Plugins, `commonPlugins.cmd` |
| ADTimePix3_mpx3 | `.../areaDetector/ADTimePix3_mpx3` | MediPix3 fork; bundles CPR 1.14.2, json |

### ADTimePix3 external deps

Bundled in `tpx3Support/` (no separate CPR/json install):

- CPR 1.14.2, nlohmann/json 3.11.2
- C++17 compiler
- GraphicsMagick (via ADSupport `WITH_GRAPHICSMAGICK=YES`)

System packages on Ubuntu 24.04: see `scripts/00-install-prerequisites-ubuntu24.sh`. GraphicsMagick is built from source in ADSupport (not a system `apt` package).

### Runtime (not installed by these scripts)

- **Serval** — ASI TimePix3 / MediPix3 server (Erik provides; match [Serval 4.1.5](https://github.com/areaDetector/ADTimePix3) for 4.x)
- **TimePix3 Emulator** — optional for offline test

## Phoebus

Product install from [ControlSystemStudio/phoebus releases](https://github.com/ControlSystemStudio/phoebus/releases).  
Requires **Java 11+** (OpenJDK 17 on Ubuntu 24.04).

Display path order:

1. `bob/main/` — simplified main screen (this repo)
2. `ADTimePix3_mpx3/tpx3App/op/bob/` — detector panels

## IOC

Default IOC: `ADTimePix3_mpx3/iocs/tpx3IOC/iocBoot/iocTimePix`

Before first run:

1. Start Serval on the detector PC or localhost.
2. Set `SERVER_URL` in `st_base.cmd` or `config/site.env`.
3. Set chip layout in `unique.cmd` / `load_chips.cmd` for hardware.

## Relation to SNS GUI

ORNL SNS screens live under `/epics/GUI/SNS/bob/ADet/R3-11/`. They reference:

- `pathADet` → facility `bob/main` (beamline navigation)
- `pathADCore` → versioned ADCore OPI embeds

ASI deployment **drops facility navigation** and keeps:

- `TimePix3.bob` or `MediPix3.bob` as top screen
- `ConnectionStatus.bob`, `ADSetup.bob`, `Acquire/ADCollect.bob` from driver tree

That split mirrors how areaDetector intends detector-specific OPIs in each driver repo vs shared ADCore templates.
