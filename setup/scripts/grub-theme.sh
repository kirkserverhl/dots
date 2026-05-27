#!/bin/bash
#
# GRUB Theme Setup
# This is a basic helper. It installs the Tartarus GRUB theme and guides you
# through setting it as default.
#
# For a more complete experience with multiple theme choices, consider using
# the full sddm-theme.sh / Chris Titus GRUB installer instead.

set -euo pipefail

THEME_NAME="tartarus"
THEME_DIR="/usr/share/grub/themes"

echo "=== GRUB Theme Setup ==="
echo "This will install the '$THEME_NAME' GRUB theme."

if ! command -v git >/dev/null; then
    echo "Error: git is not installed."
    exit 1
fi

echo "Cloning Tartarus GRUB theme..."
git clone https://github.com/AllJavi/tartarus-grub.git /tmp/tartarus-grub

echo "Installing theme to $THEME_DIR..."
sudo mkdir -p "$THEME_DIR"
sudo cp -r /tmp/tartarus-grub/tartarus "$THEME_DIR/"

echo ""
echo "Theme installed."
echo "You now need to edit /etc/default/grub and set:"
echo "  GRUB_THEME=\"$THEME_DIR/$THEME_NAME/theme.txt\""
echo ""

read -rp "Open /etc/default/grub in your editor now? [y/N] " open_editor
if [[ "$open_editor" =~ ^[Yy]$ ]]; then
    ${EDITOR:-nano} /etc/default/grub
fi

echo ""
echo "Updating GRUB config..."
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo ""
echo "Done. Reboot to see the new GRUB theme."

# Cleanup
rm -rf /tmp/tartarus-grub
