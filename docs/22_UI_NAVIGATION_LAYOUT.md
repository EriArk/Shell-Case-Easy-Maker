# 22 — UI Navigation and Layout

## UI identity

Viewport-first, icon-first, context-first.

The user dislikes large text blocks, huge text buttons, clutter, and too much information on screen.

## Main layout

```text
Top compact toolbar
Left icon rail
Center 3D viewport
Right contextual inspector
Bottom compact hints/status
```

## Always visible

- Viewport/model.
- Compact top bar.
- Left icon rail.
- View cube/orientation gizmo.

## Visible when needed

- Right inspector.
- Hints/warnings.
- Object tree.
- Export panel.
- Advanced tools.

## Left icon rail categories

- Enclosure.
- Components.
- Ports.
- Buttons.
- Mounts.
- Slots.
- Glass/inserts.
- Textures.
- Markings.
- Cases/grips.
- Supports.
- Advanced.

## Right inspector

Changes by selection:
- enclosure settings,
- component settings,
- feature settings,
- pattern settings,
- texture settings,
- case settings,
- parameter banks.

Simple settings first. Advanced collapsed.

## Bottom hints

Short, contextual:
- “Выберите грань для размещения кнопок.”
- “USB-C не доходит до стенки.”
- “4 стойки созданы по отверстиям платы.”

No long documentation in workspace.

## Camera controls

Default suggestion:
- Left click: select / drag object.
- Right drag or middle drag: orbit.
- Wheel: zoom.
- Shift + right/middle drag: pan.
- F: focus selection.
- Home: fit whole model.
- Double click: select/focus.
- View cube for standard views.

Add navigation presets:
- app default,
- Blender-like,
- Fusion-like,
- FreeCAD-like,
- touchpad-friendly.

## View cube

Required:
- top,
- front,
- left,
- right,
- back,
- bottom,
- isometric,
- home/fit.

## Animations

Allowed:
- sliding panels,
- hover previews,
- ghost generation preview,
- snap highlight,
- subtle futuristic motion.

Never sacrifice speed/clarity for animation.
