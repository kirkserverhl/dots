#!/bin/bash

# Standard matugen + Graffiti header + gum theming
source "$HOME/.config/hypr/scripts/header.sh" 2>/dev/null || true
source "$HOME/.config/hypr/scripts/colors.sh" --gum 2>/dev/null || true

clear_header "Updates"


# -----------------------------------------------------
# Define threshholds for color indicators
# -----------------------------------------------------

threshhold_green=0
threshhold_yellow=25
threshhold_red=100
install_platform="$(cat ~/.config/settings/platform.sh)"

# Check if platform is supported
case $install_platform in
arch)
    aur_helper="$(cat ~/.config/settings/aur.sh)"

    # -----------------------------------------------------
    # Calculate available updates
    # -----------------------------------------------------

    if ! updates_arch=$(checkupdates 2>/dev/null | wc -l); then
        updates_arch=0
    fi

    if ! updates_aur=$($aur_helper -Qu --aur --quiet | wc -l); then
        updates_aur=0
    fi

    # flatpak remote-ls --updates

    updates=$(("$updates_arch" + "$updates_aur"))
    ;;
fedora)
    updates=$(dnf check-update -q | grep -c ^[a-z0-9])
    ;;
*)
    updates=0
    ;;
esac

# -----------------------------------------------------
# Output in JSON format for Waybar Module custom-updates
# -----------------------------------------------------

css_class="green"

if [ "$updates" -gt $threshhold_yellow ]; then
    css_class="yellow"
fi

if [ "$updates" -gt $threshhold_red ]; then
    css_class="red"
fi

if [ "$updates" -gt $threshhold_green ]; then
    printf '{"text": "%s", "alt": "%s", "tooltip": "Click to update your system", "class": "%s"}' "$updates" "$updates" "$updates" "$css_class"
else
    printf '{"text": "0", "alt": "0", "tooltip": "No updates available", "class": "green"}'
fi
