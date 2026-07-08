# Ubuntu 24.04 install test plan

Manual verification of `ad-timepix3-deploy` on a clean Ubuntu 24.04 server.

Machine-specific logs (command output, failures) belong under `docs/deploy/<hostname>/` (local, gitignored). Example host: `detector1` at `~/src/github/ad-timepix3-deploy`.

Optional desktop for Phoebus testing: `sudo apt install xfce4-terminal` (or any terminal + X11/VNC).

## Before you start

**Host check.** Kernel says Ubuntu 24.04, but `/etc/debian_version` shows `trixie/sid` — likely upgraded packages. The scripts use `apt`; if anything odd happens in step 0, note it. Otherwise proceed.

**Time.** A full run is **long** (often 1–3+ hours). ADSupport builds GraphicsMagick and other libs from source. ADCore and ADSupport are pinned to `master` in `config/versions.env` (must stay paired).

**Disk.** Allow **~10–15 GB** free under the install root.

**Network.** Scripts clone from GitHub and download Phoebus. On SNS, confirm `git clone https://github.com/epics-base/epics-base.git` works from `detector1`.

**Install location.** Default is `/epics`. You need write access:

```bash
# Option A — match production layout (recommended for a real site test)
sudo mkdir -p /epics
sudo chown "$USER":"$(id -gn)" /epics

# Option B — test under your home dir (no sudo for installs)
# Edit config/site.env: EPICS_ROOT=/home/kg1/epics
```

The clone path (`~/src/github/ad-timepix3-deploy`) is only the **deploy repo**; builds go to `EPICS_ROOT` (default `/epics`).

---

## Step 1 — Site config

```bash
cd /home/kg1/src/github/ad-timepix3-deploy

cp config/site.env.example config/site.env
```

Edit `config/site.env` if needed:

| Setting | Default | When to change |
|---------|---------|----------------|
| `EPICS_ROOT` | `/epics` | Use `/home/kg1/epics` for a home-dir test |
| `SERVER_URL` | `http://localhost:8081` | Serval host/port on this machine |
| `IOC_PREFIX` | `MPX3-TEST:` | Must match `PREFIX` in `st_mpx3.cmd` / `unique_mpx3.cmd` (reference for docs; edit driver startup to change PVs) |
| `IOC_STARTUP` | `st_mpx3.cmd` | `st.cmd` for TimePix3-only profile |
| `PHOEBUS_DEFAULT_SCREEN` | `main/detectors.bob` | Lab Camera launcher; or `MediPix3/MediPix3.bob` |
| `PHOEBUS_SOURCE` | `sns` | `github` off-site (no SNS VPN) |
| `MAKE_JOBS` | empty (= all CPUs) | Set e.g. `8` if you want to leave headroom |
| `GIT_DEPTH` | `1` | Set `0` if a `checkout_tag` step fails |

`config/versions.env` is already sourced automatically — no copy needed.

---

## Step 2 — Prerequisites (needs sudo once)

```bash
./scripts/00-install-prerequisites-ubuntu24.sh
```

This installs compiler, git, readline, libtiff, Java 17, etc.

Quick sanity check:

```bash
gcc --version
java -version
git --version
```

---

## Step 3 — Full deploy (or staged)

### All-in-one

```bash
cd /home/kg1/src/github/ad-timepix3-deploy
./scripts/deploy-all.sh 2>&1 | tee ~/deploy-$(date +%Y%m%d).log
```

### Staged (easier to debug first time)

```bash
./scripts/01-install-epics-base.sh          # ~10–20 min
./scripts/02-install-synapps-modules.sh     # ~15–30 min
./scripts/03-install-areadetector-core.sh # longest — ADSupport + ADCore
./scripts/04-install-adtimepix3-mpx3.sh     # driver + IOC
./scripts/05-install-phoebus.sh             # download + settings
```

If a step fails, fix the issue and re-run **that** script (scripts are mostly idempotent for re-clone/re-build).

---

## Step 4 — Verify the build

