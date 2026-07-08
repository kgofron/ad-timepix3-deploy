# Phoebus screens (site / ASI lab)

Lab operator screens for **ADTimePix3 / MediPix3**. Driven by Phoebus `model/paths`
(`BOB_ROOT` + driver `tpx3App/op/bob`).

## Layout

```text
bob/
  main/
    detectors.bob              ← Camera launcher (2 choices)
  ADet/
    R3-15/                     ← pin matching ADCore master / pre-R3-15
      ADCore/R3-15/            ← ADCore .bob from build autoconvert (install sync)
      ADTimePix3/R1-0/         ← Expert tops + driver embeds (install sync)
      common/
        color_camera_pva.bob   ← PVA operator view
        subscreens/
          _ad_view_controls.bob
          _ad_view_image_pva*.bob
        Images/                ← optional branding
```

```text
detectors.bob
  └─ Camera
       ├─ ADTimePix3 PVA  → ADet/R3-15/common/color_camera_pva.bob
       │     macros: Sys=TPX3-TEST  Dev=:  Cam=cam1: …
       └─ ADMediPix3 PVA  → same screen
             macros: Sys=MPX3-TEST  Dev=:  Cam=cam1: …
                └─ Expert (AD detail)
                     ├─ ADet/R3-15/ADTimePix3/R1-0/TimePix3.bob
                     └─ ADet/R3-15/ADTimePix3/R1-0/MediPix3/MediPix3.bob
```

Effective PV prefix is **`$(Sys)$(Dev)`** (SNS convention), e.g. `MPX3-TEST:`.

Expert **top** screens are vendored under **`bob/ADet/R3-15/ADTimePix3/R1-0/`** (SNS pattern).
Driver **support** panels (`ADSetup`, `Acquire/`, `Detector/`, …) are rsynced from
`ADTimePix3_mpx3/tpx3App/op/bob/` by `05-install-phoebus.sh`.

## Provenance

`ADet/R3-15/common/*` started from SNS `/epics/GUI/SNS/bob/ADet/R3-11/common`.
`ADCore/R3-15/*.bob` is synced from `${AREA_DETECTOR}/ADCore/ADApp/op/bob/autoconvert`
at install (matches `ADCORE_TAG`). Expert layout follows SNS `ADTimePix3/R1-0/` pattern.

## Launch

```bash
./scripts/launch-phoebus.sh detectors.bob
# or after site.env default: PHOEBUS_DEFAULT_SCREEN=main/detectors.bob
```

## License

MIT — (c) UT-Battelle, LLC, Oak Ridge National Laboratory. See [LICENSE](../LICENSE).
Screens adapted from SNS facility tree for lab use.
