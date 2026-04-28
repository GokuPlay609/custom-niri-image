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
# Bluefin already provides pipewire, NetworkManager, polkit, xdg-desktop-portal*,
# upower, bluez, ImageMagick, python3, git, etc. The list below intentionally
# only adds what's missing or compositor-specific. We use --skip-unavailable so
# the build keeps going if Fedora renames/drops a package upstream.
#
# Notes:
#   - power-profiles-daemon is omitted because Bluefin ships tuned-ppd which
#     provides the same ppd-service dbus interface (they conflict).
#   - polkit-gnome is omitted (the noctalia polkit-agent plugin in dotfiles
#     handles auth prompts inside niri sessions).
dnf5 install -y --skip-unavailable \
    niri \
    xwayland-satellite \
    noctalia-shell \
    ghostty \
    brightnessctl \
    ddcutil \
    cliphist \
    wlsunset \
    grim \
    slurp \
    wl-clipboard \
    swayidle \
    swaylock \
    mako \
    foot \
    fuzzel \
    fontawesome-fonts-all \
    google-noto-emoji-fonts \
    google-noto-sans-fonts \
    jetbrains-mono-fonts-all \
    stow

###############################################################################
# 2b. CaskaydiaCove Nerd Font
###############################################################################
# Pulled directly from the upstream Nerd Fonts release because Fedora does not
# ship a CaskaydiaCove rpm. Pinned to a stable tag and installed system-wide.

NF_VERSION="v3.4.0"
NF_TMP="$(mktemp -d)"
curl -fsSL -o "$NF_TMP/CascadiaCode.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/${NF_VERSION}/CascadiaCode.zip"
install -d -m 0755 /usr/share/fonts/CaskaydiaCoveNF
( cd "$NF_TMP" && unzip -qo CascadiaCode.zip 'CaskaydiaCove*.ttf' -d /usr/share/fonts/CaskaydiaCoveNF )
fc-cache -f /usr/share/fonts/CaskaydiaCoveNF
rm -rf "$NF_TMP"

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

# ghostty config + themes
cp -a /dotfiles/ghostty/.config/ghostty /etc/skel/.config/ghostty

###############################################################################
# 4. System units
###############################################################################
# Bluefin already enables NetworkManager, bluetooth, and tuned-ppd. Nothing
# extra to enable here.
