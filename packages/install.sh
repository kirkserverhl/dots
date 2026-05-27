#!/usr/bin/env bash
#
# packages/install.sh
# Curated "necessary" packages installer for Arch / EndeavourOS + this dots repo.
#
# Purpose:
#   - Separate official-repo / chaotic-aur packages (pacman) from true AUR packages (yay)
#   - Provide a lean, opinionated list of what is actually needed for this workflow
#   - Make reinstalling the machine straightforward and auditable
#
# Usage:
#   git clone https://github.com/trevin-j/dots ~/.dots
#   cd ~/.dots
#   ./packages/install.sh
#
#   # Or with options:
#   ./packages/install.sh --with-chaotic --reflector
#
# Edit the two arrays below to match YOUR definition of "necessary".
# Packages you previously had that are bloat or provided by other tools are intentionally
# left out (full Plasma desktop, spectacle, plasma-desktop, Steam, LibreOffice, OBS, etc.).
# Dolphin + its thumbnailers/integration are kept because you still actively use Dolphin.
#
# After this script, you can run:
#   dotctl install all
#   (or dotctl install <specific> for the configs you want)

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration - EDIT THESE LISTS
# -----------------------------------------------------------------------------

# Packages available from official repos or binary repos (Chaotic-AUR, etc.).
# These will be installed with pacman (fast, no compilation for most).
# Once you enable Chaotic-AUR, many popular "AUR-looking" packages (brave-bin, etc.)
# become available here and can be moved out of the YAY list.
PACMAN_PACKAGES=(
  # --- Bootstrap / essentials ---
  base-devel
  git
  reflector
  networkmanager

  # --- Shell & core terminal workflow (from zsh/lf manifests + daily use) ---
  zsh
  eza
  fzf
  zoxide
  bat
  trash-cli
  stow
  lf
  neovim
  lazygit
  starship
  atuin
  yazi

  # lf / file preview support
  chafa
  mupdf-tools
  tesseract
  tesseract-data-eng
  ffmpeg
  ffmpegthumbnailer

  # --- Hyprland (lean, no full desktop bloat) ---
  hyprland
  hyprpolkitagent
  hyprpicker
  grim
  slurp
  wl-clipboard
  brightnessctl
  xdg-desktop-portal-hyprland
  xdg-desktop-portal

  # PipeWire audio
  pipewire
  wireplumber
  pipewire-pulse
  pipewire-alsa

  # --- Theming foundation (matugen + friends live in YAY list) ---
  uv
  qt6ct
  papirus-icon-theme
  adw-gtk-theme
  ttf-material-symbols-variable

  # --- Daily utilities (keep this list small) ---
  jq
  curl
  fastfetch
  figlet
  btop
  duf
  dust
  ncdu
  man-db
  man-pages
  pavucontrol
  dunst
  rofi
  wlogout
  waypaper

  # --- Terminals ---
  kitty
  # ghostty          # currently AUR on most Arch setups

  # --- Browser (swap to brave-bin after enabling Chaotic-AUR if preferred) ---
  firefox
  chromium   # or google-chrome from AUR if you prefer the full Google version + chrome-flags.conf

  # --- Optional but commonly wanted with this setup ---
  # (removed foot - now using ghostty + kitty as main terminals)
  # (Quickshell removed — user uses Waybar, planning to move to AGS)

  # --- Dolphin file manager + minimal KDE integration ---
  # Stripped down to reduce KDE bloat while keeping Dolphin usable.
  # (Removed konsole, kdeconnect, kompare, audiocd-kio, heavy kio plugins)
  dolphin ark baloo dolphin-plugins
  ffmpegthumbs icoutils kdegraphics-thumbnailers
  kimageformats libappimage qt6-imageformats resvg taglib
)

# Packages that must be built or come only from the AUR (or you prefer the AUR version).
# These are installed with yay after it is bootstrapped.
# Keep this list as small as possible. Many "AUR" packages are available prebuilt via Chaotic-AUR.
YAY_PACKAGES=(
  # === Theming (critical for this dots setup) ===
  matugen-git
  python-pywalfox          # Used with matugen for Firefox theming
  bibata-cursor-theme-bin

  # === Terminals ===
  ghostty

  # === Editors ===
  vscodium-bin

  # === Declared in manifests ===
  opencode-bin

  # === Nice-to-haves that are usually true AUR or you want latest -git ===
  # wvkbd-git

  # === Add your personal "must build from AUR" packages below ===
  # pyprland
  # nwg-look                 # often available via Chaotic after setup
  # grimblast-git
  # etc.
)

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

log()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==> WARNING:\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; }

DRY_RUN=false
SETUP_REFLECTOR=false
ENABLE_CHAOTIC=false
YES=false
MINIMAL=false

show_help() {
  cat <<'EOF'
packages/install.sh — install only the necessary packages (pacman vs yay split)

Options:
  --dry-run           Show what would be installed but do nothing
  --reflector         Run reflector to pick fast mirrors first
  --with-chaotic      Set up Chaotic-AUR (lets you install many AUR packages via pacman)
  --minimal           Minimal mode (accepted for compatibility)
  --yes, -y           Assume yes to all prompts
  --help, -h          This help

Edit PACMAN_PACKAGES and YAY_PACKAGES at the top of this file to customize.
EOF
}

