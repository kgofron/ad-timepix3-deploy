# areaDetector TimePix3 / MediPix3 site deployment

Scripts and configuration to install EPICS areaDetector with **ADTimePix3_mpx3** and **Phoebus** on a clean **Ubuntu 24.04** server (e.g. Erik @ ASI).

## Layout on the target machine

```text
/epics/epics-base              EPICS Base 7.0.x
/epics/support/                  synApps-style support modules
  asyn, autosave, busy, calc, seq, sscan, iocStats, …
  areaDetector/
    ADCore, ADSupport
    ADTimePix3_mpx3            MediPix3 development driver (kgofron fork)
/epics/GUI/phoebus             Phoebus product install
/epics/GUI/bob                 Simplified areaDetector main screens (this repo)
```

Detector-specific `.bob` screens ship with the driver under  
`ADTimePix3_mpx3/tpx3App/op/bob/` (same pattern as upstream [ADTimePix3](https://github.com/areaDetector/ADTimePix3)).

## Quick start (Erik's server)

```bash
git clone https://github.com/kgofron/ad-timepix3-deploy.git
cd ad-timepix3-deploy
cp config/site.env.example config/site.env
# edit config/site.env — paths, PHOEBUS_SOURCE (default sns; github off-site), git URLs
./scripts/deploy-all.sh
```

After build:

```bash
# Terminal 1 — start Serval (ASI), then IOC
./scripts/launch-ioc.sh

# Terminal 2 — Phoebus
./scripts/launch-phoebus.sh bob/main/TimePix3.bob
```

See [docs/architecture.md](docs/architecture.md) for screen layering and a possible [ADViewers](https://github.com/areaDetector/ADViewers) contribution path. For manual install testing on Ubuntu 24.04, see [docs/testing/ubuntu-24.04.md](docs/testing/ubuntu-24.04.md).

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/00-install-prerequisites-ubuntu24.sh` | `apt` build deps (compiler, readline, libtiff, Java, …) |
| `scripts/01-install-epics-base.sh` | Clone & build EPICS Base |
| `scripts/02-install-synapps-modules.sh` | asyn, autosave, busy, calc, seq, sscan, iocStats |
| `scripts/configure-areadetector.sh` | Write `RELEASE_LIBS.local`, `RELEASE_PRODS.local`, `CONFIG_SITE.local` |
| `scripts/03-install-areadetector-core.sh` | ADSupport + ADCore |
| `scripts/04-install-adtimepix3-mpx3.sh` | Driver fork + IOC build |
| `scripts/05-install-phoebus.sh` | Phoebus product + settings |
| `scripts/deploy-all.sh` | Run all of the above in order |
| `scripts/launch-ioc.sh` | Boot `iocTimePix` (edit `SERVER_URL` first) |
| `scripts/launch-phoebus.sh` | Start Phoebus with site `settings.ini` |

Pinned versions live in `config/versions.env`. Site paths in `config/site.env`.

### areaDetector configure (Erik's server)

Deploy writes these under **`/epics/support/areaDetector/configure/`**:

| File | Used when building |
|------|-------------------|
| `RELEASE_LIBS.local` | ADSupport, ADCore, ADTimePix3_mpx3 driver library |
| `RELEASE_PRODS.local` | IOC (`tpx3App`) — adds synApps + `ADTIMEPIX` |
| `CONFIG_SITE.local` | ADSupport flags (GraphicsMagick/HDF5 built in-tree) |

Templates live in `config/areaDetector/*.template`. Re-apply after path changes:

```bash
./scripts/configure-areadetector.sh
```


## References

- [areaDetector installation guide](https://areadetector.github.io/areaDetector/install_guide.html)
- [ADTimePix3](https://github.com/areaDetector/ADTimePix3) — requires asyn ≥ R4-45, ADCore R3-11+, C++17
- [ADViewers](https://github.com/areaDetector/ADViewers) — community viewers (ImageJ, Python, IDL; Phoebus `.bob` TBD)
