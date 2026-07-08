# ADCore Phoebus screens (R3-15 pin)

**Not stored in git.** Populated at install from the built ADCore checkout:

```text
${AREA_DETECTOR}/ADCore/ADApp/op/bob/autoconvert/*.bob
  → ${BOB_ROOT}/ADet/R3-15/ADCore/R3-15/
```

Synced by `install_adcore_phoebus_bob()` in `scripts/05-install-phoebus.sh` (after step 03).
Matches `ADCORE_TAG` in `config/versions.env` (default `master` ≈ forthcoming R3-15).

Expert panels (`MediPix3.bob`, `TimePix3.bob`) embed these via `pathADCore=ADet/R3-15/ADCore/R3-15`.
