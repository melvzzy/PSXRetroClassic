# Project conventions

- Work only in this repository. This is an independent Godot 4.6.3 Standard
  project using GDScript and Forward+. Do not copy code or assets from other projects.
- Keep the foundation minimal. Implement gameplay only when a future task
  explicitly requests it. No unsolicited managers, plugins, shaders or asset packs.
- Put scenes in `scenes/`, GDScript in `scripts/`, original visual assets in
  `assets/`, audio in `assets/audio/`, and checks in `tests/`. Add subfolders only
  when needed. Use snake_case filenames and PascalCase node/class names.
- Use typed GDScript where practical, Godot's default tab indentation and
  `res://` resource paths. Keep scene-specific behavior close to its scene.
- Preserve a runnable startup scene. After relevant changes run a headless
  editor import and bounded startup as described in `tests/README.md`.
  Report engine version, errors and any verification that could not be performed.
- Keep `.godot/` and export artifacts out of Git. Preserve Godot-generated
  `.uid` and asset `.import` sidecars when present; they are source metadata.
- Follow `assets/README.md` for scale, axes, materials and collision conventions.
  Add imported source files only when requested; keep them separate from reusable
  gameplay scenes. Replace visuals below existing model mounts, not controller nodes.
- Discrete gameplay actions belong to `_unhandled_input` while capture is active;
  queue physics work and clear requests on capture/focus transitions. Continuous
  movement uses Input Map state. Mouse release is not a world pause; if a later
  task adds tree pausing, release capture before pausing and require explicit recapture.
- Do not push, merge or create branches unless explicitly requested. Leave
  changes available for review. Summarize completed work and checks in German.
