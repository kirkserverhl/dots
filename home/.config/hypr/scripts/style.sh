#!/bin/bash
# =============================================
# Universal Styling Library for Hypr Scripts
# Now delegates to the central standard (header.sh + colors.sh)
# =============================================

# Source the official standard theming
source "$HOME/.config/hypr/scripts/header.sh" 2>/dev/null || true
source "$HOME/.config/hypr/scripts/colors.sh" --gum 2>/dev/null || true

# --- Backward compatibility wrappers (so old scripts keep working) ---

print_section() {
    local title="$1"
    echo "$title" | gum style --foreground "${COLOR_PRIMARY:-#89b4fa}" --bold
}

print_box() {
    local content="$1"
    echo "$content" | gum style \
        --foreground "${COLOR_TEXT:-#cdd6f4}" \
        --border rounded \
        --border-foreground "${COLOR_PRIMARY:-#89b4fa}" \
        --padding "1 3"
}

confirm_action() {
    gum confirm --affirmative "Yes" --negative "Cancel" "$1"
}

show_success() {
    gum style --foreground "${COLOR_SUCCESS:-#a6e3a1}" --bold "✓ $1"
}

show_error() {
    gum style --foreground "${COLOR_ERROR:-#f38ba8}" --bold "✗ $1"
}

# Note: print_header, clear_header, display_header, and gum_apply_matugen_theme
# are now provided by the central header.sh + colors.sh when sourced.
