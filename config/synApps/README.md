# synApps module build order

Each epics-modules tree ships `configure/RELEASE` with the author's paths. Deploy
writes `configure/RELEASE.local` from `RELEASE.local.template` (site paths under
`/epics`).

Build order follows **dependencies in each module's `configure/RELEASE`**, not
alphabetical order. Reference layout: `/epics/support2` on ORNL laptops.

| Module   | Tag source        | Needs (library build)                    |
|----------|-------------------|------------------------------------------|
| `seq`    | `SNCSEQ_TAG`      | `EPICS_BASE` — clone [epics-modules/sequencer](https://github.com/epics-modules/sequencer), install as `${SUPPORT}/seq` |
| `sscan`  | `SSCAN_TAG`       | `EPICS_BASE`, `SNCSEQ`                   |
| `calc`   | `CALC_TAG`        | `EPICS_BASE`, `SSCAN` (swait record)     |
| `asyn`   | `ASYN_TAG`        | `EPICS_BASE`, `CALC` (sCalcout in devEpics) |
| `autosave` | `AUTOSAVE_TAG`  | `EPICS_BASE`                             |
| `busy`   | `BUSY_TAG`        | `EPICS_BASE` (test app: `ASYN`, `AUTOSAVE`) |
| `iocStats` | `IOCSTATS_TAG`  | `EPICS_BASE` (test app: `SNCSEQ`)        |

`02-install-synapps-modules.sh` uses this order. A successful install writes
`${SUPPORT}/<module>/.deploy-installed` (tag name). Re-runs skip built modules
unless `FORCE_SYNAPPS_REBUILD=1`.

Facility-scale alternative: [NSLS2/installSynApps](https://github.com/NSLS2/installSynApps).
