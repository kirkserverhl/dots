# Unified Config Package

This is the main "everything under ~/.config" package.

## Philosophy (user preference)

Instead of having dozens of tiny individual packages (waybar/, dunst/, rofi/, etc.), we keep one big `config/.config/` directory.

### Benefits
- Extremely simple: drop any new app's config folder in here and it will be stowed.
- Easy to browse and edit everything in one place.
- Matches how the user previously managed things in the old setup.

### How it works

When you run:

```bash
stow config
# or
./migrate.sh config
```

It will create symlinks for everything under `~/.config/` (waybar/, hypr/, dunst/, kitty/, nvim/, etc.).

## Notes

- Some packages still have their own small `meta/manifest.sh` (for dependency tracking and package installation lists).
- Heavy caches, logs, and machine-specific state have been excluded.
- For special cases that don't live under ~/.config (like the full `~/.oh-my-zsh` or `~/Pictures/Wallpapers`), we keep separate packages (`oh-my-zsh`, `wallpapers`).

## Adding new things

Just create the folder:

```bash
mkdir -p config/.config/some-new-app
# drop your config files in there
```

Then run `migrate.sh config` (or full `migrate.sh`).
