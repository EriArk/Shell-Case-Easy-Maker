# 27 — Research and References

Use this file to record research done by Codex/developers before implementation.

## Research requirements

Research before implementing:
- OCCT operations.
- Flutter 3D viewport/rendering.
- STEP/STL/DXF export.
- KiCad footprint/board import.
- Input mapping and Stream Deck/custom controllers.
- Licensing of libraries.
- Existing open-source UX references.

## License caution

Do not copy AGPL/GPL code into incompatible project code.

Ideas and algorithms can be studied. Implementation must be original unless license-compatible.

Be careful with:
- slicer infill code,
- KiCad libraries,
- external model libraries,
- controller SDKs.

## Potential reference areas

### CAD kernels / geometry
- OpenCascade documentation and examples.
- FreeCAD source as conceptual reference, respecting license.
- build123d/CadQuery as conceptual high-level API references.

### ECAD/MCAD
- KiCad file formats.
- KiCad StepUp workflow concepts.
- KiCad 3D model libraries.

### UI
- Fusion/Onshape for viewport conventions.
- Blender/FreeCAD for navigation preset references.
- Modern 3D editor UI patterns.

### Slicers
- PrusaSlicer/Cura/Slic3r only as conceptual references for patterns.
- Do not copy AGPL code unless project licensing intentionally allows it.

### Hardware input
- QMK/VIA keyboard/encoder mapping concepts.
- Stream Deck command concepts.
- HID/serial keyboard-emulated workflows.

## Research note format

Use `templates/RESEARCH_NOTE_TEMPLATE.md`.

---

## 2026-06-30 - OCCT front-wall glass ledge window

## Question

How should front-wall `glass_recess` features use semantic `ledgeWidth` to
create a real panel window while staying one editable feature?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeBox.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepFilletAPI_MakeFillet.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  front-wall USB-C/button through-cuts, front glass shallow recesses, top-lid
  glass windows, preview surface mapping, and generated-output metrics.
- `docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md` for the recess/window/ledge
  product terminology.

## Findings

- The front-wall path can mirror the top-lid ledge/window behavior while using
  the wall-depth Y axis instead of the lid-thickness Z axis.
- The outer recess remains a shallow seat; the inner window is a second rounded
  box cut through the wall using `width - ledgeWidth * 2` and
  `height - ledgeWidth * 2`.
- Preview surface mapping should continue to use the original semantic feature
  id, such as `front_glass_recess`, for both the seat and inner window faces.
- Generated metrics can distinguish the front glass window operation without
  exposing a separate editable object.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

For front-wall `glass_recess` intents, cut the shallow outer recess first, then
cut a rounded through-window from semantic `ledgeWidth`, leaving a support
ledge in the wall. Report `nativeGlassWindowCount` and
`nativeGlassWindowFilletedEdgeCount`, and keep preview mapping keyed by the
original semantic feature id.

## Follow-up tasks

- Add protected islands inside glass recesses for buttons or screen features.
- Add DXF/acrylic contour export from the same semantic recess parameters.
- Add richer panel opening presets after screen/window feature semantics are
  explicit.

---

## 2026-06-30 - OCCT generated top lid glass ledge window

## Question

How should semantic `ledgeWidth` become generated support ledge geometry for a
top-lid glass recess without splitting the editable feature into separate
pocket/window solids?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeBox.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepFilletAPI_MakeFillet.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  generated top-lid glass recesses, lid button through-holes, preview surface
  mapping, and generated-output metrics.
- `docs/13_PANEL_RECESS_INSERT_GLASS_SYSTEM.md` for the product distinction
  between recess, insert, window, and ledge/lip/bezel.

## Findings

- `ledgeWidth` already exists in the semantic `glass_recess` feature and Dart
  validation already treats it as the border around an inner window.
- The generated top lid can keep the existing shallow outer recess cut, then
  apply a second rounded box cut through the lid plate using
  `width - ledgeWidth * 2` and `height - ledgeWidth * 2`.
- The inner window radius should be derived from the outer corner radius minus
  the ledge width, then clamped to the inner window size.
- The window should be reported with generated-output metrics, but it should
  not become a separate editable feature or raw topology selection target.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

For top-lid `glass_recess` intents, cut the shallow outer recess first, then
cut an inner rounded through-window from semantic `ledgeWidth`, leaving a
support ledge in the generated lid. Report
`nativeGeneratedLidGlassWindowCount` and
`nativeGeneratedLidGlassWindowFilletedEdgeCount` while keeping preview mapping
keyed by the original semantic feature id such as `top_lid_glass_recess`.

## Follow-up tasks

