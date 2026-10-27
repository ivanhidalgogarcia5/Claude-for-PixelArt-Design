# Claude for PixelArt Design

Pixel art sprites are written as text grids and built into Aseprite files and game-ready exports.
Follow the `pixel-art-sprites` skill (installed by `install.ps1`) for art rules: readable silhouette first,
small locked palette with hue-shifted ramps, dark non-black outline, one consistent light source (top-left),
few strong frames, integer scaling only.

## Layout

```
sprites/<name>/
  src/palette.txt        K=rrggbb per line, shared by every animation of the sprite
  src/<anim>_<dir>.txt   "---- <ms>" before each frame, then one row per line, "." = transparent
  generate.js            optional: writes src/*.txt from poses (see sprites/slime)
  <name>.aseprite        built, one tag per src file
  export/                built: <name>_sheet.png+json (one row per tag), frames/*.png, *_x8.gif
tools/build.ps1          .\tools\build.ps1 [-Sprite <name>]  rebuilds .aseprite + export from src
```

## Rules

- The `.txt` files (or `generate.js`) are the source. Never hand-edit `<name>.aseprite` or `export/`: every build deletes and recreates them.
- Every frame of every animation of a sprite has the same canvas size; the build fails otherwise. Keep the ground line on the same row (feet/base on row 14 of 16) except for deliberate jumps.
- Directions: draw only S, SE, E, NE, N. W, SW and NW are horizontal flips of E, SE and NE, done by the user or the engine. Do not generate them.
- Standard animations and frame counts: idle 4, move 4, attack 4 (anticipation, action, impact, recovery), death 5 (ends on a held frame, play once).
- When several directions share poses, write a `generate.js` like `sprites/slime/generate.js` (poses without eyes + per-direction eyes) instead of hand-copying 60 grids; check its output by diffing against existing files before replacing them.
- After building, look at the result: render a scaled sheet with
  `aseprite -b sprites/<name>/<name>.aseprite --scale 6 --sheet-type rows --split-tags --sheet <tmp>.png` and read the PNG.
- `aseprite.exe` is a GUI app: from PowerShell call it with `Start-Process ... -Wait` (plain `&` does not wait).

## Live drawing (optional)

If the `aseprite` MCP is connected (`inspect_sprite` answers), you can sketch in the user's open Aseprite with
`create_sprite`, `draw_pixels`, `preview_sprite`. It cannot save: anything worth keeping goes into `src/*.txt`.
