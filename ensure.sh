#!/usr/bin/env bash
#
# ensure.sh
# Quick entry point after cloning the repo on a new machine (or after git pull).
#
# This is intentionally tiny. It just makes sure packages are present.
# Real config deployment happens via `dotctl`.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Ensuring required packages..."
"$REPO_DIR/packages/install.sh" --with-chaotic "$@"

echo
echo "==> Done. Next steps:"
echo "    $REPO_DIR/dotctl/.local/bin/dotctl install dotctl"
echo "    dotctl install all"
echo
echo "See bootstrap/README.md for the full multi-machine workflow."
