#!/bin/bash

# Standard matugen + Graffiti header + gum theming
source "$HOME/.config/hypr/scripts/header.sh" 2>/dev/null || true
source "$HOME/.config/hypr/scripts/colors.sh" --gum 2>/dev/null || true

clear_header "Launch"

# -----------------------------------------------------
# Quit all running waybar instances
# -----------------------------------------------------
killall waybar
pkill waybar
sleep 0.5

# -----------------------------------------------------
# Reload AGS
# -----------------------------------------------------
#echo ":: Reload ags"
#ags quit &
#sleep 0.2
#ags run &

# -----------------------------------------------------
# Default theme: /THEMEFOLDER;/VARIATION
# -----------------------------------------------------
themestyle="/gruv;/gruv/colored"

# -----------------------------------------------------
# Get current theme information from ~/scripts/waybar-theme.sh
# -----------------------------------------------------
if [ -f ~/.config/hypr/scripts/waybar-theme.sh ]; then
    themestyle=$(cat ~/.config/settings/waybar-theme.sh)
else
    touch ~/.config/hypr/settings/waybar-theme.sh
    echo "$themestyle" >~/.config/settings/waybar-theme.sh
fi

IFS=';' read -ra arrThemes <<<"$themestyle"
echo ":: Theme: ${arrThemes[0]}"

if [ ! -f ~/.config/waybar/themes${arrThemes[1]}/style.css ]; then
    themestyle="/gruv;/gruv/colored"
fi

# -----------------------------------------------------
# Loading the configuration
# -----------------------------------------------------
config_file="config"
style_file="style.css"

# Standard files can be overwritten with an existing config-custom or style-custom.css
if [ -f ~/.config/waybar/themes${arrThemes[0]}/config-custom ]; then
    config_file="config-custom"
fi
if [ -f ~/.config/waybar/themes${arrThemes[1]}/style-custom.css ]; then
    style_file="style-custom.css"
fi

# Check if waybar-disabled file exists
if [ ! -f $HOME/.cache/waybar-disabled ]; then
    waybar -c ~/.config/waybar/themes${arrThemes[0]}/$config_file -s ~/.config/waybar/themes${arrThemes[1]}/$style_file
fi