- Add protected islands inside glass recesses for buttons or screen features.
- Add DXF/acrylic contour export from the same semantic recess parameters.

---

## 2026-06-30 - OCCT generated top lid glass recess

## Question

How should semantic top-lid glass recesses become shallow generated lid
features without turning the lid into editable B-Rep state?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeBox.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepFilletAPI_MakeFillet.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  front-wall glass recesses, generated lid plate assembly, generated lid
  button cuts, preview surface mapping, and generated-output metrics.

## Findings

- A top-lid recess can reuse the rounded box tool pattern from front-wall glass
  recesses, but its cutting axis is Z and its depth is clamped to remain a
  shallow lid feature.
- `BRepFilletAPI_MakeFillet` supports adding fillets by edge and radius, so
  the recess tool can fillet the vertical rounded-rectangle edges before the
  boolean cut.
- `BRepAlgoAPI_Cut` is the appropriate boolean subtraction path already used
  for body feature cuts and generated lid screw/button holes.
- Routing by semantic `targetSurface` keeps front-wall recesses on the body
  path and top-lid recesses on the generated lid path.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

Parse `glass_recess` intents targeting `main_enclosure.top_lid.outer`,
validate their face-local size/depth/radius against the generated lid safe
area, cut a shallow rounded rectangular tool into the generated lid plate, and
map resulting preview triangles by semantic feature id such as
`top_lid_glass_recess`. Report
`nativeGeneratedLidFeatureCutCount`,
`nativeGeneratedLidGlassRecessCount`, and
`nativeGeneratedLidGlassRecessFilletedEdgeCount`.

## Follow-up tasks

- Add protected islands, retaining lips, and glass/acrylic contour export once
  insert semantics are explicit.
- Add real lid/body assembly semantics before exposing generated lid parts as
  independently inspectable objects.

---

## 2026-06-30 - OCCT generated top lid button cutouts

## Question

How should semantic top-lid button groups become generated lid holes without
flattening the group into editable per-hole solids?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  front-wall button cutouts, generated lid plate assembly, screw-hole cuts,
  preview surface mapping, and generated-output metrics.

## Findings

- `BRepPrimAPI_MakeCylinder` already supports cylinder tools with an explicit
  `gp_Ax2`, so the same primitive used for front-wall buttons can cut top-lid
  holes by switching the axis to Z.
- Top-lid button groups should be routed by `targetSurface` to the generated
  lid branch instead of the body feature-cut branch.
- The editable group should remain one semantic `button_group`; generated
  holes are disposable B-Rep output and preview ranges can still be keyed by
  the group id.
- Counting generated-lid feature cuts separately from body cuts keeps smoke
  metrics readable while preserving the existing body feature metrics.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

Parse `button_group` intents targeting `main_enclosure.top_lid.outer`, validate
their positions against the lid safe area, and cut vertical cylinder tools
through the generated top lid plate. Report
`nativeGeneratedLidFeatureCutCount`,
`nativeGeneratedLidButtonGroupCount`, and
`nativeGeneratedLidButtonCutoutCount`, and map preview triangles by the
semantic group id such as `top_lid_buttons`.

## Update - first native button rings

M85 reuses the same OCCT primitive/Boolean family for first-pass button
rings/bezels. The worker builds an annular ring by cutting an inner
`BRepPrimAPI_MakeCylinder` tool out of an outer cylinder, validates the ring
with `BRepCheck_Analyzer`, then fuses it to the already-cut body or generated
lid with `BRepAlgoAPI_Fuse`.

The ring dimensions use semantic `button_group.itemPrototype` parameters:
`ringWidth` defaults to `1.2 mm` and `ringProtrusion` defaults to `0.45 mm`.
The inner clearance and shallow overlap remain generator-owned implementation
details for robust Boolean/fuse operations. Preview classification uses the
same radius helpers as generation so ring faces map back to `front_buttons` or
`top_lid_buttons` instead of becoming separate editable objects.

Smoke metrics now include `nativeButtonRingCount` and
`nativeGeneratedLidButtonRingCount`; the sample reports 2 front-wall rings and
4 generated top-lid rings. No GPL/AGPL code or external project snippets were
copied; this slice uses project-local OCCT headers and existing worker
patterns.

## Update - first native button cap/stem previews

M87 keeps using the same OCCT primitive family already researched for button
holes and rings. The worker builds first-pass cap and stem preview solids with
`BRepPrimAPI_MakeCylinder`, stores them in the preview compound with
`BRep_Builder`, and validates the resulting compound with `BRepCheck_Analyzer`.
The caps/stems are deliberately not fused into the body or generated lid,
because button plungers are separate generated parts in the product model.

