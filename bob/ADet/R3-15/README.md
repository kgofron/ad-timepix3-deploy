# ADet/R3-15 — lab areaDetector Phoebus tree

Pinned to this deploy’s ADCore track (`ADCORE_TAG=master` ≈ [R3-15](https://github.com/areaDetector/ADCore/blob/master/RELEASE.md)).

Not a full SNS facility `ADet/R3-11` tree. Includes operator `common/` plus Expert support:

| Path | Role |
|------|------|
| `common/color_camera_pva.bob` | PVA preview + acquire embeds |
| `common/subscreens/_ad_view_controls.bob` | Acquire; Expert → `ADTimePix3/R1-0/...` |
| `common/subscreens/_ad_view_image_pva*.bob` | Image / profile widgets |
| `ADCore/R3-15/*.bob` | areaDetector screens from built ADCore `autoconvert` (install sync) |
| `ADTimePix3/R1-0/` | Expert tops + driver embeds (synced by `05-install-phoebus.sh`) |

Source donor: SNS `ADet/R3-11/common` (macros/paths retargeted).
