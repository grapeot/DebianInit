# DebianInit

Personal machine bootstrap for Ubuntu, macOS (Apple Silicon), legacy Debian, and Windows/Cygwin. Shared pieces are [grapeot/.dotfiles](https://github.com/grapeot/.dotfiles), oh-my-zsh, `rupa/z`, and git identity `Yan Wang <grapeot@outlook.com>` (the old Debian script still writes `grapeot@gmail.com`).

| Path | Role |
|---|---|
| `setup_ubuntu.sh` | Current Linux path. Idempotent Ubuntu CLI bootstrap. Safe to re-run. |
| `mac/setup.sh` | Current Mac path. Apple Silicon only. Orchestrates bootstrap → apps → verify. |
| `setup_debian.sh` | Historical Debian 7 XFCE desktop. Not for modern Ubuntu or ARM boards. |
| `setup_windows.ps1` + `cygwin.sh` | Windows + Cygwin. |
| `docs/dev_mac.md` | Mac agent kernel: inventory, cask names, known pits. |
| `docs/working.md` | Changelog and lessons. |

Python for development is **uv**. Distro `python3` is left alone; do not `pip install` into it.

## Ubuntu

```bash
cd DebianInit
./setup_ubuntu.sh
```

Needs `sudo` and may prompt for `chsh`. Does **not** change the SSH port or install a desktop.

It will:

1. `apt-get install` vim, zsh, git, wget, dos2unix, parallel, tig, build-essential, curl, htop, rsync, tmux, zip, unzip, pkg-config, trash-cli
2. Install **uv** via the official installer (`UV_NO_MODIFY_PATH=1` so it does not rewrite the `.zshrc` symlink). Binary lands in `~/.local/bin` or `~/.cargo/bin`
3. Put `~/.local/bin` on PATH via `~/.zshenv`
4. Install oh-my-zsh unless `~/.oh-my-zsh` already exists
5. Clone `rupa/z` to `~/z` if missing
6. Clone `.dotfiles` and run `deploy_linux.sh` (backs up `.zshrc` / `.vimrc` / `.tmux.conf` and replaces them with symlinks)
7. Apply git config and set the login shell to zsh
8. Verify `zsh`, `git`, `tmux`, `uv`, `trash-put`

`set -euo pipefail`: if `apt-get install` fails, the script stops. Already-installed packages are skipped.

Some vendor images (for example Orange Pi) create an empty `~/.oh-my-zsh` with only `cache/`. The directory check then skips the real install, and the prompt stays a raw `zsh` `%`. If `~/.oh-my-zsh/oh-my-zsh.sh` is missing, move the stub aside and clone [ohmyzsh/ohmyzsh](https://github.com/ohmyzsh/ohmyzsh) into `~/.oh-my-zsh`.

## macOS (Apple Silicon)

```bash
cd DebianInit
./mac/setup.sh
```

Requires Darwin + `arm64`. Intel Macs are rejected. Stages can also be run alone: `mac/bootstrap.sh`, `mac/apps.sh`, `mac/davinci.sh`, `mac/verify.sh`.

`bootstrap.sh` is unconditional: Xcode CLT, Homebrew (`/opt/homebrew`), gum, uv, core formulae (including zellij), Meslo Nerd Font, mas-cli, oh-my-zsh, git config, `.dotfiles` via `deploy_mac.sh`, `DSDontWriteNetworkStores`.

`apps.sh` is a gum TUI (everything pre-selected; deselect to skip): brew casks, extra formulae, rustup, and App Store apps via mas. DaVinci Resolve uses `davinci.sh` (Blackmagic API; tokenized URL, do not hardcode). See `docs/dev_mac.md` for cask names and pitfalls.

## Debian 7 (legacy)

For an old Debian 7 server **without** a desktop. Do not run this on Ubuntu or ARM.

```bash
su
apt-get install sudo git
git clone https://github.com/grapeot/DebianInit
visudo   # grant sudo
exit
cd DebianInit
./setup_debian.sh | tee logs
```

This script is not idempotent. It rewrites apt sources to unstable, maps SSH **22 → 30**, installs XFCE and related desktop packages, and tries to download **amd64** Chrome / Dropbox debs.

## Windows / Cygwin

There is no `cgywin.cmd`. Entry point is the PowerShell script:

```powershell
# from a copy of this repo, or after downloading setup_windows.ps1
.\setup_windows.ps1
```

It installs Chocolatey + git, runs the official Cygwin `setup-x86_64.exe`, then executes `cygwin.sh` inside Cygwin. `cygwin.sh` still changes sshd to port 30 and expects Cygwin at `C:\cygwin64`.