The cap/stem dimensions are semantic `button_group.itemPrototype` parameters:
`capDiameter`, `capHeight`, `stemDiameter`, and `stemDepth`. Native validation
requires plunger caps and stems to fit inside the button cutout and target
surface safe area. Preview classification maps cap/stem faces back to the
original button group id, so selection still behaves like one semantic group.

Smoke metrics now include `nativeButtonCapCount`, `nativeButtonStemCount`,
`nativeGeneratedLidButtonCapCount`, and
`nativeGeneratedLidButtonStemCount`; the sample reports 2 front-wall caps/stems
and 4 generated top-lid caps/stems. No GPL/AGPL code or external project
snippets were copied.

## Update - semantic plunger travel/clearance controls

M90 adds semantic `button_group.itemPrototype` parameters for `travel`,
`switchClearance`, and `guideClearance`. This slice does not add a new OCCT
operation or copy external geometry code; it extends the editable semantic
schema, Flutter inspector/dialog controls, geometry request serialization, and
project-level validation before guide-wall or travel-stop B-Rep is generated.

The validator checks plunger-mode groups only. Cutout-mode button groups stay
quiet. For plungers, `travel + switchClearance` must fit within `stemDepth`
with a small generator reserve, and `stemDiameter + guideClearance * 2` must
fit inside the button opening. Very tight or very loose guide clearance is
reported as a warning so the user can still continue while the real printable
guide-wall generator is pending.

## Follow-up tasks

- Add guide walls, travel stops, anti-wobble geometry, and richer
  switch-contact/collision validation for real printable plungers.
- Expand ring/bezel/cap style parameters later if caps/plungers need shape,
  chamfer, or texture controls.
- Add lid/body assembly semantics before exposing generated lid parts as
  independently inspectable objects.

---

## 2026-06-30 - OCCT generated top lid fit preview

## Question

How should the generated top lid be positioned so the body seat and lid lip are
readable without pretending the project has editable assembly state?

## Sources checked

- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  generated top lid plate, locating lip, screw holes, body lid seat, preview
  assembly, bounds metrics, and semantic preview mappings.
- Previous OCCT notes in this file for generated lid plate compounds, screw
  holes, locating lip, and body-side lid seat.

## Findings

- The first lid preview does not need a new OCCT operation. The generated lid
  plate, lip, and screw-hole tools can use the same coordinate system with a
  smaller `preview_gap`.
- Decoupling lip height from the old exploded gap keeps the mating detail
  stable while the display position moves closer to the body.
- A small inspection gap is preferable to a fully closed preview because the
  user can still orbit and see the relationship between the generated lip and
  generated body seat.
- Reporting `nativeGeneratedLidFitPreviewGap` makes the preview positioning
  deterministic and testable.

## License / compatibility notes

- No new dependency or external source code was used.
- Existing OCCT usage remains through the project-local vcpkg dependency.

## Decision

Position the generated top lid with a first-pass fit-preview gap derived from
wall thickness. For the sample enclosure this gap is `0.35 mm`, giving preview
bounds of `[-60, -35, 0]` to `[60, 35, 30.35]`. Keep this as disposable
generated preview output; do not save lid assembly state, topology IDs, or
triangle IDs in `ProjectModel`.

## Follow-up tasks

- Add explicit lid/body assembly semantics before making the lid truly closed
  or independently selectable as a generated part.
- Add top-lid feature targeting once lid/body semantics can distinguish body
  wall features from lid features.
- Add printable chamfers/fillets after the fit relationship is stable.

---

## 2026-06-30 - OCCT generated top lid body seat

## Question

How should the first native body-side lid seat be generated so it matches the
generated lid lip without introducing editable groove solids or raw topology
state?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeBox.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  shell/cavity generation, generated lid lip sizing, semantic preview surface
  ranges, and `BRepCheck_Analyzer` validation.

## Findings

- A shallow body-side seat can be modeled as generated subtraction from the
  top-open shell, using four rectangular tool solids that nibble the inner top
  wall band.
- `BRepPrimAPI_MakeBox` supports axis-aligned rectangular tool solids from two
  corner points or from a corner plus dimensions, which is enough for this
  first wall-band seat.
- `BRepAlgoAPI_Cut` is appropriate because the seat is disposable generated
  B-Rep output and the editable project stores only semantic lid metadata.
- The seat dimensions can be derived conservatively from wall thickness,
  generated lip width, lip clearance, and lip height. A small overcut through
  the top band avoids coplanar sliver faces at the rim.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

