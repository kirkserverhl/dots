# Waybar

## Current Structure (Clean)
- `style.css` is a **symlink** to the active theme (e.g. `themes/matugen/style.css`)
- `colors/` holds color definitions (currently `matugen.css` driven by wallpaper)
- `themes/` contains visual style variants:
  - `matugen/` ← current daily driver
  - `dark/`, `light/`, `transparent/` ← placeholders
- Modules in `modules.json`
- Only essential scripts kept (mediaplayer.py + referenced ones)

## Theming Model
- Switch styles by updating the `style.css` symlink:
  ```bash
  ln -sf themes/dark/style.css style.css
  ```
- A future `scripts/themeswitcher.sh` will let you choose both **style** and **colors**.

## Launching
```bash
~/.config/waybar/scripts/launch.sh
```

The simplified launcher uses the symlinked `style.css`.
