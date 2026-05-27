# Wallpapers

This package manages your wallpaper collection so that `~/Pictures/Wallpapers` is always a symlink into the dotfiles repo.

## Why this structure?

The package uses this layout:

```
wallpapers/
└── Pictures/
    └── Wallpapers/     ← actual wallpaper files and folders
```

When you run `stow wallpapers`, GNU Stow creates:

```
~/Pictures/Wallpapers → ~/.dots/wallpapers/Pictures/Wallpapers
```

This guarantees that any script referencing `~/Pictures/Wallpapers/...` will continue to work without modification on new machines.

## Why not just put files directly in `wallpapers/`?

Many of your scripts (waypaper, hyprpaper, matugen templates, custom launchers, etc.) hardcode the path `~/Pictures/Wallpapers`. Keeping the exact same path via symlink is the simplest and most reliable solution.

## Populating the package

From your current live system:

```bash
mkdir -p ~/.dots/wallpapers/Pictures
rsync -a --delete ~/Pictures/Wallpapers/ ~/.dots/wallpapers/Pictures/Wallpapers/
```

From the old backup (if needed):

```bash
mkdir -p ~/.dots/wallpapers/Pictures
rsync -a --delete /path/to/old/Pictures/Wallpapers/ ~/.dots/wallpapers/Pictures/Wallpapers/
```

## Deployment

```bash
cd ~/.dots
./migrate.sh wallpapers
```

Or with dotctl:

```bash
dotctl install wallpapers
```

After deployment, `~/Pictures/Wallpapers` will be a symlink pointing into this repo.

## Notes

- Large wallpaper collections can make the repo big. Consider using Git LFS for very large files if you plan to push the repo publicly.
- Waypaper, matugen, and several custom scripts depend on this exact path.