Cut a first-pass body-side top lid seat from the native shell before assembling
the generated lid preview. Key preview triangles by
`main_enclosure.generated_top_lid_seat`, emit `nativeGeneratedLidSeatCount`,
and keep the seat as generated output derived from `Enclosure.lid`.

## Follow-up tasks

- Lower or position the generated lid into a clearer fit state once the
  preview assembly should stop floating above the body.
- Add configurable lid fit clearance and edge chamfers/fillets after the basic
  lip/seat relationship is stable.
- Keep top-lid feature cuts blocked until lid/body targeting is explicit.

---

## 2026-06-30 - OCCT generated top lid locating lip

## Question

How should the first native lid mating detail add an underside locating lip
without making generated lid geometry editable project state?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Fuse.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  rounded box generation, generated lid plate assembly, and semantic preview
  surface ranges.

## Findings

- A locating lip can be represented as generated B-Rep by building a rounded
  outer lip body and subtracting a smaller rounded inner tool to make a ring.
- `BRepAlgoAPI_Cut` is suitable for the ring operation because the lip is
  disposable generated geometry, not source project data.
- `BRepAlgoAPI_Fuse` can join the generated ring into the generated lid plate
  with a small overlap into the plate underside.
- The lip can be sized from enclosure wall thickness, inner opening dimensions,
  and a small clearance while keeping all values derived from semantic
  enclosure/lid data.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

Generate a first-pass underside locating lip as a rounded rectangular ring,
fuse it into the generated top lid plate, and map its preview triangles by
`main_enclosure.generated_top_lid_locating_lip`. Keep the lip disposable and do
not save generated B-Rep, topology IDs, or triangle IDs into the project model.

## Follow-up tasks

- Add a true body-side groove/seat and configurable fit clearance after the
  preview lid becomes a real mating lid/body split.
- Add lid-specific fillets/chamfers once the basic mating workflow is stable.

---

## 2026-06-30 - OCCT generated top lid screw clearance holes

## Question

How should the native preview plate get screw clearance holes aligned with the
generated screw bosses without adding editable per-hole CAD objects?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Cut.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  lid screw boss generation, generated lid preview assembly, and semantic
  surface range mapping.

## Findings

- `BRepAlgoAPI_Cut` is the existing OCCT boolean subtraction path used by the
  worker for disposable generated geometry.
- `BRepPrimAPI_MakeCylinder(gp_Ax2, radius, height)` can create a complete
  vertical tool cylinder through the generated lid plate.
- The generated lid screw boss positions already provide deterministic XY
  centers for matching lid holes.
- A small Z overcut through the plate makes each tool robust without changing
  semantic project data.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

Cut generated screw clearance holes through the preview lid plate from the
same semantic lid screw boss positions. Report
`nativeGeneratedLidScrewHoleCount` and map the preview ranges by
`main_enclosure.generated_top_lid_screw_holes`. Do not save generated hole
solids, OCCT topology IDs, or triangle IDs in the editable project model.

## Follow-up tasks

- Add lid screw hole sizing parameters when lid/boss profiles become
  user-facing.
- Add mating lip/groove and screw-head/countersink options after the real
  lid/body split exists.

---

## 2026-06-30 - OCCT preview compound for generated lid plate

## Question

How should the first native top-lid preview show a separate generated plate
without making generated geometry editable project state?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRep_Builder.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/TopoDS_Compound.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/TopoDS_Builder.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  rounded box generation, shell/cavity generation, preview meshing, and
  semantic surface range mapping.

## Findings

- `TopoDS_Compound` can hold multiple generated shapes while keeping them as
  separate compound members.
- `BRep_Builder` inherits `TopoDS_Builder`, whose `MakeCompound` creates an
  empty compound and `Add` can add any shape to a compound.
- A compound is suitable for preview meshing a body plus a generated lid plate
  before the real mating lid/body split exists.
- The compound should remain generated B-Rep output. It must not introduce
  editable lid solids, raw topology IDs, or stable triangle IDs into the
  semantic project model.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

Use `BRep_Builder` and `TopoDS_Compound` to create a native preview assembly
from the cut body plus a generated `top_screw_lid` preview plate. Key preview
ranges by semantic IDs such as `main_enclosure.generated_top_lid`, not by OCCT
topology.

## Follow-up tasks

- Turn the preview lid plate into a real mating lid/body split.
- Add top-lid feature cuts only after lid/body targeting is explicit.

---

## 2026-06-30 - OCCT cylindrical button cutout tools

## Question

