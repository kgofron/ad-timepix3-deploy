# Draft email — Erik (ASI): EPICS + Phoebus for ADTimePix3_mpx3

**Subject:** EPICS areaDetector (MediPix3) + Phoebus install on Ubuntu 24.04

---

Hi Erik,

Here is a reproducible way to install the EPICS areaDetector stack for **MediPix3** on your Ubuntu 24.04 server, including **Phoebus** operator screens.

## Overview

We use a development driver checkout **`ADTimePix3_mpx3`** (MediPix3 branch of the [ADTimePix3](https://github.com/areaDetector/ADTimePix3) driver). It installs under:

```text
/epics/support/areaDetector/ADTimePix3_mpx3
```

Phoebus `.bob` screens for the detector are shipped inside that module (`tpx3App/op/bob/`). A small companion repo provides **deployment scripts** and a simplified **main screen** layer (similar in spirit to SNS facility screens, but without beamline-specific pieces).

**Deployment repo:** `ad-timepix3-deploy` (suggested name; currently `deployAD` on my side)  
**Clone and run:**

```bash
git clone <URL> ad-timepix3-deploy
cd ad-timepix3-deploy
cp config/site.env.example config/site.env
# edit SERVER_URL, paths if needed
./scripts/deploy-all.sh
```

Full README and dependency list are in the repository.

## What gets installed

| Layer | Location |
|-------|----------|
| EPICS Base 7.0 | `/epics/epics-base` |
| synApps modules (asyn, autosave, busy, calc, seq, sscan, …) | `/epics/support/` |
| areaDetector configure (`RELEASE_*.local`) | `/epics/support/areaDetector/configure/` |
| ADCore, ADSupport | `/epics/support/areaDetector/` |
| ADTimePix3_mpx3 driver + IOC | `/epics/support/areaDetector/ADTimePix3_mpx3` |
| Phoebus | `/epics/GUI/phoebus` |
| Simplified main `.bob` screens | `/epics/GUI/bob` |

## Prerequisites you provide

1. **Serval** — same major version as your detector/emulator (we test with Serval 4.1.5 for 4.x).
2. Network access from the IOC host to Serval’s HTTP port (default in IOC: `http://localhost:8081` — change in `st_base.cmd` if Serval runs elsewhere).
3. Sudo for one-time `apt` packages (build tools, Java, libtiff, …). GraphicsMagick is built inside ADSupport — no system GraphicsMagick dev package required.

## After install

```bash
source /epics/epics-base/setEpicsEnv.sh

# Terminal 1 — start Serval first, then:
cd /epics/support/areaDetector/ADTimePix3_mpx3/iocs/tpx3IOC/iocBoot/iocTimePix
./st.cmd

# Terminal 2 — Phoebus (main MediPix3 screen)
/epics/GUI/phoebus/phoebus.sh -settings /epics/GUI/phoebus/settings.ini \
  -resource bob/main/MediPix3.bob
```

(Exact screen name may be `MediPix3.bob` or `TimePix3.bob` depending on your chip layout — both live under `tpx3App/op/bob/`.)

## Phoebus screens — plan

- **Detector-specific panels** stay in the driver repo (Connection, Acquire, Mask, …) — these can eventually merge to [areaDetector/ADTimePix3](https://github.com/areaDetector/ADTimePix3).
- **Generic areaDetector “main” embed** (collect, plugins, PVA image) we are simplifying from SNS templates; candidate for a new `Phoebus/` folder in [areaDetector/ADViewers](https://github.com/areaDetector/ADViewers) if the collaboration wants a standard entry screen for all detectors.

For your site we only need the main detector screen, not the full SNS beamline GUI.

## Key technical notes

- **asyn ≥ R4-45** and recent **ADCore** (destructible driver teardown) are required.
- Driver build uses **C++17**; Ubuntu 24.04 default GCC is fine.
- CPR/json are **bundled** in the driver — no separate install.
- IOC can start **before** Serval; reconnect logic refreshes SDK version and detector state when Serval comes up.

Happy to walk through the first install on a call if useful. Let me know your Serval version and whether the IOC runs on the same machine as Serval or remotely.

Best,  
Kaz

---

*Internal refs: [areaDetector install guide](https://areadetector.github.io/areaDetector/install_guide.html), [ADTimePix3 README](https://github.com/areaDetector/ADTimePix3), deploy repo `docs/architecture.md`.*
