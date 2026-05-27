export requires=(foot theming)
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
    quickshell
    ttf-material-symbols-variable
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-kde
    pipewire wireplumber pipewire-pulse

    # Dolphin file manager + KDE integration / thumbnailers (still used)
    dolphin ark audiocd-kio baloo dolphin-plugins kio-admin kompare konsole
    ffmpegthumbs icoutils kdegraphics-thumbnailers kdesdk-thumbnailers
    kimageformats libappimage qt6-imageformats resvg taglib
    kdeconnect
)
export aur_deps=(
    bibata-cursor-theme-bin
    wvkbd-git
)
