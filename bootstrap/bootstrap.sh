#!/usr/bin/env bash
#
# bootstrap/bootstrap.sh
# Minimal bootstrap to get any machine (main, laptop, or new) to a working state.
#
# Philosophy:
# - This is NOT a full reproduction script.
# - Its only job is to ensure the required base tools + all declared packages exist.
# - After this, `dotctl` (via GNU Stow + manifests) handles config deployment.
# - Main computer owns the main branch. Other machines just `git pull` + re-run this.
#
# Usage (on a fresh Arch-based machine):
#   git clone https://github.com/trevin-j/dots ~/.dots
#   ~/.dots/bootstrap/bootstrap.sh
#
#   # Then:
#   ~/.dots/dotctl/.local/bin/dotctl install dotctl
#   dotctl install all
#
# Options:
#   --with-chaotic     Set up Chaotic-AUR (recommended)
#   --minimal          Skip optional niceties
#   --help

set -euo pipefail

DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_SCRIPT="$DOTS_DIR/packages/install.sh"

# ---------- helpers ----------
log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }

WITH_CHAOTIC=false
MINIMAL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-chaotic) WITH_CHAOTIC=true; shift ;;
    --minimal)      MINIMAL=true; shift ;;
    --help|-h)
      sed -n '2,20p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *) warn "Unknown flag: $1"; exit 1 ;;
  esac
done

# ---------- step 1: base tools ----------
log "Installing base bootstrap tools..."
sudo pacman -Syu --needed --noconfirm \
  git base-devel reflector stow

# ---------- step 2: yay ----------
if ! command -v yay >/dev/null 2>&1; then
  log "Bootstrapping yay..."
  tmp=$(mktemp -d)
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
else
  log "yay already present"
fi

# ---------- step 3: Chaotic-AUR (optional but recommended) ----------
if [[ "$WITH_CHAOTIC" == true ]]; then
  log "Setting up Chaotic-AUR..."
  if ! grep -q '^\[chaotic-aur\]' /etc/pacman.conf 2>/dev/null; then
    sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com || true
    sudo pacman-key --lsign-key 3056513887B78AEB || true
    sudo pacman -U --noconfirm \
      'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
      'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' || true
    echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | \
      sudo tee -a /etc/pacman.conf >/dev/null
  fi
  sudo pacman -Syy
fi

# ---------- step 4: ensure all required packages ----------
if [[ -x "$PACKAGES_SCRIPT" ]]; then
  log "Ensuring all required packages are installed..."
  "$PACKAGES_SCRIPT" ${WITH_CHAOTIC:+--with-chaotic} ${MINIMAL:+--minimal} || true
else
  warn "packages/install.sh not found or not executable — skipping package ensure step"
fi

# ---------- step 5: final instructions ----------
echo
log "Bootstrap complete."
echo
cat <<'EOF'
Next steps (recommended order for testing / new machines):

  1. Run the main migration (this handles most packages + special ones like oh-my-zsh and wallpapers):
     ~/.dots/migrate.sh

  2. (Optional) Once dotctl is ready and you prefer it:
     ~/.dots/dotctl/.local/bin/dotctl install dotctl
     dotctl install all

migrate.sh is currently the more reliable path, especially early on or in VMs.

See docs/VM_TEST.md for realistic expectations when testing in a virtual machine.

Special packages (oh-my-zsh full directory, wallpapers, etc.) are included
in the default list inside migrate.sh and have post_stow hooks.

Edit packages in the dots repo on your main machine, commit, push.
Other machines just pull and re-run the bootstrap + migrate.
EOF
