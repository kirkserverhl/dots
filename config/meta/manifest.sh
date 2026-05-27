# Unified config package
# Contains almost everything under ~/.config/
# This is the simple "drop a folder in here and it gets stowed" approach the user prefers.

export requires=(theming)

# Most of these are already declared in their own small packages or in packages/install.sh
# We keep this light because the heavy lifting is done by the individual manifests + install.sh
export pacman_deps=()
export aur_deps=()
