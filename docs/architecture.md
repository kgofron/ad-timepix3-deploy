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
| ADTimePix3_mpx3 | `.../areaDetector/ADTimePix3_mpx3` | [kgofron/ADTimePix3](https://github.com/kgofron/ADTimePix3) **R1-7-0** (unified TPX3+MPX3); [PR #15](https://github.com/areaDetector/ADTimePix3/pull/15) to upstream |

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

Product install via `05-install-phoebus.sh` — source set in `config/site.env`:

| `PHOEBUS_SOURCE` | Download | Notes |
|------------------|----------|-------|
| `sns` (default) | [ORNL/SNS CS-Studio](https://controlssoftware.sns.ornl.gov/css_phoebus/) `product-sns-linux.zip` | Bundled `jdk` at `/epics/GUI/jdk`; SNS network/VPN only |
| `github` | [ControlSystemStudio/phoebus releases](https://github.com/ControlSystemStudio/phoebus/releases) `phoebus-*-linux.tar.gz` | Off-site; needs Java 11+ (`openjdk-17-jre` from step 00) |

Requires **Java 11+** for `github` source (OpenJDK 17 on Ubuntu 24.04).

Display path order:

1. `bob/main/detectors.bob` — Camera launcher (`Sys`/`Dev` → `MPX3-TEST:` / `TPX3-TEST:`)
2. `bob/ADet/R3-15/common/` — PVA viewer (pinned to ADCore master / pre-R3-15)
3. `bob/ADet/R3-15/ADCore/R3-15/` — ADCore `.bob` screens (from built `autoconvert`, install sync)
4. `bob/ADet/R3-15/ADTimePix3/R1-0/` — Expert tops + driver embeds (rsync at install)
5. `ADTimePix3_mpx3/tpx3App/op/bob/` — driver source for support panels (also in model path)

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

This deploy vendors under `bob/ADet/R3-15/` (name tracks ADCore master ≈ R3-15), adapted from SNS R3-11:

- `main/detectors.bob` — Camera menu only (TimePix / MediPix PVA)
- `common/color_camera_pva.bob` + `_ad_view_*` — operator PVA view
- `ADCore/R3-15/*.bob` — from ADCore build `ADApp/op/bob/autoconvert` (not vendored SNS `.opi`)
- `ADTimePix3/R1-0/` — Expert tops; `open_display` uses relative paths from `subscreens/`

ASI deployment **drops** Logbook/Archiver/Motion and facility `pathADet` absolute paths.