```bash
source /epics/epics-base/setEpicsEnv.sh   # or your EPICS_ROOT

# EPICS
caget --version 2>/dev/null || echo "caget in EPICS_BASE/bin/${EPICS_HOST_ARCH}"

# Driver IOC binary
ls -la /epics/support/areaDetector/ADTimePix3_mpx3/iocs/tpx3IOC/iocBoot/iocTimePix/linux-x86_64/

# Phoebus
ls -la /epics/GUI/phoebus/phoebus.sh

# areaDetector configure files
ls -la /epics/support/areaDetector/configure/RELEASE_*.local
```

---

## Step 5 — Test the IOC

**Without Serval** (smoke test — IOC should still start; acquire will fail until Serval is up):

```bash
cd /home/kg1/src/github/ad-timepix3-deploy
./scripts/launch-ioc.sh
```

Uses `IOC_STARTUP` from `config/site.env` (default `st_mpx3.cmd` for MediPix3). Override: `IOC_STARTUP=st.cmd ./scripts/launch-ioc.sh`.

In another terminal:

```bash
source /epics/epics-base/setEpicsEnv.sh
caget -V
caget MPX3-TEST:cam1:StatusMessage   # prefix from st_mpx3.cmd / unique_mpx3.cmd
```

Stop the IOC with Ctrl+C in the IOC terminal.

**With Serval** (full test): start Serval/emulator on the URL in `SERVER_URL`, then run `launch-ioc.sh` again and try acquire from Phoebus or `caput`.

If `SERVER_URL` is not in `st_base.cmd` yet, edit it under:

```text
/epics/support/areaDetector/ADTimePix3_mpx3/iocs/tpx3IOC/iocBoot/iocTimePix/
```

---

## Step 6 — Test Phoebus

Site launcher and PVA common screens: `bob/main/detectors.bob`, `bob/ADet/R3-15/`.  
Driver Expert screens: `ADTimePix3_mpx3/tpx3App/op/bob/` (e.g. `MediPix3/MediPix3.bob`).

```bash
# List site + driver screens
ls /epics/GUI/bob/main/
ls /epics/GUI/bob/ADet/R3-15/common/
ls /epics/support/areaDetector/ADTimePix3_mpx3/tpx3App/op/bob/MediPix3/

# Launch Phoebus (needs DISPLAY / X11 or VNC) — default: main/detectors.bob
cd /home/kg1/src/github/ad-timepix3-deploy
./scripts/launch-phoebus.sh
# Camera → ADMediPix3 PVA sets Sys=MPX3-TEST Dev=: (no manual P/R)
# Expert (AD detail) → MediPix3/MediPix3.bob
#
# Or open driver screen directly:
./scripts/launch-phoebus.sh MediPix3/MediPix3.bob
```

Check versions with `caget -V` (not `caget --version`).

On a headless server:

```bash
echo $DISPLAY    # must be set, e.g. :0 or via ssh -X
```

---

## Common issues

