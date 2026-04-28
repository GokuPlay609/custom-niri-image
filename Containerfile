# Allow build scripts and assets to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY dotfiles /dotfiles

# Base image: ublue sericea-main is the closest match for niri (Wayland tiling
# compositor stack with greetd/tuigreet, pipewire, xdg-portals, NetworkManager,
# etc., already configured) without the bloat of GNOME/KDE.
FROM ghcr.io/ublue-os/sericea-main:stable

### MODIFICATIONS
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
RUN bootc container lint
