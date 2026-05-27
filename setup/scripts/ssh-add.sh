#!/bin/bash
#
# Simple helper to add your SSH key to the agent.

set -euo pipefail

KEY="$HOME/.ssh/id_ed25519"

if [ ! -f "$KEY" ]; then
    echo "No SSH key found at $KEY"
    echo "Run 'dots-welcome' and choose SSH & GitHub → Generate new SSH key first."
    exit 1
fi

echo "Starting ssh-agent and adding key..."
eval "$(ssh-agent -s)"
ssh-add "$KEY"

echo "Key added to ssh-agent."