How should the first native button-group slice build simple circular front-wall
cutouts without exposing low-level CAD operations in the default UX?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/gp_Ax2.hxx`
- Existing native worker slices in `occt_worker/native/src/occt_main.cpp` for
  `BRepPrimAPI_MakeBox`, `BRepAlgoAPI_Cut`, and deterministic preview meshing.

## Findings

- `BRepPrimAPI_MakeCylinder` can build a complete cylinder from a `gp_Ax2`,
  radius, and height.
- The cylinder height is along the local Z/main direction of the `gp_Ax2`.
- `gp_Ax2` provides an origin plus orthogonal directions, so a front-wall cut
  can place the cylinder origin just outside the front face and set the main
  direction to `+Y`.
- The resulting cylinder is suitable as a disposable boolean cut tool. It should
  not become editable project state.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Useful implementation references

- Use `BRepPrimAPI_MakeCylinder(gp_Ax2(origin, gp_Dir(0, 1, 0)), radius, height)`
  for front-wall circular button cut tools.
- Continue validating generated shapes with `BRepCheck_Analyzer`.
- Keep preview mesh triangle ranges disposable and keyed by the semantic
  `button_group` id, not by raw topology or per-triangle IDs.

## Decision

Implement first native button cutouts as controlled semantic generator output
for front-wall `button_group` feature intents. A group stays one editable
semantic object; native button holes are generated B-Rep preview output.

## Follow-up tasks

- Add top-lid button cutouts after the lid/body split exists.

---

## 2026-06-30 - OCCT standoff boss fuse tools

## Question

How should the first native standoff-mount slice generate simple printable
mounting bosses without turning mounts into independent editable solids?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Fuse.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`
- Existing native worker boolean cut/fuse-adjacent patterns in
  `occt_worker/native/src/occt_main.cpp`.

## Findings

- `BRepAlgoAPI_Fuse` provides a boolean union between a base shape and a tool
  shape.
- `BRepPrimAPI_MakeCylinder(gp_Ax2, radius, height)` is suitable for both the
  outer standoff boss and the central hole tool.
- A tiny overlap into the bottom floor makes the boss and enclosure volumes
  intersect before fusion, which is more robust than relying on coplanar touch.
- Cutting the hole from the boss before fusing it to the shell creates a blind
  screw pilot instead of cutting a through-hole in the enclosure floor.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

Implement first native bottom standoffs as generated B-Rep bosses from
`standoff_mounts` feature-group item positions. The editable project still
stores one semantic group with diameter, hole diameter, height, and source
mounting-hole metadata.

## Follow-up tasks

- Add fillet/chamfer polish for standoff bases after the first native boss path
  is stable.
- Add top-lid or side-wall mount variants only after the body/lid split and
  target-surface mapping are richer.

---

## 2026-06-30 - OCCT top screw lid boss generation

## Question

How should the first native top-screw-lid slice add simple lid screw bosses
without creating editable CAD solids or exposing raw boolean operations?

## Sources checked

- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepAlgoAPI_Fuse.hxx`
- Local OCCT 8.0 header:
  `occt_worker/native/vcpkg_installed/x64-windows/include/opencascade/BRepPrimAPI_MakeCylinder.hxx`
- Existing native worker boss/fuse path for `standoff_mounts` in
  `occt_worker/native/src/occt_main.cpp`.

## Findings

- The same cylinder-plus-pilot-hole approach used for standoff bosses can
  generate simple screw bosses from enclosure lid metadata.
- Boss positions can be derived from the inner enclosure rectangle with a fixed
  inset, avoiding new editable per-boss project objects.
- Fusing boss shapes into the top-open shell before feature cutouts keeps the
  generated B-Rep deterministic and still disposable.

## License / compatibility notes

- OCCT headers are from the project-local vcpkg dependency. They are LGPL 2.1
  with OCCT exception / commercial alternative, matching the existing OCCT
  dependency evaluation.
- No external project code was copied.

## Decision

For `top_screw_lid`, generate four default cylindrical screw bosses with pilot
holes as native B-Rep output keyed to the enclosure semantic lid spec. Do not
add separate editable boss objects to the project model.

## Follow-up tasks

- Add user-facing screw boss parameters after the lid/body workflow is richer.
- Add fillets/chamfers and screw-size profiles after the generated boss path is
  stable.
- Add richer button geometry later: bevels, caps, support rings, and clearance
  profiles.

---

## 2026-06-27 — Flutter GitHub Actions CI

## Question

What minimal GitHub Actions workflow should validate the current Flutter desktop project without starting platform packaging too early?

## Sources checked

- Flutter documentation: [Continuous delivery with Flutter](https://docs.flutter.dev/deployment/cd)
- GitHub official action: [actions/checkout](https://github.com/actions/checkout)
- Flutter setup action: [subosito/flutter-action](https://github.com/subosito/flutter-action)

## Findings

- Flutter's deployment documentation lists GitHub Actions as an available integration path for CI/CD.
- `actions/checkout` is the official GitHub checkout action. Its README now documents `actions/checkout@v7`; the repository is MIT licensed.
- `subosito/flutter-action@v2` is a maintained Flutter setup action for Linux, Windows, and macOS runners. It supports explicit Flutter versions, stable channel selection, and cache options. The repository is MIT licensed and had a latest release in 2026.
- The current project was created with Flutter `3.44.2`, so CI pins that version for deterministic validation instead of floating on latest stable.

## License / compatibility notes

- `actions/checkout`: MIT license.
- `subosito/flutter-action`: MIT license.
- No source code from either project was copied into this repository.

## Useful implementation references

- Use `actions/checkout@v7`.
- Use `subosito/flutter-action@v2` with `channel: stable`, `flutter-version: "3.44.2"`, `cache: true`, and `pub-cache: true`.
- Run `flutter pub get`, `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, and `flutter test`.

