# Working Notes

Unified notes, architecture evolution, changelogs, and operational lessons across all supported operating systems (`setup_ubuntu.sh`, `mac/`, `setup_debian.sh`, `setup_windows.ps1`).

---

## Architecture & Layout

- **Linux (Modern)**: `setup_ubuntu.sh` — Idempotent CLI bootstrap with `uv`, `.dotfiles`, and fail-fast `set -euo pipefail`. Git: `Yan Wang <grapeot@outlook.com>`. Does **not** change SSH port 22.
- **macOS (Apple Silicon)**: `mac/setup.sh` orchestrates `bootstrap.sh` (base) → `apps.sh` (TUI selection; calls `davinci.sh` if DaVinci is chosen) → DaVinci **presence check** (does not invoke `davinci.sh`) → `verify.sh` (audit). Darwin/`arm64` guard is only in `setup.sh`. Git: `Yan Wang <grapeot@outlook.com>`.
- **macOS Generative Kernel Spec**: `docs/dev_mac.md` — Prompt and decision layer for AI Agents managing Mac setups.
- **Legacy Linux**: `setup_debian.sh` — 2013 Debian 7 XFCE desktop setup (renamed from `setup.sh`). Git: `Yan Wang <grapeot@gmail.com>`. SSH `22 → 30`.
- **Windows / Cygwin**: `setup_windows.ps1` (elevated PowerShell) + `cygwin.sh`. Cygwin git: `Yan Wang <grapeot@outlook.com>`. SSH `22 → 30`.

---

## Changelog

### 2026-08-24
- **Documentation Architecture Overhaul**: Fully rewrote `README.md` and `docs/dev_mac.md` to align with the active 2026 repository state.
- **Debian Entry Point Renaming**: Renamed `setup.sh` → `setup_debian.sh` to prevent confusion with the modern Ubuntu script. Updated all README commands.
- **Cygwin Entry Point Fix**: Removed references to nonexistent `cgywin.cmd`, pointing explicitly to `setup_windows.ps1`.
- **Vendor Image Edge-Case Note**: Documented the empty `~/.oh-my-zsh` stub bug on SBC images (e.g. Orange Pi / Armbian). `setup_ubuntu.sh` and `mac/bootstrap.sh` still treat any existing `~/.oh-my-zsh` **directory** as installed; they do not check for `oh-my-zsh.sh`.
- **Mac Generative Kernel Alignment**: Aligned `docs/dev_mac.md` with `mac/apps.sh` and `mac/bootstrap.sh` (Apple Silicon only, `zellij`, `rectangle` cask, GitHub Release DMG for Antigravity Tools, `rustup.rs` installer).
- **Documentation Fact-Check**: Corrected Stage 4 (`setup.sh` does not call `davinci.sh`), Windows/Cygwin execution order, Debian 7 git email (`grapeot@gmail.com`), TUI counts (23 casks + 2 special GUI items; 11 formulae + rustup), Ubuntu oh-my-zsh installer vs clone, `chsh` path, and single-threaded DaVinci `curl` download.

### 2026-08-23
- **Ubuntu Bootstrap Modernization**: Made `setup_ubuntu.sh` strictly idempotent (`set -euo pipefail`, skipping existing oh-my-zsh / z / dotfiles / chsh).
- **Python Toolchain to `uv`**: Dropped distro `pip3`/`virtualenv` in favor of standalone `uv` with `UV_NO_MODIFY_PATH=1`. Exported `~/.local/bin` via `~/.zshenv`.
- **Package Cleanups**: Switched `trash-cli` to distro package manager, removed automatic SSH `22 → 30` port reassignment on Ubuntu.

### 2026-03-21
- **Rust via Official Rustup**: Added optional `rustup.rs` installer (`sh.rustup.rs -y`) into `mac/apps.sh` and `mac/verify.sh` with `~/.cargo/env` PATH verification.

### 2026-03-16
- **Mac 5-Stage Architecture**: Implemented 5 modular stages under `mac/` (`bootstrap.sh`, `apps.sh`, `davinci.sh`, `verify.sh`, `setup.sh`).
- **DaVinci Resolve Reverse Engineering**: Reverse-engineered Blackmagic API registration flow to enable programmatic downloads of 6.5GB installers with dynamic time-limited signature tokens.
- **Tailscale Standalone Decision**: Enforced `tailscale-app` cask over Mac App Store to bypass Screen Time web filter blocks and enable full CLI capabilities (`tailscale ssh`).
- **TUI Selection Engine**: Integrated charmbracelet `gum` for multi-select terminal interfaces.

---

## Lessons Learned & Operational Notes

1. **Cask vs Formula Naming Discrepancies**:
   - `brew install --cask tailscale` does not exist; the standalone cask is `tailscale-app`.
   - `ollama-app` is the GUI client, whereas `ollama` is the CLI formula.
   - `docker-desktop` is the GUI app, whereas `docker` is the CLI formula.
   - `codex` is the CLI binary; `codex-app` is the GUI application.
2. **DaVinci Resolve API Tokens**:
   - The `verify=` parameter in Blackmagic download URLs embeds a Unix timestamp that expires rapidly. URLs must be dynamically generated on the fly and never hardcoded.
3. **App Store Tailscale Sandbox Quarantine**:
   - Mac App Store Tailscale cannot bind to system network extensions properly under Screen Time filters and lacks CLI capabilities. Migrations from App Store to standalone require deleting the app, emptying the Trash, and rebooting macOS before installing `tailscale-app`.
4. **Non-Interactive Shell Paths**:
   - Shell configuration must not assume standard interactive terminal PATHs. `uv` and `cargo` paths should be declared in `~/.zshenv` or exported explicitly in bootstrap wrappers.
   - Actual scripts: `setup_ubuntu.sh` persists only `~/.local/bin` in `~/.zshenv` (session `PATH` also includes `~/.cargo/bin`). `mac/bootstrap.sh` exports both paths for the current session only and does not write `~/.zshenv`.
