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
                     ├─ TimePix3.bob
                     └─ MediPix3/MediPix3.bob   ← resolved via driver op/bob path
```

Effective PV prefix is **`$(Sys)$(Dev)`** (SNS convention), e.g. `MPX3-TEST:`.

Driver tops stay in **`ADTimePix3_mpx3/tpx3App/op/bob/`** (not duplicated here).

## Provenance

`ADet/R3-15/common/*` started from SNS `/epics/GUI/SNS/bob/ADet/R3-11/common`
and was adapted for this deploy (CORE_VER, Expert → `.bob` only, no facility menu).
Screen tree name is **R3-15** to align with ADCore `master` (forthcoming R3-15 tag).

## Launch

```bash
./scripts/launch-phoebus.sh detectors.bob
# or after site.env default: PHOEBUS_DEFAULT_SCREEN=main/detectors.bob
```

## License

MIT — (c) UT-Battelle, LLC, Oak Ridge National Laboratory. See [LICENSE](../LICENSE).
Screens adapted from SNS facility tree for lab use.
