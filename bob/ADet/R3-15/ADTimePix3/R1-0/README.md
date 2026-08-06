# ADTimePix3 Expert screens (lab bob tree)

SNS-style layout: Expert top screens live under `bob/ADet/R3-15/`, not in the driver
checkout alone. Phoebus resolves `open_display` paths relative to the **calling** screen,
so Expert must use `../../ADTimePix3/R1-0/...` from `common/subscreens/`.

| File | Role |
|------|------|
| `MediPix3/MediPix3.bob` | MediPix3 Expert (AD detail) — committed, `pathADCore` → R3-15 |
| `TimePix3.bob` | TimePix3 Expert — committed |
| `ADSetup.bob`, `Acquire/`, `Detector/`, `Mpx3Status.bob`, … | Synced from driver `tpx3App/op/bob` by `05-install-phoebus.sh` |

Driver Acquire embeds (after sync): `Mpx3ServerFileWriter`, `Mpx3PreviewChannels`, `Mpx3ImageChannels`, `Mpx3PrvImgMonitor`, **`Mpx3HdfImgConfig`**, **`Mpx3ImgMonitor`**. Tools buttons **Img** / **HDF** open the last two.

After `git pull` of this repo **and** the driver, re-run `./scripts/05-install-phoebus.sh` to refresh driver embeds. Do not overwrite committed `MediPix3.bob` / `TimePix3.bob` from the driver (script excludes them so site `pathADCore` stays R3-15).
