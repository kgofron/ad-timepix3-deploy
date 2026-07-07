# Changelog

Deploy milestones for [ad-timepix3-deploy](https://github.com/kgofron/ad-timepix3-deploy).  
Detailed history: `git log`.

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