confirm() {
  [[ "$YES" == true ]] && return 0
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

have() { command -v "$1" >/dev/null 2>&1; }

run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY: $*"
  else
    "$@"
  fi
}

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)        DRY_RUN=true; shift ;;
    --reflector)      SETUP_REFLECTOR=true; shift ;;
    --with-chaotic)   ENABLE_CHAOTIC=true; shift ;;
    --minimal)        MINIMAL=true; shift ;;  # accepted for bootstrap compatibility (no-op for now)
    --yes|-y)         YES=true; shift ;;
    --help|-h)        show_help; exit 0 ;;
    *) err "Unknown option: $1"; show_help; exit 1 ;;
  esac
done

# -----------------------------------------------------------------------------
# Pre-flight
# -----------------------------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
  err "Do not run this script as root. It will use sudo when needed."
  exit 1
fi

log "Starting necessary packages installation (pacman vs yay separation)"
[[ "$DRY_RUN" == true ]] && warn "DRY RUN MODE — no changes will be made"

# -----------------------------------------------------------------------------
# Mirror speed (optional but highly recommended on fresh installs)
# -----------------------------------------------------------------------------

if [[ "$SETUP_REFLECTOR" == true ]]; then
  log "Installing reflector and ranking mirrors (US + worldwide, rate sorted)..."
  run sudo pacman -S --needed --noconfirm reflector
  if [[ "$DRY_RUN" == false ]]; then
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak 2>/dev/null || true
    sudo reflector \
      --save /etc/pacman.d/mirrorlist \
      --sort rate \
      --sort age \
      --country "United States" \
      --country "Worldwide" \
      --protocol https \
      --latest 20 || warn "reflector failed, continuing with existing mirrors"
    sudo pacman -Syy
  fi
fi

# -----------------------------------------------------------------------------
# Base tools needed before anything else
# -----------------------------------------------------------------------------

log "Ensuring base tools for bootstrapping..."
run sudo pacman -S --needed --noconfirm git base-devel

# -----------------------------------------------------------------------------
# AUR helper (yay) bootstrap — only if not already present
# -----------------------------------------------------------------------------

if ! have yay; then
  log "Bootstrapping yay (AUR helper)..."
  if [[ "$DRY_RUN" == false ]]; then
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    pushd "$tmp/yay-bin" >/dev/null
    makepkg -si --noconfirm
    popd >/dev/null
    rm -rf "$tmp"
    trap - EXIT
  else
    echo "DRY: would clone yay-bin and makepkg -si"
  fi
  log "yay installed."
else
  log "yay already present: $(yay --version | head -1)"
fi

# -----------------------------------------------------------------------------
# Chaotic-AUR (optional, highly recommended)
# -----------------------------------------------------------------------------

setup_chaotic() {
  log "Setting up Chaotic-AUR (prebuilt popular AUR packages)..."

  if ! grep -q '^\[chaotic-aur\]' /etc/pacman.conf 2>/dev/null; then
    log "Adding [chaotic-aur] to /etc/pacman.conf"
    run sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    run sudo pacman-key --lsign-key 3056513887B78AEB

    run sudo pacman -U --noconfirm \
      'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
      'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

    echo -e '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist' | \
      run sudo tee -a /etc/pacman.conf >/dev/null
  else
    log "[chaotic-aur] already configured in pacman.conf"
  fi

  run sudo pacman -Syy
  log "Chaotic-AUR ready. You can now move many packages from YAY_PACKAGES into PACMAN_PACKAGES (brave-bin, nwg-*, etc)."
}

if [[ "$ENABLE_CHAOTIC" == true ]]; then
  setup_chaotic
fi

# -----------------------------------------------------------------------------
# Install official / repo packages
# -----------------------------------------------------------------------------

if ((${#PACMAN_PACKAGES[@]} > 0)); then
  log "Installing ${#PACMAN_PACKAGES[@]} pacman packages..."
  # Filter out empty / comment lines just in case
  mapfile -t PKGS < <(printf '%s\n' "${PACMAN_PACKAGES[@]}" | grep -v '^#' | grep -v '^$')
  if ((${#PKGS[@]} > 0)); then
    run sudo pacman -S --needed --noconfirm "${PKGS[@]}"
  fi
else
  log "No pacman packages listed."
fi

# -----------------------------------------------------------------------------
# Install AUR packages via yay
# -----------------------------------------------------------------------------

if ((${#YAY_PACKAGES[@]} > 0)); then
  log "Installing ${#YAY_PACKAGES[@]} AUR packages via yay..."
  mapfile -t AURPKGS < <(printf '%s\n' "${YAY_PACKAGES[@]}" | grep -v '^#' | grep -v '^$')
  if ((${#AURPKGS[@]} > 0)); then
    run yay -S --needed --noconfirm "${AURPKGS[@]}"
  fi
else
  log "No AUR packages listed."
fi

# -----------------------------------------------------------------------------
# Post-install hints
# -----------------------------------------------------------------------------

log "Package installation complete."

if ! have dotctl; then
  warn "dotctl not found in PATH yet."
  echo "After switching to zsh (if not already), make sure ~/.local/bin is in PATH,"
  echo "then run:  ~/.dots/dotctl/.local/bin/dotctl install dotctl"
fi

echo
cat <<'EOF'
Next recommended steps:
  1. (Optional) Switch to zsh:  chsh -s "$(which zsh)"
  2. Install your dotfiles:     dotctl install all     (or specific packages)
  3. Reboot or log out/in so everything (especially portals, pipewire, etc.) starts cleanly.

Edit this script anytime to add/remove packages as your "necessary" set evolves.
Bloat you previously accumulated (full Plasma, Steam, big IDEs, etc.) has been left out on purpose.
EOF

if [[ "$DRY_RUN" == true ]]; then
  warn "This was a dry run. Remove --dry-run to actually install."
fi
