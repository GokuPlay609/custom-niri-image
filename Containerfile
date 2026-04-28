# Allow build scripts and assets to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY dotfiles /dotfiles
# (After the bind mount in the next stage, build.sh sees these at /ctx/dotfiles)

# Base image: Bluefin (GNOME-based ublue image, actively maintained, ships
# gdm + pipewire + xdg portals + NetworkManager out of the box). niri is
# installed alongside and will appear as an additional Wayland session in gdm.
FROM ghcr.io/ublue-os/bluefin:stable

### MODIFICATIONS
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
RUN bootc container lint
