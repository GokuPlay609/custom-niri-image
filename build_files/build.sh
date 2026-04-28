#!/usr/bin/env bash
# Build hook for the custom uBlue niri + noctalia image.
# Runs inside the Containerfile build context.

set -ouex pipefail

###############################################################################
# 1. Repositories
###############################################################################

# Terra ships noctalia-shell (and the noctalia-qs Quickshell fork) for Fedora.
# https://docs.noctalia.dev/v4/getting-started/installation/#fedora
dnf5 install -y --nogpgcheck \
    --repofrompath "terra,https://repos.fyralabs.com/terra\$releasever" \
    terra-release

###############################################################################
# 2. Packages
###############################################################################

# niri (compositor) + noctalia-shell (Quickshell-based replacement for
# waybar/walker) + the runtime/optional deps documented in the noctalia docs
# and a usable baseline of CLI/Wayland tooling.
dnf5 install -y \
    niri \
    xwayland-satellite \
    noctalia-shell \
    brightnessctl \
    ImageMagick \
    python3 \
    git \
    ddcutil \
    power-profiles-daemon \
    NetworkManager \
    upower \
    bluez \
    cliphist \
    wlsunset \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    evolution-data-server \
    pipewire \
    wireplumber \
    pipewire-pulseaudio \
    polkit \
    polkit-gnome \
    grim \
    slurp \
    wl-clipboard \
    swayidle \
    swaylock \
    mako \
    foot \
    fuzzel \
    libnotify \
    fontawesome-fonts-all \
    google-noto-emoji-fonts \
    google-noto-sans-fonts \
    jetbrains-mono-fonts-all \
    stow

###############################################################################
# 3. Default user dotfiles -> /etc/skel
###############################################################################
# Anaconda copies /etc/skel into every newly-created user's $HOME. Stow-style
# packages from the source dotfiles repo are flattened in here so first boot
# yields a fully-configured niri + noctalia session.

install -d -m 0755 /etc/skel/.config

# niri config (kdl includes -> ./cfg/, ./animations/, noctalia.kdl)
cp -a /dotfiles/niri/.config/niri /etc/skel/.config/niri

# noctalia config (settings.json, colors.json, plugins/)
cp -a /dotfiles/noctalia/.config/noctalia /etc/skel/.config/noctalia

###############################################################################
# 4. System units
###############################################################################

# These should already be enabled in sericea-main but we ensure idempotently.
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable power-profiles-daemon.service
