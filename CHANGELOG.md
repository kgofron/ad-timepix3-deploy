# Changelog

Deploy milestones for [ad-timepix3-deploy](https://github.com/kgofron/ad-timepix3-deploy).  
Detailed history: `git log`.

## Unreleased

## 2026-07 — Phoebus operator screens (v0.1.1)

Tested on LAP142249 with live MediPix3 acquire (histogram, intensity, Expert panels).

### Lab launcher and PVA view
- `bob/main/detectors.bob` — Camera menu for ADTimePix3 / ADMediPix3 PVA (`Sys`/`Dev` macros)
- `bob/ADet/R3-15/common/color_camera_pva.bob` + `_ad_view_*` subscreens (adapted from SNS R3-11)
- Default launch screen: `main/detectors.bob`
- Full PVA operator embeds: histogram, intensity, display controls (ROI/autoscale), transform/process

### Expert (AD detail)
- Expert tops under `bob/ADet/R3-15/ADTimePix3/R1-0/` (SNS-style relative paths from `subscreens/`)
- ADCore `.bob` screens synced from built checkout `ADApp/op/bob/autoconvert` → `ADCore/R3-15/` (not vendored SNS `.opi`)
- Driver support panels (`ADSetup`, `Acquire/`, `Detector/`, …) rsynced at install from `ADTimePix3_mpx3/tpx3App/op/bob`

### Install / launch
- `05-install-phoebus.sh`: ADCore bob sync, driver embed sync, refresh `settings.ini` model paths
- `launch-phoebus.sh`: resolve Expert screens from site bob tree before driver copy

## 2026-07 — MediPix3 site deploy (ORNL / ASI)

### Launch and operator workflow
- Default IOC startup: `st_mpx3.cmd` (`IOC_STARTUP` in `site.env`)
- Default Phoebus screen: `MediPix3.bob` with path resolution in `launch-phoebus.sh`
- PV prefix documented as `MPX3-TEST:` (matches `st_mpx3.cmd`)

### Environment and tools
- Generate `${EPICS_BASE}/setEpicsEnv.sh` for `caget` / `caput` on PATH
- `configure-epics-env.sh` and `setup-epics-shell.sh` for existing installs

### Phoebus
- SNS `product-sns-linux.zip` or GitHub `phoebus-*-linux.tar.gz` (`PHOEBUS_SOURCE`)
- Default `PHOEBUS_SOURCE=sns` for ORNL/SNS machines

### areaDetector / EPICS build fixes (Ubuntu 24.04)
- ADCore iocBoot: copy `EXAMPLE_commonPlugins.cmd` → `commonPlugins.cmd` (+ `.req`)
- EPICS Base: init PVA git submodules before build
- ADSupport `master` paired with ADCore `master` (lz4hdf5)
- synApps: RELEASE.local, build order, sscan R2-11-5, asyn TIRPC, re2c, X11 dev libs

### Project metadata
- MIT LICENSE (UT-Battelle / ORNL)
- SPDX headers on deploy scripts and config templates
- Ubuntu 24.04 test plan: `docs/testing/ubuntu-24.04.md`

## 2026-06 — Initial deploy scripts

- Scripts 00–05: prerequisites through Phoebus
- `ADTimePix3_mpx3` driver install (kgofron `medipix3-integration`)
- areaDetector `RELEASE_*.local` templates for `/epics/support/areaDetector`
