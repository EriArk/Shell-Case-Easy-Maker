# 00 — Project Vision

## One sentence

A minimal, visual, Flutter desktop app for designing precise 3D-printable enclosures, devices, inserts, slots, grips, cases, and accessories around semantic internal components, powered by OpenCascade.

## What the app is

The app is a maker-focused enclosure constructor. It should help users build useful, attractive, printable mechanical parts without learning traditional CAD workflows.

The app should feel like:
- “place a board and generate the case around it,”
- “choose the screen opening and create a glass recess,”
- “draw a line and get a support rib,”
- “pick a button group pattern and tweak spacing with a knob,”
- “select the finished device and generate a TPU case.”

## What the app is not

The app is not:
- a generic CAD clone,
- a mesh sculpting tool,
- a Dune3D/FreeCAD/Blender fork,
- a program where beginners must know sketches, booleans, shell operations, or B-Rep terminology.

Advanced CAD tools can exist later, but default product identity is generator-first.

## Main workflows

### 1. Enclosure-first

For quick simple boxes:
1. Create enclosure.
2. Set dimensions, wall thickness, corner radius.
3. Choose lid type.
4. Add simple holes, bosses, ports, vents.
5. Export STL/STEP.

### 2. Component-first

The core differentiator:
1. Create or import internal component templates.
2. Define board outline, holes, switches, ports, buttons, keepouts, contact areas.
3. Place component inside enclosure.
4. Automatically generate mounts, cutouts, supports, button holes, port openings, and warnings.
5. Refine case visually.

### 3. Accessory/case-first from finished device

After device design:
1. Select device/body.
2. Create TPU/hard/hybrid case, bumper, grip, dock, stand, or module.
3. Select covered/open sides.
4. Auto-propagate button/port/screen cutouts and pseudo-buttons.
5. Add grips, bumpers, stands, hinges, slots, stylus holders, etc.

## Product personality

- Minimal.
- Visual.
- Icon-first.
- Parameter-knob-friendly.
- Friendly for beginners.
- Powerful enough for makers.
- Futuristic is acceptable if it stays clean and readable.

## Long-term promise

The app should become a specialized mechanical workflow for electronics and maker devices:
- board to enclosure,
- enclosure to accessory,
- accessory to export,
- all through semantic templates and reusable generators.
