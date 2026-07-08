# ADTimePix3 Expert screens (lab bob tree)

SNS-style layout: Expert top screens live under `bob/ADet/R3-15/`, not in the driver
checkout alone. Phoebus resolves `open_display` paths relative to the **calling** screen,
so Expert must use `../../ADTimePix3/R1-0/...` from `common/subscreens/`.

| File | Role |
|------|------|
| `MediPix3/MediPix3.bob` | MediPix3 Expert (AD detail) — committed, `pathADCore` → R3-15 |
| `TimePix3.bob` | TimePix3 Expert — committed |
| `ADSetup.bob`, `Acquire/`, `Detector/`, … | Synced from driver `tpx3App/op/bob` by `05-install-phoebus.sh` |

After `git pull`, re-run `./scripts/05-install-phoebus.sh` to refresh driver embeds.