| Symptom | Likely fix |
|---------|------------|
| `Missing config/site.env` | `cp config/site.env.example config/site.env` |
| `caget` / `caput` not found | EPICS Base does not add itself to PATH — `source ${EPICS_BASE}/setEpicsEnv.sh` or `./scripts/setup-epics-shell.sh`. Regenerate: `./scripts/configure-epics-env.sh` |
| `setEpicsEnv.sh` does not exist | Same — run `./scripts/configure-epics-env.sh` (no rebuild needed) |
| `Permission denied` on `/epics` | `sudo chown` or use `EPICS_ROOT=$HOME/epics` |
| `git checkout` / tag not found | Set `GIT_DEPTH=0` in `site.env`, delete the failed clone dir, re-run |
| `make` fails on ADSupport | Check log; ensure step 0 apt packages installed |
| ADSupport GraphicsMagick: `X11/Xos.h: No such file` | `sudo apt install libx11-dev libxext-dev` (compile-time only on headless servers) or re-run step 00, then retry step 03 |
| ADCore: `No rule to make target ... libpvData.a` | EPICS 7 PVA not built — `ls $EPICS_BASE/lib/linux-x86_64/libpvData.a` should exist. On detector1, PVA git submodules were often not checked out: `git -C $EPICS_BASE submodule update --init --recursive`, then re-run step 01 |
| ADCore: `No rule to make target ... liblz4hdf5.a` | ADCore `master` + ADSupport `R1-10` mismatch — ADSupport must be `master` (builds `lz4hdf5Src`). `git -C $EPICS_BASE/../support/areaDetector/ADSupport checkout master && make -C .../ADSupport install`, then rebuild ADCore; or pull deploy repo and re-run step 03 |
| synApps `make` fails on wrong `EPICS_BASE` | Ensure `02-install-synapps-modules.sh` writes `configure/RELEASE.local` (or create manually) |
| Git asks for GitHub password on `seq` clone | Wrong repo URL — use `epics-modules/sequencer` (not `seq`); GitHub 404 looks like an auth prompt |
| seq build: `re2c: No such file or directory` | `sudo apt install re2c` or re-run `./scripts/00-install-prerequisites-ubuntu24.sh` |
| sscan build: `unknown type name 'READONLY'` | EPICS 7 needs sscan **R2-11-5+** (`shareLib.h`); set `SSCAN_TAG=R2-11-5` in `versions.env`, `rm -rf /epics/support/sscan`, re-run step 02 |
| asyn build: `rpc/rpc.h: No such file` | Install `libtirpc-dev` (step 00); deploy writes `asyn/configure/CONFIG_SITE.local` with `TIRPC=YES`. `libntirpc-dev` is not required. Re-run step 02 after both |
| asyn: `sCalcoutRecord.h: No such file` | Build **calc before asyn**; pull latest script order (`seq` → `sscan` → `calc` → `asyn` → …) |
| Re-run after partial synApps build | Re-run `./scripts/02-install-synapps-modules.sh` — skips modules with `.deploy-installed`; set `FORCE_SYNAPPS_REBUILD=1` to rebuild all |
| Phoebus won’t open | Java/display; run `java -version`, check `$DISPLAY`. SNS source bundles JDK at `/epics/GUI/jdk` |
| `05-install-phoebus.sh` leaves empty `/epics/GUI` | Default is `PHOEBUS_SOURCE=sns`; use `github` off-site. Re-run step 05 on SNS/VPN |
| GitHub Phoebus download 404 | Old script used `phoebus-product-*.zip` (does not exist); current deploy uses `phoebus-*-linux.tar.gz` |
| IOC can’t connect | Start Serval; fix `SERVER_URL` in IOC startup files |
| `Can't open .../ADCore/iocBoot/commonPlugins.cmd` | ADCore only ships `EXAMPLE_*` files — copy once: `cp -n EXAMPLE_commonPlugins.cmd commonPlugins.cmd` and `cp -n EXAMPLE_commonPlugin_settings.req commonPlugin_settings.req` in `$ADCORE/iocBoot`, or re-run step 03 (deploy script does this automatically) |
| `Pva1` / `Stats5` PV not found after IOC start | `commonPlugins.cmd` did not load — fix row above; `Stats5` comes from common plugins. `Pva1` is optional (commented in EXAMPLE); MPX3 uses driver-wired `Pva2`–`Pva6` in `st_mpx3.cmd` |
| `unable to open file auto_settings.req` | File lives in driver `iocs/tpx3IOC/iocBoot/iocTimePix/` — `git pull` in `ADTimePix3_mpx3` or re-run step 04; needs `commonPlugin_settings.req` in ADCore `iocBoot` |

---

## Minimal “did the scripts work?” checklist

1. `./scripts/00` … `05` all exit 0  
2. `source /epics/epics-base/setEpicsEnv.sh` works  
3. IOC starts with `./scripts/launch-ioc.sh`  
4. `caget` sees PVs under your prefix  
5. Phoebus launches and opens a driver `.bob` screen  

---

## Suggested first run on `detector1`

```bash
cd /home/kg1/src/github/ad-timepix3-deploy
cp config/site.env.example config/site.env
# Default PHOEBUS_SOURCE=sns (SNS product + bundled Java)
sudo mkdir -p /epics && sudo chown "$USER":"$(id -gn)" /epics
./scripts/00-install-prerequisites-ubuntu24.sh
./scripts/deploy-all.sh 2>&1 | tee ~/deploy-detector1.log
```

Then IOC + Phoebus as above.

If you hit a failure, paste the **script name** and the **last ~30 lines** of the log and we can narrow it down.
