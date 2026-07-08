# ADet/R3-15 — lab areaDetector Phoebus tree

Pinned to this deploy’s ADCore track (`ADCORE_TAG=master` ≈ [R3-15](https://github.com/areaDetector/ADCore/blob/master/RELEASE.md)).

Not a copy of the SNS facility `ADet/R3-11` tree. Minimum `common/` screens only;
Expert opens driver screens from `ADTimePix3_mpx3/.../op/bob` via Phoebus search paths.

| Path | Role |
|------|------|
| `common/color_camera_pva.bob` | PVA preview + acquire embeds |
| `common/subscreens/_ad_view_controls.bob` | Acquire; Expert → TimePix3 / MediPix3 |
| `common/subscreens/_ad_view_image_pva*.bob` | Image / profile widgets |

Source donor: SNS `ADet/R3-11/common` (macros/paths retargeted).
