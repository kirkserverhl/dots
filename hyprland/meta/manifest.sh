export requires=(theming)
export pacman_deps=(
    firefox
    brightnessctl
    cliphist
    curl
    jq
    pinentry
    rbw
    wl-clipboard
    wtype
    hyprpolkitagent
    hyprland
    hyprsunset
    hyprpicker
    grim slurp
    ttf-material-symbols-variable
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-kde
    pipewire wireplumber pipewire-pulse

    # Dolphin file manager + minimal KDE integration (kept because user still uses Dolphin)
    dolphin ark baloo dolphin-plugins
    ffmpegthumbs icoutils kdegraphics-thumbnailers
    kimageformats libappimage qt6-imageformats resvg taglib
)
export aur_deps=(
    bibata-cursor-theme-bin
    wvkbd-git
    hyprpm          # or hyprpm-bin / whatever package name you use for hyprpm
)
