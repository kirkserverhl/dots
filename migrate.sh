#!/usr/bin/env bash
#
# migrate.sh
# Safe migration script for the new ~/.dots setup.
#
# Usage:
#   ./migrate.sh                    # Migrate common packages with backups
#   ./migrate.sh zsh hyprland       # Migrate specific packages
#   ./migrate.sh --dry-run          # Show what would happen
#
# It will:
# 1. Create timestamped backups of existing config before touching anything
# 2. Run stow to create symlinks from ~/.dots/<package> to ~

set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_BASE="$HOME/backups/dots-migrate-$(date +%Y-%m-%d_%H%M%S)"
DRY_RUN=false

# Default packages to migrate if none specified
DEFAULT_PACKAGES=(zsh lf theming hyprland waybar fonts lazygit)

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    shift
fi

PACKAGES=("$@")
if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    PACKAGES=("${DEFAULT_PACKAGES[@]}")
fi

echo "==> New dotfiles location: $DOTS_DIR"
echo "==> Backups will go to:    $BACKUP_BASE"
echo "==> Packages to migrate:   ${PACKAGES[*]}"
echo

if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY RUN] No changes will be made."
fi

mkdir -p "$BACKUP_BASE"

backup_path() {
    local src="$1"
    if [[ -e "$src" || -L "$src" ]]; then
        local dest="$BACKUP_BASE/$(basename "$src")"
        echo "  Backing up: $src → $dest"
        if [[ "$DRY_RUN" == false ]]; then
            mkdir -p "$(dirname "$dest")"
            cp -a "$src" "$dest"
        fi
    fi
}

stow_package() {
    local pkg="$1"
    local pkg_path="$DOTS_DIR/$pkg"

    if [[ ! -d "$pkg_path" ]]; then
        echo "  Skipping $pkg (no directory at $pkg_path)"
        return
    fi

    echo "==> Migrating package: $pkg"

    # Common locations that this package might affect (customize per package if needed)
    case "$pkg" in
        zsh)
            backup_path "$HOME/.zshrc"
            backup_path "$HOME/.zshenv"
            backup_path "$HOME/.config/zsh"
            ;;
        hyprland)
            backup_path "$HOME/.config/hypr"
            ;;
        lf)
            backup_path "$HOME/.config/lf"
            ;;
        theming)
            backup_path "$HOME/.config/matugen"
            backup_path "$HOME/.local/share/color-schemes"
            ;;
        waybar)
            backup_path "$HOME/.config/waybar"
            ;;
        fonts)
            backup_path "$HOME/.local/share/fonts"
            ;;
        *)
            # Generic: try to guess common config dir
            if [[ -d "$HOME/.config/$pkg" ]]; then
                backup_path "$HOME/.config/$pkg"
            fi
            ;;
    esac

    echo "  Stowing $pkg..."
    if [[ "$DRY_RUN" == false ]]; then
        stow --dir="$DOTS_DIR" --target="$HOME" --no-folding "$pkg" 2>&1 || {
            echo "  Warning: stow had issues for $pkg (check manually)"
        }
    else
        echo "  [DRY] Would run: stow --dir=$DOTS_DIR --target=$HOME --no-folding $pkg"
    fi
}

for pkg in "${PACKAGES[@]}"; do
    stow_package "$pkg"
done

echo
echo "==> Migration complete (or simulated)."
echo "Backups are in: $BACKUP_BASE"
echo
echo "Next steps:"
echo "  1. Test your shell / Hyprland session"
echo "  2. cd ~/.dots && git init && git add . && git commit -m 'Initial clean dotfiles'"
echo "  3. Push to your new GitHub repo"
echo
echo "If something is broken, restore from the backup directory above."