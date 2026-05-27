#!/usr/bin/env bash
#
# atuin/setup.sh
# One-time setup steps for Atuin on a new machine.
#
# TODO: Review and refine if setting up again on a fresh device.
# Not critical — you can improve the instructions later.
#
# Run this after:
#   ./packages/install.sh
#   dotctl install atuin
#
# This script handles the parts that can't (or shouldn't) be fully automated.

set -euo pipefail

echo "==> Atuin setup for new device"
echo

if ! command -v atuin >/dev/null 2>&1; then
    echo "Error: atuin is not installed. Run ./packages/install.sh first."
    exit 1
fi

echo "1. Importing existing shell history (if any)..."
if atuin history list --limit 1 >/dev/null 2>&1; then
    echo "   History already exists. Skipping import."
else
    atuin import auto || echo "   (import auto had no data or failed — this is usually fine)"
fi

echo
echo "2. Sync setup (optional but recommended)"
echo "   If you use Atuin sync, run one of the following:"
echo
echo "   - First time / new account:"
echo "     atuin register -u <username> -e <email>"
echo
echo "   - Existing account on new device:"
echo "     atuin login"
echo
echo "   After logging in, your history will sync automatically."
echo

echo "==> Atuin setup script finished."
echo "You can now use Ctrl+R (or your configured key) for enhanced history search."
