# home/ - Main "Big Home" Stow Package

This package mirrors large parts of your `$HOME` directory for simple deployment.

## How to deploy

```bash
cd ~/.dots
stow home
# or
./migrate.sh home
```

This will create symlinks in your home directory for:
- `.config/`
- `.local/`
- `.fonts/`
- `.icons/`
- `Pictures/Wallpapers/`
- `.zshrc`
- and any other top-level items you place here

## Adding new applications

Just drop the folder in:

```bash
mkdir -p home/.config/new-cool-app
# add your config files
```

Then run `migrate.sh home`.

## Special packages kept outside home/

Some things are kept as separate top-level packages because they need extra logic:

- `oh-my-zsh/` (very large + contains its own .git)
- `wallpapers/` (if you want isolated management of the Pictures/Wallpapers target)
- `hyprland/` (has post_stow hooks for building plugins and setting up hyprpm)
- `theming/` (matugen + automatic color generation + default wallpaper)

You can choose to move more things into `home/` over time if you prefer maximum simplicity.
