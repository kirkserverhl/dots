#!/bin/bash

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

# Ensure .ssh directory exists
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Check for existing SSH keys
if ls -al "$SSH_DIR" | grep -q "id_"; then
	echo "An existing SSH key is found."
	if [ -f "$SSH_KEY.pub" ]; then
		echo "Would you like to copy the SSH public key to the clipboard? (y/n)"
		read -r copy_key
		if [[ "$copy_key" =~ ^[Yy]$ ]]; then
			cat "$SSH_KEY.pub" | wl-copy 2>/dev/null || xclip -selection clipboard 2>/dev/null || pbcopy
			echo "SSH key copied to clipboard."
		fi
	else
		echo "No public key found at $SSH_KEY.pub"
	fi
else
	echo "No SSH key found. Generating a new one..."
	ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$SSH_KEY" -N ""
	eval "$(ssh-agent -s)"
	ssh-add "$SSH_KEY"
	cat "$SSH_KEY.pub" | wl-copy 2>/dev/null || xclip -selection clipboard 2>/dev/null || pbcopy
	echo "New SSH key generated and copied to clipboard."
fi

# Offer to open GitHub SSH settings
echo ""
read -rp "Open GitHub SSH key settings in browser? [y/N] " open_github
if [[ "$open_github" =~ ^[Yy]$ ]]; then
    xdg-open "https://github.com/settings/keys" 2>/dev/null || firefox "https://github.com/settings/keys" 2>/dev/null || echo "Please visit: https://github.com/settings/keys"
else
    echo "You can manually add the key at: https://github.com/settings/keys"
fi