## Decision

Add a lightweight `Flutter CI` workflow for push and pull request events on `main`. It validates formatting, static analysis, and tests only. Desktop build jobs will be added later when packaging dependencies and platform-specific build policies are ready.

## Follow-up tasks

- Add platform build jobs later for Windows, Linux, and macOS packaging.
- Decide whether to keep Flutter pinned in CI or adopt a `.fvmrc`/pubspec-based version source.

---

## 2026-06-27 — Flutter viewport MVP approach

## Question

What should the first interactive viewport use before real OCCT preview mesh
integration exists?

## Sources checked

- Flutter docs: [Taps, drags, and other gestures](https://docs.flutter.dev/ui/interactivity/gestures)
- Flutter API: [InteractiveViewer](https://api.flutter.dev/flutter/widgets/InteractiveViewer-class.html)
- Flutter API: [CustomPainter](https://api.flutter.dev/flutter/rendering/CustomPainter-class.html)
- Flutter API: [PointerScrollEvent](https://api.flutter.dev/flutter/gestures/PointerScrollEvent-class.html)
- Flutter blog: [Getting started with Flutter GPU](https://blog.flutter.dev/getting-started-with-flutter-gpu-f33d497b7c11)
- Pub.dev: [flutter_scene](https://pub.dev/packages/flutter_scene)
- Pub.dev: [three_js](https://pub.dev/packages/three_js)
- Pub.dev: [flutter_3d_controller](https://pub.dev/packages/flutter_3d_controller)

## Findings

- Flutter separates raw pointer events from higher-level gestures, so a desktop
  viewport can use raw pointer movement for CAD-like mouse button behavior while
  keeping semantic actions in app code.
- `InteractiveViewer` gives pan/zoom for child widgets, but the current app
  needs orbit, right/middle-button pan, wheel zoom, semantic hit-test routing,
  and later mesh-backed selection. A small controller is more explicit for this
  first slice.
- `CustomPainter` is appropriate for the current mock preview and supports
  repaint/hit-test patterns without adding a renderer dependency yet.
- `flutter_scene` is promising and MIT licensed, but it currently depends on
  Flutter GPU / Impeller preview flow. That is too early for the default stable
  Windows workflow.
- `three_js` is MIT licensed and supports desktop targets, but it introduces a
  rendering stack before the geometry/preview mesh protocol is defined.
- `flutter_3d_controller` is MIT licensed and useful for loading general 3D
  assets, but it is model-viewer oriented and not a precise CAD preview path.

## License / compatibility notes

- `flutter_scene`: MIT license.
- `three_js`: MIT license.
- `flutter_3d_controller`: MIT license.
- No package source code was copied.
- No new dependency was added in this chunk.

## Useful implementation references

- Use `Listener`/pointer events for desktop drag button handling.
- Use `PointerScrollEvent` for mouse wheel zoom.
- Keep viewport state separate from `GeometryService` and project data.
- Keep selection hit results semantic: object IDs, surface IDs, feature IDs.

## Decision

Implement M4 with the existing Flutter canvas stack:
- `ViewportController` for orbit, pan, zoom, fit, selection ID, and ghost
  preview state.
- `MockViewportLayout` shared by painter and hit tester.
- `MockViewportHitTester` returning semantic IDs only.

Defer a real 3D rendering dependency until the preview mesh protocol and OCCT
worker output are defined.

## Follow-up tasks

- Re-evaluate `three_js`, `flutter_scene`, or a lower-level renderer after the
  `GeometryService` preview mesh protocol exists.
- Add viewport hit testing against generated preview mesh using semantic face
  mappings, not raw triangle IDs.

---

## 2026-06-27 — OCCT first geometry slice

## Question

What is the safest first OCCT integration boundary for generated enclosure
geometry?

## Sources checked

- Open CASCADE official overview:
  [Introduction](https://dev.opencascade.org/doc/overview/html/)
- Open CASCADE official build docs:
  [Build OCCT](https://dev.opencascade.org/doc/overview/html/build_upgrade__building_occt.html)
- Open CASCADE official licensing page:
  [Licensing](https://dev.opencascade.org/resources/licensing)
- Open CASCADE reference:
  [BRepPrimAPI_MakeBox](https://dev.opencascade.org/doc/refman/html/class_b_rep_prim_a_p_i___make_box.html)
- Open CASCADE user guide:
  [Modeling Algorithms - Fillets and Chamfers](https://dev.opencascade.org/doc/overview/html/occt_user_guides__modeling_algos.html)
- Open CASCADE user guide:
  [Mesh](https://dev.opencascade.org/doc/overview/html/occt_user_guides__mesh.html)
- Open CASCADE reference:
  [STEPControl_Writer](https://dev.opencascade.org/doc/refman/html/class_s_t_e_p_control___writer.html)

## Findings

- OCCT is a C++ library platform for geometric modeling, CAD data exchange, and
  visualization. The app should keep it behind a worker/adapter boundary.
- The current official build path is CMake-based. The docs also describe a
  vcpkg-based quick start for provisioning third-party dependencies.
- OCCT 6.7.0+ is licensed as LGPL 2.1 with the Open CASCADE additional
  exception. Bundling and license notices need deliberate packaging work later.
- `BRepPrimAPI_MakeBox` is the obvious first solid primitive for a rectangular
  enclosure body and exposes named box faces that can be mapped to semantic
  surface IDs.
- OCCT filleting uses `BRepFilletAPI_MakeFillet`: construct with a shape, add
  edge/radius descriptions, then build the result.
- `BRepMesh_IncrementalMesh` is the standard first meshing path. Its key control
  settings are linear and angular deflection, which should be explicit and
  deterministic.
- `STEPControl_Writer` is the later STEP export path after B-Rep generation is
  stable.

## License / compatibility notes

- OCCT is not a dependency in this repository yet.
- No OCCT source code was copied.
- Before distributing binaries, add license files/notices and document whether
  OCCT is dynamically linked, bundled, or installed externally.

## Decision

M5 should not compile OCCT yet. It should define the protocol boundary first:
- Flutter sends semantic project JSON through `GeometryRequest`.
- Worker/adapter returns `GeometryResponse`.
- Preview mesh is disposable output.
- Surface selection maps through semantic IDs.
- Raw OCCT topology IDs stay inside the worker.

## Follow-up tasks

- Decide Windows dev distribution path: source CMake + vcpkg, prebuilt package,
  or project-managed binary cache.
- Add the first `occt_worker` executable after the protocol is stable.
- Add deterministic geometry tests around known dimensions and warning outputs.
- Add license-notice packaging before distributing an OCCT-backed app.

---

## 2026-06-27 — Native project file dialogs

## Question

What dependency should provide desktop open/save file dialogs for project JSON
files?

## Sources checked

- pub.dev package page:
  [file_selector](https://pub.dev/packages/file_selector)
- pub.dev license/version metadata:
  [file_selector license metadata](https://pub.dev/packages/file_selector/versions/0.9.5/license)

## Findings

- `file_selector` is published by `flutter.dev`.
- The package purpose matches this slice: native file selection UI for opening,
  saving, and directory selection.
- The pub.dev package metadata lists Android, iOS, Linux, macOS, Web, and
  Windows support; Windows support is required for the manual build.
- The package metadata lists `BSD-3-Clause`.
- The repository should keep file dialogs behind a small service seam so tests
  can use fakes and project JSON logic can remain independent of plugin APIs.

## Decision

Use `file_selector` for native project open/save dialogs.

`ProjectFileService` stays responsible for JSON encode/decode/read/write.
`ProjectFileDialogService` is responsible only for choosing a file path.

## Follow-up tasks

- Add unsaved-changes prompts before opening another project.
- Add "Save As" when the command system grows beyond the compact toolbar.
- Bundle dependency license notices during packaging work.

---

## 2026-06-29 - OCCT Windows dependency path

## Question

What Windows dependency path should the native worker use before the first real
OCCT-generated enclosure slice?

## Sources checked

- OpenCascade official documentation: [Build OCCT](https://dev.opencascade.org/doc/overview/html/build_upgrade__building_occt.html)
- OpenCascade official licensing page: [Licensing](https://dev.opencascade.org/resources/licensing)
- vcpkg package page: [opencascade](https://vcpkg.io/en/package/opencascade.html)
- OpenCascade forum: [OCCT VCPKG Extended Package Support Now Available](https://dev.opencascade.org/content/occt-vcpkg-extended-package-support-now-available)

## Findings

- OCCT's official build path is CMake-based and requires C++17. Windows support
  expects Visual Studio 2019 or later, with Visual Studio 2022 preferred.
- Official OCCT docs call vcpkg the fastest path to a working OCCT build for
  dependency provisioning.
- The public vcpkg package page lists `opencascade` as available and currently
  exposes version `8.0.0#1`.
- OCCT 6.7.0 and later are LGPL 2.1 with the Open CASCADE additional exception.
- Some OCCT developer tools such as DRAWEXE may need manual source/CMake paths,
  but the first app worker slice does not need DRAWEXE.

## License / compatibility notes

- Do not vendor OCCT source into this repository.
- Do not copy GPL/AGPL application code while studying OCCT integrations.
- Before distributing OCCT-backed binaries, add third-party license notices and
  document bundled DLLs.

## Useful implementation references

- Full task-specific note: `docs/35_OCCT_WINDOWS_DEPENDENCY_PLAN.md`.
- Readiness command:
  `powershell -NoProfile -ExecutionPolicy Bypass -File tools\check_occt_windows_readiness.ps1`

## Decision

Use vcpkg as the first Windows developer acquisition path, but keep normal
Flutter builds and the current native stub independent of OCCT. Add a separate
opt-in OCCT-linked native target only after local readiness is true.

## Follow-up tasks

- Install/configure vcpkg locally or set `OpenCASCADE_DIR` / `CASROOT`.
- Add an opt-in OCCT CMake target after readiness is true.
- Keep generated B-Rep/mesh disposable and behind the worker protocol.

---

## 2026-06-29 - OCCT shell/cavity generation

## Question

What OCCT operation should produce the first editable-enclosure body shell while
keeping Flutter behind the `GeometryService` boundary?

## Sources checked

- OpenCascade reference:
  [BRepOffsetAPI_MakeThickSolid](https://dev.opencascade.org/doc/refman/html/class_b_rep_offset_a_p_i___make_thick_solid.html)
- OpenCascade package reference:
  [BRepOffsetAPI](https://dev.opencascade.org/doc/refman/html/package_brepoffsetapi.html)
- OpenCascade reference:
  [BRepAlgoAPI_Cut](https://dev.opencascade.org/doc/refman/html/class_b_rep_algo_a_p_i___cut.html)

## Findings

- `BRepOffsetAPI_MakeThickSolid` is intended for hollowed solids from an initial
  solid plus faces to remove. In local experiments, the `GeomAbs_Arc` join
  produced the expected visible cavity but failed the first strict
  `BRepCheck_Analyzer` pass; `GeomAbs_Intersection` passed validity but kept
  the sample metrics equivalent to the old solid preview.
- `BRepAlgoAPI_Cut` is the official Boolean subtraction API. A semantic
  generator can build one rounded internal cavity tool from `wallThickness` and
  cut it from the rounded outer body without exposing Boolean operations in the
  default UI.
- The Boolean-cavity result for the sample enclosure passes
  `BRepCheck_Analyzer`, meshes with status `0`, and produces deterministic
  shell metrics.

## Decision

Use a generator-owned `BRepAlgoAPI_Cut` for the first top-open shell/cavity
slice:
- outer rounded box comes from semantic enclosure size/corner radius;
- inner rounded cavity tool comes from semantic wall thickness;
- top opening is implicit because the cavity tool starts above the bottom floor
  and extends through the top;
- Flutter receives only disposable preview mesh data, semantic surface ranges,
  and metrics.

## Follow-up tasks

- Revisit `BRepOffsetAPI_MakeThickSolid` for later lid/body variants if it gives
  cleaner wall construction for less-rounded or multi-part bodies.
- Add feature-intent cuts for USB-C/glass/buttons against the generated shell.
- Add STEP/STL export only after native B-Rep validation and license notices are
  ready.

## Update - first feature-intent cut

M70 reuses the generator-owned `BRepAlgoAPI_Cut` path for the first native
USB-C feature intent. The worker builds a rounded rectangular cut tool from
semantic USB-C dimensions and optional `placement.surfacePosition`, cuts only
the supported front-wall surface slice, and reports unsupported button/glass
intents as ignored metrics instead of exposing Boolean tools in the default UI.
