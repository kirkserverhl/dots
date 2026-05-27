# bootstrap/

Minimal tools to get a machine into a state where `dotctl` can manage the rest of the system.

## Purpose

This is **not** a full "reproduce my entire computer" script.

Its only job is:
- Install the smallest possible set of base tools
- Ensure all packages declared across the dotfiles manifests are present
- Get you to the point where `dotctl install ...` works reliably

After this runs, **dotctl + GNU Stow** handle all your configs, `~/.local` files, and home directory files.

## Recommended Workflow (Multi-Machine)

### Main Computer (owns the main branch)
- You edit configs here.
- You run `dotctl install ...` and test.
- You commit and push to GitHub.

### Laptop / Other Machines / Future Computers
1. Fresh Arch install (or EndeavourOS, etc.)
2. `git clone https://github.com/trevin-j/dots ~/.dots`
3. Run the bootstrap script (see below)
4. `dotctl install dotctl`
5. `dotctl install all` (or specific packages)
6. Later: `git pull` + re-run bootstrap or `dotctl upgrade`

This keeps everything in sync without needing a giant "one script to rule them all."

## Usage

```bash
git clone https://github.com/trevin-j/dots ~/.dots
~/.dots/bootstrap/bootstrap.sh --with-chaotic
```

Common options:
- `--with-chaotic` — Strongly recommended. Makes many AUR packages installable via pacman.
- `--minimal` — Skips some nice-to-haves.

## What Gets Installed

The actual package lists live in:
- `packages/install.sh` (curated split between pacman and AUR)
- Individual package manifests (`<package>/meta/manifest.sh`) that declare `pacman_deps` and `aur_deps`

The bootstrap script runs the package ensure step so you don't have to manually hunt down missing dependencies.

## Philosophy

- Keep the bootstrap **small and boring**.
- All real configuration lives in the stow packages.
- Hardware-specific things (monitors, touchpad, etc.) live in easily editable files that are **not** blindly forced on every machine.
- Main branch on main computer. Everything else is a consumer of that branch.

## .hyprgruv

The old `~/.hyprgruv` directory is intentionally left as a historical backup / previous attempt. New development happens here (in the dots repo) under the `bootstrap/` and `packages/` areas.
