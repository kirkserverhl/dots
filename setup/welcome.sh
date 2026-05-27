#!/usr/bin/env bash
#
# dots welcome / setup utility
#
# This is a re-runnable "welcome screen" + setup tool.
# It can be run at any time to configure common things after install.
#
# Usage:
#   ./setup/welcome.sh
#   dots-welcome                    (once installed via home stow)
#   dots-welcome --dry-run          (safe testing - shows what would happen)
#
# It is intentionally non-destructive and optional.

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
DOTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/dots"
WELCOME_DISABLED_FILE="$STATE_DIR/welcome-disabled"

# Dry-run support for safe testing
DRY_RUN=false

# Floating window support (consistent with other tools like unlockroot.sh and palette.sh)
CLASS="dotfiles-floating"
CLEAN_ENV=(env -u GDK_DEBUG -u GDK_DISABLE GDK_DEBUG= GDK_DISABLE=)

# Path to local setup scripts (we execute these rather than sourcing
# to avoid side effects from their current top-level code)
SETUP_SCRIPTS_DIR="$DOTS_DIR/setup/scripts"

# Colors for basic output if gum is not available
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }

log()    { echo -e "${BLUE}==>${NC} $*"; }
success(){ echo -e "${GREEN}==>${NC} $*"; }
warn()   { echo -e "${YELLOW}==>${NC} $*"; }
error()  { echo -e "${RED}ERROR:${NC} $*" >&2; }

# Helper for dry-run safe execution
run_or_dry() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would execute: $*"
    else
        "$@"
    fi
}

require_gum() {
    if ! have gum; then
        warn "gum is not installed. Some menus will be less pretty."
        warn "You can install it with: yay -S gum"
        return 1
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Welcome screen toggle
# -----------------------------------------------------------------------------
is_welcome_disabled() {
    [[ -f "$WELCOME_DISABLED_FILE" ]]
}

disable_welcome_screen() {
    mkdir -p "$STATE_DIR"
    touch "$WELCOME_DISABLED_FILE"
    success "Welcome screen disabled. You can still run this script anytime with 'dots-welcome'."
}

enable_welcome_screen() {
    rm -f "$WELCOME_DISABLED_FILE"
    success "Welcome screen re-enabled."
}

# -----------------------------------------------------------------------------
# Main Menu
# -----------------------------------------------------------------------------
show_main_menu() {
    local title="Dots Setup"

    if [[ "$DRY_RUN" == true ]]; then
        title="Dots Setup (DRY RUN - No changes will be made)"
    elif is_welcome_disabled; then
        title="Dots Setup (Welcome screen is disabled)"
    else
        title="Welcome to your new system!"
    fi

    if require_gum; then
        gum style \
            --border normal \
            --margin "1" \
            --padding "1 2" \
            --border-foreground 212 \
            "$title"

        local choice
        choice=$(gum choose \
            "System Theming" \
            "User Preferences" \
            "SSH & GitHub" \
            "Shell Setup" \
            "Toggle Welcome Screen" \
            "Exit")

        case "$choice" in
            "System Theming")     theming_menu ;;
            "User Preferences")   preferences_menu ;;
            "SSH & GitHub")       ssh_github_menu ;;
            "Shell Setup")        shell_menu ;;
            "Toggle Welcome Screen") toggle_welcome_menu ;;
            "Exit"|"")            exit 0 ;;
        esac
    else
        # Basic fallback menu
        echo "=== $title ==="
        echo "1) System Theming"
        echo "2) User Preferences"
        echo "3) SSH & GitHub"
        echo "4) Shell Setup"
        echo "5) Toggle Welcome Screen"
        echo "6) Exit"
        read -rp "Choose an option: " choice
        case "$choice" in
            1) theming_menu ;;
            2) preferences_menu ;;
            3) ssh_github_menu ;;
            4) shell_menu ;;
            5) toggle_welcome_menu ;;
            *) exit 0 ;;
        esac
    fi
}

# -----------------------------------------------------------------------------
# Menus (stubs for now - we will fill these in)
# -----------------------------------------------------------------------------
theming_menu() {
    echo "=== System Theming ==="
    echo "1) Install & configure GRUB theme"
    echo "2) Install & configure SDDM theme"
    echo "3) Back"
    read -rp "Choice: " c
    case "$c" in
        1) setup_grub_theme ;;
        2) setup_sddm_theme ;;
        *) show_main_menu ;;
    esac
}

preferences_menu() {
    echo "=== User Preferences ==="
    echo "(This will eventually let you set browser, editor, file manager, etc.)"
    echo "1) Set default browser"
    echo "2) Set default terminal"
    echo "3) Back"
    read -rp "Choice: " c
    case "$c" in
        1) set_default_browser ;;
        2) set_default_terminal ;;
        *) show_main_menu ;;
    esac
}

