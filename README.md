# DebianInit

Multi-platform personal machine initialization and bootstrap toolchain for Ubuntu, macOS (Apple Silicon), legacy Debian, and Windows / Cygwin.

Centralizes environment provisioning across servers, single-board computers (e.g. Orange Pi / Raspberry Pi), personal Macs, and Windows workstations with a unified toolchain philosophy: **uv** for user-space Python, modern CLI utilities, [grapeot/.dotfiles](https://github.com/grapeot/.dotfiles) integration, oh-my-zsh, and Git identity `Yan Wang <grapeot@outlook.com>` on Ubuntu, macOS, and Cygwin (legacy Debian 7 uses `grapeot@gmail.com`).

---

## Repository Map

| Path | Target Platform | Execution Model | Description |
|---|---|---|---|
| `setup_ubuntu.sh` | **Ubuntu Linux** (22.04+ / Debian-like, x86_64 & aarch64) | Idempotent CLI script | Modern Linux server / SBC bootstrap (apt packages, uv, oh-my-zsh, rupa/z, dotfiles, git config, zsh default shell, verification). |
| `mac/setup.sh` | **macOS** (Apple Silicon `arm64`) | 5-stage pipeline | Master orchestrator: bootstrap → TUI apps (may call `davinci.sh`) → DaVinci presence check (does **not** invoke `davinci.sh`) → verify. Darwin/`arm64` guard lives here only. |
| `mac/bootstrap.sh` | macOS (`arm64`) | Standalone / Stage 1 | Unconditional base layer: Xcode CLT, Homebrew, gum, uv, core CLI formulae, Meslo Nerd Font, mas-cli, oh-my-zsh, git config, dotfiles, system preferences. No Darwin/`arm64` guard of its own. |
| `mac/apps.sh` | macOS (`arm64`) | Standalone / Stage 2+3 | Interactive multi-select TUI: 25 GUI items (23 brew casks + DaVinci handler + Antigravity Tools GitHub DMG), 11 CLI formulae + rustup, 3 App Store apps. |
| `mac/davinci.sh` | macOS (`arm64`) | Standalone / called from `apps.sh` | Automated DaVinci Resolve downloader and installer via Blackmagic API registration flow. `setup.sh` Stage 4 does not run this script. |
| `mac/verify.sh` | macOS (`arm64`) | Standalone / Stage 5 | Comprehensive post-install verification of CLI binaries, GUI apps, dotfiles, git config, and preferences. |
| `setup_debian.sh` | **Debian 7** (Legacy x86_64) | Single-run desktop script | Historical Debian 7 server-to-desktop setup (apt sources unstable, XFCE4, SSH port 30, Chrome / Dropbox deb downloads, QuickTile). |
| `setup_windows.ps1` | **Windows** (PowerShell) | PowerShell script | Windows bootstrap: Chocolatey, git, Cygwin installer invocation, and dotfiles symlink setup. |
| `cygwin.sh` | **Cygwin** | Cygwin zsh script | Cygwin environment setup invoked by `setup_windows.ps1` (oh-my-zsh, rupa/z, dotfiles, SSH host config). |
| `quicktile.cfg` | Linux X11 | Config file | Keyboard-driven window tiling configuration for QuickTile (used by `setup_debian.sh`). |
| `docs/dev_mac.md` | macOS | Specification / Prompt Layer | Generative Kernel specification, complete app inventory, cask mappings, and design rationale. |
| `docs/working.md` | All | Documentation | Architectural changelogs, lessons learned, and maintenance notes. |

---

## 1. Ubuntu Linux

Recommended for modern Ubuntu server installations, cloud instances, and ARM single-board computers (e.g. Orange Pi Zero 3W, Raspberry Pi).

### Quick Start

```bash
cd DebianInit
./setup_ubuntu.sh
```

### Execution Details & Idempotency

`setup_ubuntu.sh` is guarded by `set -euo pipefail` and is designed to be **safe to re-run**:

1. **Apt Packages (`sudo`)**: Installs core utilities:
   - Editors & Shell: `vim`, `zsh`, `tmux`
   - Version Control & Development: `git`, `tig`, `build-essential`, `pkg-config`
   - File & Network Utilities: `curl`, `wget`, `rsync`, `htop`, `zip`, `unzip`, `dos2unix`, `parallel`, `trash-cli`
2. **Python Toolchain (`uv`)**: Installs `uv` via the official standalone script (`UV_NO_MODIFY_PATH=1` to preserve dotfiles symlinks). Distro system Python is untouched. The current-session `PATH` includes both `~/.local/bin` and `~/.cargo/bin`.
3. **Environment Setup**: Appends `export PATH="$HOME/.local/bin:$PATH"` to `~/.zshenv` if that file does not already mention `.local/bin`. Does **not** persist `~/.cargo/bin` in `~/.zshenv`.
4. **Shell & Navigation**:
   - Installs [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) via the official unattended installer if `~/.oh-my-zsh` is not already a directory (directory-only check; does not inspect `oh-my-zsh.sh`).
   - Clones [rupa/z](https://github.com/rupa/z) to `~/z` if not present.
5. **Dotfiles Deployment**: Clones [grapeot/.dotfiles](https://github.com/grapeot/.dotfiles) to `~/.dotfiles` if missing, then always executes `deploy_linux.sh` (backs up `.vimrc`, `.zshrc`, `.tmux.conf` to `.bak` and creates symlinks).
6. **Git Identity**: Sets global Git configuration:
   - `user.name` = `Yan Wang`
   - `user.email` = `grapeot@outlook.com`
   - `push.default` = `simple`, `color.ui` = `auto`, `core.fileMode` = `false`
7. **Login Shell**: Changes the user default shell via `chsh -s "$(command -v zsh)"` (skipped if already zsh). Does not hardcode `/usr/bin/zsh`. Does **not** change SSH port 22.
8. **Automated Verification**: Verifies presence of `zsh`, `git`, `tmux`, `uv`, and `trash-put`.

> **Note on SBC / Vendor OS Images**:
> Some vendor Linux distributions (e.g. certain Orange Pi / Armbian images) populate a stub directory at `~/.oh-my-zsh` containing only `cache/`. `setup_ubuntu.sh` treats any existing `~/.oh-my-zsh` directory as installed and will skip the official installer. In this scenario, move the stub aside (`mv ~/.oh-my-zsh ~/.oh-my-zsh.bak`) and re-run the script (or `git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh`).

---

## 2. macOS (Apple Silicon `arm64`)

The macOS initialization toolchain follows the **Generative Kernel** architecture: combining an unconditional deterministic foundation with interactive user selection and automated API fallbacks.

### Quick Start

```bash
cd DebianInit
./mac/setup.sh
```

### Execution Pipeline

```
mac/setup.sh (Darwin arm64 only)
  ├── Stage 1: mac/bootstrap.sh  (Critical base layer — aborts on failure)
  ├── Stage 2+3: mac/apps.sh    (Interactive TUI — continues on partial failure; calls davinci.sh if DaVinci is selected)
  ├── Stage 4: DaVinci presence check (does not invoke davinci.sh; warns to run it separately if missing)
  └── Stage 5: mac/verify.sh    (Comprehensive post-installation health check)
```

Each stage script can also be executed independently:

- **`mac/bootstrap.sh`**:
  - Installs Xcode Command Line Tools (`xcode-select --install`).
  - Installs Homebrew (`/opt/homebrew`) and adds it to PATH.
  - Installs `gum` (charmbracelet TUI engine).
  - Installs `uv` standalone toolchain (`curl -LsSf https://astral.sh/uv/install.sh | sh`, no `UV_NO_MODIFY_PATH`; PATH export is session-only).
  - Installs core CLI formula suite: `coreutils`, `wget`, `tmux`, `ripgrep`, `htop`, `btop`, `macmon`, `p7zip`, `rsync`, `nmap`, `shellcheck`, `tig`, `socat`, `gh`, `git-lfs`, `exiftool`, `neovim`, `fd`, `lazygit`, `zellij`.
  - Installs `font-meslo-lg-nerd-font` (cask) and `mas` (formula; mas-cli).
  - Configures oh-my-zsh (official unattended installer; directory-only check), Git identity (`Yan Wang <grapeot@outlook.com>`; also `push.default=simple`, `color.ui=auto`, `core.fileMode=false`), and — only if `~/.dotfiles` is absent — clones grapeot/.dotfiles and runs `deploy_mac.sh`.
  - Sets macOS preference `DSDontWriteNetworkStores = TRUE` (prevents `.DS_Store` clutter on network drives).
- **`mac/apps.sh`**:
  - Interactive multi-select dialogs powered by `gum choose` (all items pre-selected by default; deselect to skip).
  - **GUI Applications (25 items: 23 brew casks + DaVinci special handler + Antigravity Tools GitHub DMG)**: Claude, ChatGPT, ChatGPT Atlas, Cursor, Codex, LM Studio, Ollama, VS Code, Android Studio, Docker Desktop, iTerm2, Telegram, Zoom, DaVinci Resolve, Gyroflow, BambuStudio, OpenSCAD, Roon, Tailscale (standalone), Windows App, 1Password, Firefox, Rectangle, Antigravity, Antigravity Tools (GitHub Release DMG from `lbjlaq/Antigravity-Manager`).
  - **CLI Tools & Compilers (11 formulae + rustup)**: `ffmpeg`, `sox`, `zbar`, `pandoc`, `marp-cli`, `borgbackup`, `cmake`, `go`, `swig`, `astrometry-net`, `argyll-cms`, and **Rust** via official `rustup.rs` (`sh -s -- -y`).
  - **App Store via `mas`**: Compressor (ID: `424390742`), Photomator (ID: `1444636541`), Xcode (opens `macappstore://apps.apple.com/app/id497799835` for manual installation; not installed via `mas`).
- **`mac/davinci.sh`** (called from `apps.sh` when selected; **not** invoked by `setup.sh` Stage 4):
  - Programmatically interacts with Blackmagic Design API (`GET /api/support/latest-stable-version/davinci-resolve/mac` and `POST /api/register/us/download/{downloadId}`) to retrieve a time-limited signed URL for DaVinci Resolve (~6.5 GB `.dmg` / `.zip` / `.pkg`), downloads it with single-threaded `curl`, and `open`s the file (does not unzip). Falls back to `open https://www.blackmagicdesign.com/products/davinciresolve` on API failure.
- **`mac/verify.sh`**:
  - Checks core CLI binaries (`brew`, `git`, `nvim`, `tmux`, `rg`, `fd`, `lazygit`, `gh`, `zellij`, `gum`, `uv`), a fixed optional `/Applications` list, `DSDontWriteNetworkStores`, existence of `~/.dotfiles` and `~/.oh-my-zsh` directories, and Git `user.name` / `user.email`.

For detailed rationale, cask name mappings, and Tailscale configuration rules, refer to [`docs/dev_mac.md`](docs/dev_mac.md).

---

## 3. Windows & Cygwin

Provides a Unix-like CLI environment on Windows workstations.

### Windows Host Setup

From an elevated PowerShell session:

```powershell
# Execute the automated Windows setup script
.\setup_windows.ps1
```

The script performs (actual order):
1. Downloads the official Cygwin 64-bit installer (`setup-x86_64.exe`) and fetches `cygwin.sh` from the GitHub `master` branch (overwrites any local copy).
2. Installs [Chocolatey](https://chocolatey.org/) and then `git` via Chocolatey.
3. Runs the Cygwin installer with base packages: `vim`, `openssh`, `rsync`, `gcc-g++`, `make`, `wget`, `curl`, `dos2unix`, `tig`, `zsh`, `tmux`.
4. Configures `/etc/passwd` so the user home is `/cygdrive/c/Users/<User>` and the shell is `zsh`.
5. Launches `cygwin.sh` inside the Cygwin environment.
6. Installs `7zip`, `vim`, and `python3` via Chocolatey, then bootstraps pip via `get-pip.py` using the hardcoded path `C:\Python36\python.exe`.
7. Creates NTFS symlinks for `.vim`, `.vimrc`, and `.zshrc` using Windows `kernel32.dll!CreateSymbolicLink`.

### Cygwin Environment (`cygwin.sh`)

- Installs oh-my-zsh and clones `rupa/z`.
- Clones `.dotfiles` and links `.tmux.conf` (disables powerline for Windows terminal compatibility).
- Sets global Git identity (`Yan Wang <grapeot@outlook.com>`).
- Rewrites SSH daemon `Port 22` → `Port 30` (reads `/etc/sshd_config`, writes `/etc/ssh/sshd_config`) and runs `ssh-host-config`.
- Does not set `push.default` or `core.fileMode` (only `user.name`, `user.email`, `color.ui`).

---

## 4. Legacy Debian 7 (`setup_debian.sh`)

> ⚠️ **Historical Reference Only**:
> `setup_debian.sh` was written for clean Debian 7 ("Wheezy") server installations from 2013. It is not idempotent and should **not** be executed on modern Debian/Ubuntu releases or ARM hardware.

```bash
su
apt-get install sudo git
git clone https://github.com/grapeot/DebianInit
visudo   # grant sudo privilege
exit
cd DebianInit
./setup_debian.sh | tee logs
```

Actions performed by the legacy script:
- Modifies `/etc/apt/sources.list` pointing from `wheezy` to `unstable` (`main contrib non-free`).
- Installs XFCE4 desktop environment, fonts, Adwaita theme, and audio stack (`pulseaudio`). Does not install a display manager; ends with `startx`.
- Modifies SSH daemon port from 22 to 30 (`/etc/ssh/sshd_config`).
- Sets Git identity to `Yan Wang <grapeot@gmail.com>` (historical; other platforms use `grapeot@outlook.com`).
- Downloads and installs `amd64` Debian packages for Google Chrome (`google-chrome-stable_current_amd64.deb`) and Dropbox (`dropbox_1.6.0_amd64.deb`).
- Compiles and installs QuickTile (window tiling helper, not a window manager) from source and copies `quicktile.cfg` to `~/.config`.
- Switches default login shell to `zsh` via `chsh -s $(which zsh)` and starts X11 via `startx`.

---

## License & Maintenance

Maintained by [Yan Wang (grapeot)](https://github.com/grapeot). Licensed under MIT or public domain where applicable.
