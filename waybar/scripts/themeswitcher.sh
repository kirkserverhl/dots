#!/bin/bash
# Waybar Theme + Color Switcher
#
# This is a skeleton. Expand it later to let the user choose:
#   - Visual style (matugen, dark, light, transparent, etc.)
#   - Color palette (matugen vs static)
#
# Current behavior: placeholder that just shows the structure.

WAYBAR_DIR="$HOME/.config/waybar"
THEMES_DIR="$WAYBAR_DIR/themes"

# Available themes (add more as you create them)
THEMES=("matugen" "dark" "light" "transparent")

chosen=$(printf "%s\n" "${THEMES[@]}" | rofi -dmenu -p "Waybar Theme" -i)

if [ -z "$chosen" ]; then
    echo "No theme selected."
    exit 0
fi

if [ ! -d "$THEMES_DIR/$chosen" ]; then
    notify-send "Waybar Theme" "Theme '$chosen' not found."
    exit 1
fi

# Switch the style
ln -sf "$THEMES_DIR/$chosen/style.css" "$WAYBAR_DIR/style.css"

# Future: also handle color switching here
# e.g. ln -sf "$WAYBAR_DIR/colors/$chosen.css" "$WAYBAR_DIR/colors/current.css"

notify-send "Waybar Theme" "Switched to: $chosen"

# Restart waybar
pkill -x waybar 2>/dev/null || true
sleep 0.3
waybar -c "$WAYBAR_DIR/config.jsonc" -s "$WAYBAR_DIR/style.css" &
