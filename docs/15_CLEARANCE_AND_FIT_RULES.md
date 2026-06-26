# 15 — Clearance and Fit Rules

## Purpose

Clearances are system-level concepts, not random offsets.

## Fit profiles

Examples:
- `fdm_tight`
- `fdm_normal`
- `fdm_loose`
- `resin_precise`
- `sliding_fit`
- `friction_fit`
- `tpu_soft_tight`
- `hard_shell_clearance`
- `glass_insert_clearance`

## Interaction types

- Pass-through hole.
- Button in hole.
- Sliding part.
- Friction fit.
- Snap fit.
- Lid lip.
- Glass insert.
- PCB standoff.
- Screw clearance.
- Heat insert hole.
- TPU stretch lip.
- Hard case shell.

## Profile fields

```json
{
  "id": "fdm_normal",
  "linearClearance": 0.3,
  "slidingClearance": 0.4,
  "holeExtraDiameter": 0.25,
  "glassEdgeClearance": 0.2,
  "buttonClearance": 0.35
}
```

## UI

Show simple presets first:
- Tight
- Normal
- Loose

Advanced:
- numeric overrides,
- per-feature overrides,
- material/process profile.

## Validation

Warn when:
- clearance too small for process,
- fit too loose for retention,
- TPU profile used on hard case,
- glass insert lacks adhesive/ledge area,
- moving button lacks enough gap.
