# VM Testing Guide

This document describes how to test the full dots setup in a virtual machine (recommended before relying on it for real machines).

## Recommended VM Setup

- Use **Arch ISO** (or EndeavourOS / Garuda if you prefer a slightly easier base).
- Give the VM at least **4GB RAM** and **2+ CPU cores**.
- Enable **3D acceleration** if your hypervisor supports it (helps with Hyprland).
- Use **VirtIO** graphics + **VirtIO** disk/network for best performance.

**Known limitations in a VM:**
- Hyprland will be slow or glitchy without proper GPU passthrough.
- Some hardware-specific tools (`brightnessctl`, certain input devices) won't work.
- You probably won't have a real display manager — plan to start Hyprland from the TTY.

## Recommended Test Flow

1. Boot the Arch ISO.
2. Set up networking and partition the disk (basic install).
3. Install base system + essential tools:
   ```bash
   pacman -Syu git base-devel reflector
   ```
4. Clone the repo:
   ```bash
   git clone https://github.com/trevin-j/dots ~/.dots
   cd ~/.dots
   ```
5. Run the bootstrap:
   ```bash
   ./bootstrap/bootstrap.sh --with-chaotic
   ```
6. At this point you should have yay + most declared packages.

7. Deploy configs:
   - Preferred (once ready): `dotctl install all`
   - Fallback: `./migrate.sh`

8. Special packages that need extra attention:
   - `oh-my-zsh` (full directory symlink)
   - `wallpapers` (creates ~/Pictures/Wallpapers symlink)
   - `zsh` (your .zshrc + custom plugins)

   You can install these individually:
   ```bash
   dotctl install oh-my-zsh wallpapers zsh
   ```

## What to Test

- [ ] Bootstrap script completes without errors
- [ ] All declared packages from manifests get installed
- [ ] `dotctl install all` (or `migrate.sh`) succeeds
- [ ] Zsh starts with your config and plugins (especially Atuin + custom .oh-my-zsh stuff)
- [ ] Hyprland starts (even if performance is bad)
- [ ] Waybar appears with correct styling and scripts
- [ ] Special symlinks exist:
  - `~/.oh-my-zsh`
  - `~/Pictures/Wallpapers`
- [ ] Common tools work: yazi, nvim, starship, bat, fastfetch, etc.
- [ ] No hard-coded paths from your main machine break things

## Tips for Smoother VM Testing

- Start with `--minimal` flag on bootstrap if you want to move faster.
- You can run `migrate.sh --dry-run` first to see what would happen.
- For Hyprland testing, consider temporarily using a simpler window manager (sway or even i3) until the core configs are validated.
- If you hit missing dependencies, add them to `packages/install.sh` or the relevant manifest.

## After a Successful Test

- Note any packages that were missing.
- Note any scripts that assumed certain directories or hardware existed.
- Update `packages/install.sh` and manifests accordingly.
- Consider adding a `post_stow` hook if a package needs extra setup on first run.

## When to Stop Testing in the VM

Once the following work reliably, you're in good shape to try it on real hardware:
- Fresh Arch install → clone → bootstrap → full config deployment
- Your shell and core tools feel like "your setup"
- Major breakage is caught before it hits a real machine
