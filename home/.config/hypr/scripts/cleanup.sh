#!/bin/bash
# Standard matugen + Graffiti header + gum theming
source "$HOME/.config/hypr/scripts/header.sh" 2>/dev/null || true
source "$HOME/.config/hypr/scripts/colors.sh" --gum 2>/dev/null || true

# Load common functions (legacy paths removed — using modern locations if available)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Old .hyprgruv paths intentionally removed for portability
# source "$HOME/.hyprgruv/lib/common.sh" 2>/dev/null || true
# source "$HOME/.hyprgruv/lib/state.sh" 2>/dev/null || true

export GUM_CONFIRM_PROMPT="? Would you like to perform a system cleanup? "

clear_header "System Cleanup"
aur_helper="$(bat ~/.config/settings/aur.sh)"
echo ""
sleep1
$aur_helper -Scc
yay -Rsn $(pacman -Qdtq)
sleep 1
clear

duf -theme ansi
sleep 2
