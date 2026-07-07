# Release v0.1.0 notes

Published: https://github.com/kgofron/ad-timepix3-deploy/releases/tag/v0.1.0

Copy below was used for the GitHub Release body (also editable via `gh release edit v0.1.0 --notes-file docs/release-v0.1.0-notes.md`).

---

First tagged release of ad-timepix3-deploy for EPICS areaDetector + ADTimePix3_mpx3 + Phoebus on Ubuntu 24.04.

## Install

```bash
git clone https://github.com/kgofron/ad-timepix3-deploy.git
cd ad-timepix3-deploy
git checkout v0.1.0
cp config/site.env.example config/site.env
# edit paths, SERVER_URL, PHOEBUS_SOURCE (sns on ORNL/SNS)
./scripts/deploy-all.sh
source ${EPICS_BASE}/setEpicsEnv.sh
./scripts/launch-ioc.sh
./scripts/launch-phoebus.sh
```

## Highlights

- Scripts 00–05: EPICS Base, synApps, ADSupport/ADCore, ADTimePix3_mpx3, Phoebus
- `setEpicsEnv.sh` generation (`caget` / `caput` on PATH)
- SNS or GitHub Phoebus (`PHOEBUS_SOURCE`)
- ADCore `commonPlugins.cmd` site copy
- Default MediPix3: `st_mpx3.cmd`, `MediPix3.bob`, `MPX3-TEST:` prefix

## Docs

- [README](https://github.com/kgofron/ad-timepix3-deploy/blob/v0.1.0/README.md)
- [Ubuntu 24.04 test plan](https://github.com/kgofron/ad-timepix3-deploy/blob/v0.1.0/docs/testing/ubuntu-24.04.md)
- [CHANGELOG](https://github.com/kgofron/ad-timepix3-deploy/blob/v0.1.0/CHANGELOG.md)

## Requirements

- Ubuntu 24.04, ~10–15 GB disk, network for git/GitHub
- Serval (ASI) for live detector — IOC starts without it; acquire needs Serval
