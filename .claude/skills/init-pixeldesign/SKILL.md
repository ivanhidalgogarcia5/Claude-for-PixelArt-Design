---
name: init-pixeldesign
description: Prepare this Claude Code session for pixel-art work in this repo. Checks and, where safe, installs what the workflow needs (Node, Aseprite, pixel-art skills, optional Aseprite MCP), loads the art rules, and tells the user when they can start asking for sprites. Use when the user runs /init-pixeldesign or asks to set up / check the pixel-art environment.
---

# /init-pixeldesign

Run these steps in order from the repo root, then answer in the user's language.

1. **Check.** Run `.\tools\doctor.ps1` (PowerShell). Each line is `OK`, `MISSING` (with the fix after `->`) or `OPTIONAL`.
2. **Install skills if missing.** If a `skill ...` line is `MISSING`, run `.\install.ps1` (no flags; installs the skills globally), then run the doctor again.
   Skills installed during the session only show up in the skill list after Claude Code restarts. Say so, but carry on: read them from `~/.claude/skills/<name>/` directly.
3. **Stop on missing programs.** If Node.js or Aseprite is `MISSING`, do not install them yourself. Tell the user exactly what to install (the doctor's fix text) and to run `/init-pixeldesign` again afterwards. Stop here.
4. **Aseprite MCP is optional.**
   - If it is `OPTIONAL`, mention in one line that `.\install.ps1 -Mcp` enables drawing live in Aseprite. Run it only if the user asks: it edits `~/.claude.json` and starts a background service.
   - If it is configured, call the `aseprite` MCP's `inspect_sprite` tool. If it answers, live drawing works; if not, the fix is to open Aseprite and run *File → Scripts → Connect AI MCP*.
5. **Load the art rules.** Invoke the `pixel-art-sprites` skill (or read its `SKILL.md` and `references/patterns.md` if it is not listed yet). Then read `CLAUDE.md` for this repo's conventions.
6. **Report.** Keep it short:
   - A status table with ✅ / ❌ / ➖ per item (Node, Aseprite, skills, test build, MCP).
   - When every required item is OK, say clearly that the session is ready: **"Listo: ya puedes pedirme sprites."**
   - Three example requests, e.g. "Haz un murciélago 16x16 con idle, move, attack y death en las 5 direcciones", "Dibuja 6 items de 12x12 para minerales", "Añade una animación hurt de 2 frames al slime".
