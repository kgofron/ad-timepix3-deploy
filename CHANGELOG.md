# Changelog

Deploy milestones for [ad-timepix3-deploy](https://github.com/kgofron/ad-timepix3-deploy).  
Detailed history: `git log`.

## Unreleased

- ADCore Phoebus: sync `ADApp/op/bob/autoconvert` → `bob/ADet/R3-15/ADCore/R3-15/` (not vendored SNS `.opi`)
- Vendor `bob/ADet/R3-15/ADCore/R3-15/` install path for Expert embeds
- Expert tops under `bob/ADet/R3-15/ADTimePix3/R1-0/`; fix `open_display` relative paths
- `05-install-phoebus.sh`: rsync driver bob embeds; refresh `settings.ini` model paths
- Phoebus lab tree: `bob/main/detectors.bob` + `bob/ADet/R3-15/common` (from SNS R3-11, retargeted)
- Default launch screen `main/detectors.bob`
- Unhide PVA operator embeds: histogram, intensity, display controls, transform/process

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
