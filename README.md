# custom-niri-image

A personal [bootc](https://github.com/bootc-dev/bootc) / Universal Blue image
that ships the [niri](https://github.com/YaLTeR/niri) Wayland scrolling
compositor together with the [Noctalia](https://docs.noctalia.dev) Quickshell
shell (replaces waybar / walker / mako etc.) and my dotfiles preinstalled.

Built daily and signed via [cosign](https://docs.sigstore.dev/cosign/overview/).

| | |
|---|---|
| Image | `ghcr.io/gokuplay609/custom-niri-image:latest` |
| Base | `ghcr.io/ublue-os/sericea-main:stable` |
| Compositor | [niri](https://github.com/YaLTeR/niri) |
| Shell | [noctalia-shell](https://docs.noctalia.dev) (Quickshell-based) |

## Layout

```
.
├── Containerfile               # FROM sericea-main:stable + run build.sh
├── build_files/build.sh        # installs niri, noctalia, deps, dotfiles
├── dotfiles/                   # copied verbatim into /etc/skel
│   ├── niri/.config/niri/...
│   └── noctalia/.config/noctalia/...
├── disk_config/                # bootc-image-builder configs (qcow2 / ISO)
├── .github/workflows/
│   ├── build.yml               # daily build + sign + push to GHCR
│   └── build-disk.yml          # on-demand qcow2 / anaconda-ISO builds
└── cosign.pub                  # public verification key
```

## Switch an existing bootc system to this image

```sh
sudo bootc switch ghcr.io/gokuplay609/custom-niri-image:latest
sudo systemctl reboot
```

Verify the signature beforehand if desired:

```sh
cosign verify \
  --key https://raw.githubusercontent.com/GokuPlay609/custom-niri-image/main/cosign.pub \
  ghcr.io/gokuplay609/custom-niri-image
```

## Building a fresh ISO / qcow2

The `Build disk images` workflow (`build-disk.yml`) is `workflow_dispatch`-only.
Trigger it from the **Actions** tab and pick `amd64` or `arm64` — artifacts are
attached to the workflow run.

## Auto-build schedule

`build.yml` runs:
- on every push to `main` (except README-only changes)
- on every PR targeting `main`
- daily at **10:05 UTC** (`cron: '05 10 * * *'`)
- manually via **Run workflow**

The image is signed with the cosign key stored in the `SIGNING_SECRET` repo
secret on each successful main-branch build.

## Updating the dotfiles

The `dotfiles/` directory in this repo is the source of truth used at build
time. To pull in latest changes from `~/dotfiles`:

```sh
rsync -a --delete ~/dotfiles/niri/     ./dotfiles/niri/
rsync -a --delete ~/dotfiles/noctalia/ ./dotfiles/noctalia/
git add dotfiles && git commit -m "dotfiles: sync"
git push
```

The next daily/push build will bake them into `/etc/skel`, so any newly
created user gets the configs automatically.

## Acknowledgements

Forked from the upstream
[ublue-os/image-template](https://github.com/ublue-os/image-template).
