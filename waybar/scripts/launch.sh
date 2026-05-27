#!/bin/bash
#  ____  _             _    __        __          _
# / ___|| |_ __ _ _ __| |_  \ \      / /_ _ _   _| |__   __ _ _ __
# \___ \| __/ _` | '__| __|  \ \ /\ / / _` | | | | '_ \ / _` | '__|
#  ___) | || (_| | |  | |_    \ V  V / (_| | |_| | |_) | (_| | |
# |____/ \__\__,_|_|   \__|    \_/\_/ \__,_|\__, |_.__/ \__,_|_|
#                                           |___/
#
# Simple Waybar launcher for the new dots structure.
# style.css at the root is a symlink to the active theme.

echo ">> Killing existing Waybar..."
pkill -x waybar 2>/dev/null || true
sleep 0.4

# Launch Waybar using the local config and the symlinked style.css
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &

echo ">> Waybar started (using symlinked theme)"
