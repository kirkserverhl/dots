#!/usr/bin/env bash
#
# packages/list-current.sh
# Helper to dump your *currently installed* explicit packages, separated by
# pacman (official + binary repos like Chaotic) vs yay/AUR (foreign packages).
#
# Use this when preparing for a reinstall to see exactly what you have today,
# then prune the lists in install.sh down to only what is truly necessary.
#
# Output is sorted and clean (just package names).

set -euo pipefail

echo "# === PACMAN / BINARY REPO PACKAGES (explicit) ==="
echo "# These can be installed with pacman (or yay, same result)."
echo "# After enabling Chaotic-AUR many of your current 'AUR-looking' packages move here."
pacman -Qent | awk '{print $1}' | sort
echo

echo "# === TRUE AUR / FOREIGN PACKAGES (explicit) ==="
echo "# These require yay (or another AUR helper) because they are not in any enabled repo."
pacman -Qemt | awk '{print $1}' | sort
echo

echo "# === ALL EXPLICIT PACKAGES (combined, for reference) ==="
pacman -Qe | awk '{print $1}' | sort
echo

cat <<'EOF' >&2
# Tips:
# - Pipe to a file: ./packages/list-current.sh > my-current-packages.txt
# - Compare with the curated lists in install.sh
# - Look for things you never use (big KDE apps, steam, IDEs, games, etc.)
# - Many packages in the foreign list may become pacman-installable once you add Chaotic-AUR.
EOF
