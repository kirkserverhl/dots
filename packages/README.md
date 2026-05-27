# packages/

Scripts for managing the "necessary packages" list when reinstalling the machine.

## Why this exists

Over time every Arch install accumulates hundreds of packages that are:
- No longer used
- Pulled in as dependencies of things you tried once
- Big desktop environment bits (full Plasma, etc.) you don't actually need with Hyprland
- Provided by other tools now

This directory keeps a **curated, auditable, minimal-but-complete** split:

- `install.sh` — the actual reinstall script. Uses `pacman` for repo packages and `yay` for AUR packages.
- `list-current.sh` — run on your live system to see exactly what you currently have explicitly installed, already separated the same way.

## Recommended workflow for a reinstall

1. On your current machine:
   ```bash
   ./packages/list-current.sh > ~/my-current-packages.txt
   ```
   Review it. Delete anything you don't actually miss when it's gone.

2. Edit `install.sh` and update the two arrays (`PACMAN_PACKAGES` and `YAY_PACKAGES`) with your pruned list.

3. On the fresh machine (after base Arch/EndeavourOS install + internet):
   ```bash
   git clone https://github.com/trevin-j/dots ~/.dots
   cd ~/.dots
   ./packages/install.sh --reflector --with-chaotic -y
   ```

4. Then install the actual configs:
   ```bash
   # make dotctl available
   ~/.dots/dotctl/.local/bin/dotctl install dotctl

   # install everything (or pick what you want)
   dotctl install all
   ```

## Tips

- `--with-chaotic` is strongly recommended. It turns a huge number of popular AUR packages into normal `pacman` installs (no compilation, faster updates).
- After enabling Chaotic, move packages like `brave-bin`, `nwg-*`, `grimblast-git`, etc. from the YAY list into the PACMAN list.
- The lists in `install.sh` are intentionally lean. Start there and only add back things you truly use daily.
- `yay` is used for the AUR section because it's what the original post-install checklist used and it's very popular. You can change it to `paru` if you prefer (one line change).
- Dolphin + its supporting KDE packages (Ark, thumbnailers, kio plugins, kdeconnect, xdg-desktop-portal-kde, etc.) are intentionally kept because Dolphin is still actively used as the file manager. The rest of Plasma (plasma-desktop, spectacle, etc.) remains excluded.

## Files

- `install.sh` — main bootstrap script (edit the package arrays at the top)
- `list-current.sh` — diagnostic tool to audit what you currently have installed

Both scripts are safe to run with `--dry-run` first.
