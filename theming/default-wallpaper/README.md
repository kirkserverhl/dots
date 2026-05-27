# Default Wallpaper for New Machines

Drop **one image file** (jpg, png, webp, etc.) into this folder.

On a fresh install, after all configs are stowed, the `theming` post_stow hook will:

1. Run `matugen image <your-default-wallpaper>` to generate colors.
2. Run `waypaper --wallpaper <your-default-wallpaper>` to set it as the background.

This gives new machines (and VMs) a working color scheme and wallpaper immediately, without requiring you to manually set one first.

Recommended: Use a relatively small, fast-loading image as your "default" for quick VM testing and fresh installs.

Example:
- `default-wallpaper/default.jpg`
- `default-wallpaper/wallpaper.png`

Only the first matching image found will be used.