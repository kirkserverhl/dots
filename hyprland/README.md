# Hyprland Configuration

This package contains your full modular Hyprland setup.

## Structure

```
.config/hypr/
├── hyprland.conf          # Main entrypoint (sources everything else)
├── conf/                  # All your modular config (keybindings, windowrules, animations, monitors, etc.)
│   ├── keybindings/
│   ├── windowrules/
│   ├── monitors/
│   └── ...
├── colors/                # Theme variants + matugen output
├── scripts/               # Custom scripts
├── hyprlock/
└── ...
```

When stowed, this becomes `~/.config/hypr/`.

## Plugins

- Custom plugin (`hyprnospecialfade`) source lives in `hyprnospecialfade/` and is built automatically in `meta/post_stow`.
- Other plugins (hyprbars, hypridle, hymission, etc.) are managed by `hyprpm`.
  - The `meta/post_stow` script automatically runs `hyprpm update + enable + reload` for your main plugins on new machines.

## Notes

- Some files inside `conf/monitors/bak/` and certain color files contain machine-specific comments. These are harmless.
- If you have a `local.conf` or machine-specific overrides, consider keeping them out of the repo or in a separate ignored file.
- After stowing on a new machine, the `post_stow` hook will try to build your custom plugin and set up the hyprpm plugins.

## Re-stowing

If you change anything in this package, re-run:

```bash
~/.dots/migrate.sh hyprland
```