ssh_github_menu() {
    echo "=== SSH & GitHub Authentication ==="
    echo "1) Generate new SSH key + copy to clipboard"
    echo "2) Add key to ssh-agent"
    echo "3) GitHub CLI authentication (gh)"
    echo "4) Back"
    read -rp "Choice: " c
    case "$c" in
        1) generate_ssh_key ;;
        2) add_ssh_to_agent ;;
        3) setup_github_auth ;;
        *) show_main_menu ;;
    esac
}

shell_menu() {
    echo "=== Shell Setup ==="
    echo "1) Switch default shell (bash ↔ zsh)"
    echo "2) Back"
    read -rp "Choice: " c
    case "$c" in
        1) change_default_shell ;;
        *) show_main_menu ;;
    esac
}

toggle_welcome_menu() {
    if is_welcome_disabled; then
        enable_welcome_screen
    else
        disable_welcome_screen
    fi
    show_main_menu
}

# -----------------------------------------------------------------------------
# Placeholder functions (we will implement these properly later)
# -----------------------------------------------------------------------------
setup_grub_theme() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would run GRUB theme setup script."
    else
        echo "Running existing gruvgrub setup..."
        bash "$SETUP_SCRIPTS_DIR/grub-theme.sh"
    fi
    read -rp "Press enter to continue..."
    theming_menu
}

setup_sddm_theme() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would run SDDM/GRUB theme setup script."
    else
        echo "Running existing SDDM/GRUB theme setup..."
        bash "$SETUP_SCRIPTS_DIR/sddm-theme.sh"
    fi
    read -rp "Press enter to continue..."
    theming_menu
}

set_default_browser() {
    warn "Browser selection not implemented yet."
    read -rp "Press enter to continue..."
    preferences_menu
}

set_default_terminal() {
    warn "Terminal selection not implemented yet."
    read -rp "Press enter to continue..."
    preferences_menu
}

generate_ssh_key() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would run SSH key generation helper."
    else
        echo "Running SSH key generation helper..."
        bash "$SETUP_SCRIPTS_DIR/ssh-key.sh"
    fi
    read -rp "Press enter to continue..."
    ssh_github_menu
}

add_ssh_to_agent() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would run SSH agent helper."
    else
        echo "Running SSH agent helper..."
        bash "$SETUP_SCRIPTS_DIR/ssh-add.sh"
    fi
    read -rp "Press enter to continue..."
    ssh_github_menu
}

setup_github_auth() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would attempt GitHub CLI authentication (gh auth login)."
    else
        echo "Launching GitHub CLI authentication..."
        if command -v gh >/dev/null 2>&1; then
            gh auth login
        else
            echo "GitHub CLI (gh) is not installed."
            echo "Install it with: yay -S github-cli"
        fi
    fi
    read -rp "Press enter to continue..."
    ssh_github_menu
}

change_default_shell() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would run shell selection script."
    else
        echo "Running existing shell selection script..."
        bash "$SETUP_SCRIPTS_DIR/shell.sh"
    fi
    read -rp "Press enter to continue..."
    shell_menu
}

# -----------------------------------------------------------------------------
# Entry point
# -----------------------------------------------------------------------------
main() {
    # --- Floating Kitty self-launch (so it appears in a nice floating window) ---
    # Skip self-launch if:
    # - Already inside the floating instance
    # - Running with --dry-run from an existing terminal (for testing)
    # - Running in a non-interactive context
    if [[ -z "${WELCOME_INSIDE:-}" && "$DRY_RUN" != true && -t 1 ]]; then
        export WELCOME_INSIDE=1
        exec "${CLEAN_ENV[@]}" kitty \
            --class "$CLASS" \
            --title "Dots Welcome" \
            --override initial_window_width=100c \
            --override initial_window_height=35c \
            "$0" "$@"
    fi

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    local first_run=false

    if ! is_welcome_disabled; then
        first_run=true
    fi

    if [[ "$first_run" == true ]]; then
        local welcome_title="Welcome to your new Dots setup!"
        if [[ "$DRY_RUN" == true ]]; then
            welcome_title="Welcome to your new Dots setup! (DRY RUN)"
        fi

        if require_gum; then
            gum style \
                --foreground 212 --border double --align center --width 60 --margin "1 2" \
                "$welcome_title" "" \
                "This tool can be run at any time with:" \
                "    dots-welcome"
        else
            echo "=============================================="
            echo "  $welcome_title"
            echo "=============================================="
            echo
            echo "You can run this tool anytime with: dots-welcome"
            echo
        fi
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN MODE ENABLED] No changes will be made to your system."
        echo
    fi

    while true; do
        show_main_menu
    done
}

main "$@"
