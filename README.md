# My Dotfiles (Clean)

Fresh, minimal, and maintainable dotfiles using GNU Stow + a small `dotctl` helper.

**Location:** `~/.dots`

## Quick Start on a New Machine / VM

Simplest one-command flow:

```bash
git clone <your-repo> ~/.dots
cd ~/.dots
./bootstrap/bootstrap.sh --with-chaotic
```

This now installs packages **and** automatically deploys all configs via migrate.sh (including special packages like oh-my-zsh and wallpapers).

Use `--minimal` or `--no-migrate` if you only want packages installed.

## Structure

- `packages/` — Individual Stow packages (zsh, hyprland, ghostty, lf, etc.)
- `bootstrap/` — Tools to get required packages installed
- `migrate.sh` — Safe way to transition existing configs with backups
- `ensure.sh` — Quick "make sure required packages exist" entrypoint
- `dotctl/` — Optional helper tool for dependency-aware installs

## Philosophy

- No heavy plugin managers (Zinit, etc.)
- No Powerlevel10k (using Starship)
- Only tools I actually use
- Easy to migrate machine-to-machine via Git + this repo

## Backups

The `migrate.sh` script always creates timestamped backups in `~/backups/dots-migrate-YYYY-MM-DD_HHMMSS/` before touching anything.

## After Migration

```bash
cd ~/.dots
git init
git add .
git commit -m "Initial clean dotfiles from old setup"
# Then push to GitHub
```

This repo is now the single source of truth.
