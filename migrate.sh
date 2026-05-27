#!/usr/bin/env bash
#
# migrate.sh
# Safe deployment script for the minimal ~/.dots setup.
#
# Philosophy: Almost everything lives in the single "home/" stow package.
#
# Usage:
#   ./migrate.sh                    # Stow the home/ package (recommended)
#   ./migrate.sh home               # Explicitly stow home/
#   ./migrate.sh --dry-run          # Preview what would happen
#
# It will:
# 1. Create a timestamped backup of anything that will be touched
# 2. Run GNU Stow for the requested package(s)
# 3. Run any post_stow hook(s) (especially home/meta/post_stow for first-boot automation)

set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_BASE="$HOME/backups/dots-migrate-$(date +%Y-%m-%d_%H%M%S)"
DRY_RUN=false

# In the minimal setup, we almost always just want "home"
DEFAULT_PACKAGES=(home)

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    shift
fi

PACKAGES=("$@")
if [[ ${#PACKAGES[@]} -eq 0 ]]; then
    PACKAGES=("${DEFAULT_PACKAGES[@]}")
fi

# Early check for stow
if ! command -v stow >/dev/null 2>&1; then
    echo "ERROR: 'stow' command not found."
    echo ""
    echo "Correct sequence on a brand new machine:"
    echo "  1. git clone <your-repo> ~/.dots"
    echo "  2. cd ~/.dots"
    echo "  3. ./bootstrap/bootstrap.sh --with-chaotic"
    echo "  4. ./migrate.sh"
    echo ""
    echo "Do NOT run migrate.sh directly after a fresh install without stow."
    exit 1
fi

echo "==> Dots directory: $DOTS_DIR"
echo "==> Backups will go to: $BACKUP_BASE"
echo "==> Packages to deploy: ${PACKAGES[*]}"
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
        echo "  Skipping $pkg (directory not found)"
        return
    fi

    echo "==> Deploying package: $pkg"

    # Broad backups for the main "home" package (covers .config, .local, .fonts, .icons, .zshrc, Pictures, etc.)
    if [[ "$pkg" == "home" ]]; then
        backup_path "$HOME/.zshrc"
        backup_path "$HOME/.config"
        backup_path "$HOME/.local"
        backup_path "$HOME/.fonts"
        backup_path "$HOME/.icons"
        backup_path "$HOME/Pictures/Wallpapers"
        backup_path "$HOME/.oh-my-zsh"   # if user puts the full dir inside home/
    else
        # Generic fallback for any other packages someone might still use
        if [[ -d "$HOME/.config/$pkg" ]]; then
            backup_path "$HOME/.config/$pkg"
        fi
    fi

    echo "  Running stow for $pkg..."
    if [[ "$DRY_RUN" == false ]]; then
        stow --dir="$DOTS_DIR" --target="$HOME" --no-folding "$pkg" 2>&1 || {
            echo "  Warning: stow had issues for $pkg (check manually)"
        }

        # Run post_stow hook if present (this is where first-boot automation lives now)
        local post_hook="$pkg_path/meta/post_stow"
        if [[ -x "$post_hook" ]]; then
            echo "  Running post_stow hook..."
            "$post_hook" || echo "  Warning: post_stow for $pkg exited with error"
        fi
    else
        echo "  [DRY] Would run: stow --dir=$DOTS_DIR --target=$HOME --no-folding $pkg"
        if [[ -x "$pkg_path/meta/post_stow" ]]; then
            echo "  [DRY] Would run post_stow hook: $pkg_path/meta/post_stow"
        fi
    fi
}

for pkg in "${PACKAGES[@]}"; do
    stow_package "$pkg"
done

echo
echo "==> Migration complete."
echo "Backups are in: $BACKUP_BASE"
echo
echo "Next steps after a fresh install:"
echo "  - Test Hyprland / your shell"
echo "  - Run any post_stow automation that lives in home/meta/post_stow"
echo
echo "If something broke, restore from the backup directory above."
