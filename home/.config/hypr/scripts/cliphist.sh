#!/bin/bash

# Standard matugen + Graffiti header + gum theming
source "$HOME/.config/hypr/scripts/header.sh" 2>/dev/null || true
source "$HOME/.config/hypr/scripts/colors.sh" --gum 2>/dev/null || true

clear_header "Clipboard History"

#case $1 in
#    d) cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist delete
#       ;;
#
#    w) if [ `echo -e "Clear\nCancel" | rofi -dmenu -config ~/.config/rofi/config-short.rasi` == "Clear" ] ; then
#            cliphist wipe
#       fi
#       ;;
#
#    *) cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist decode | wl-copy
#       ;;
#esac

#!/usr/bin/env bash

case $1 in
d)
    # Delete selected item
    cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist delete
    ;;
w)
    # Wipe (clear) all history after confirmation
    if [ "$(echo -e "Clear\nCancel" | rofi -dmenu -config ~/.config/rofi/config-short.rasi)" = "Clear" ]; then
        cliphist wipe
    fi
    ;;
*)
    # Default: show history and copy selected item to clipboard
    cliphist list | rofi -dmenu -replace -config ~/.config/rofi/config-cliphist.rasi | cliphist decode | wl-copy
    ;;
esac
