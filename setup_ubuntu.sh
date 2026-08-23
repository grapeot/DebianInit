#!/usr/bin/env bash
# Ubuntu CLI bootstrap. Idempotent: safe to re-run.
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; RESET='\033[0m'
info()    { printf "${GREEN}✓${RESET}  %s\n" "$*"; }
warn()    { printf "${YELLOW}⚠${RESET}  %s\n" "$*"; }
error()   { printf "${RED}✗${RESET}  %s\n" "$*" >&2; }
section() { printf "\n${GREEN}═══ %s ═══${RESET}\n" "$*"; }

# uv lives here; keep it on PATH for this run and for later zsh sessions
# via ~/.zshenv (not .zshrc — that file is a symlink into .dotfiles).
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# ── 1. Packages ──────────────────────────────────────────────────────────────
section "apt packages"
sudo apt-get update
sudo apt-get install -y -q \
    vim zsh git wget dos2unix parallel tig build-essential curl \
    htop rsync tmux zip unzip pkg-config trash-cli
info "apt packages up to date"

# ── 2. uv (user-space Python toolchain) ──────────────────────────────────────
section "uv"
if command -v uv &>/dev/null; then
    info "uv already installed: $(uv --version)"
else
    warn "Installing uv..."
    # Do not let the installer rewrite ~/.zshrc (symlink to .dotfiles).
    curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
    if command -v uv &>/dev/null; then
        info "uv installed: $(uv --version)"
    else
        error "uv installed but not on PATH (expected ~/.local/bin)"
        exit 1
    fi
fi

zshenv="$HOME/.zshenv"
local_bin_line='export PATH="$HOME/.local/bin:$PATH"'
if [[ -f "$zshenv" ]] && grep -qF '.local/bin' "$zshenv"; then
    info "~/.zshenv already adds ~/.local/bin"
else
    printf '\n%s\n' "$local_bin_line" >> "$zshenv"
    info "Added ~/.local/bin to ~/.zshenv"
fi

# ── 3. oh-my-zsh ─────────────────────────────────────────────────────────────
section "oh-my-zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    info "oh-my-zsh already installed"
else
    warn "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    info "oh-my-zsh installed"
fi

# ── 4. z ─────────────────────────────────────────────────────────────────────
section "z"
if [[ -d "$HOME/z" ]]; then
    info "~/z already cloned"
else
    git clone https://github.com/rupa/z "$HOME/z"
    info "cloned rupa/z"
fi

# ── 5. Dotfiles ──────────────────────────────────────────────────────────────
section "dotfiles"
if [[ -d "$HOME/.dotfiles" ]]; then
    info ".dotfiles already present"
else
    git clone --recursive https://github.com/grapeot/.dotfiles "$HOME/.dotfiles"
fi
"$HOME/.dotfiles/deploy_linux.sh"
info "dotfiles deployed"

# ── 6. Git ───────────────────────────────────────────────────────────────────
section "git config"
git config --global user.name "Yan Wang"
git config --global user.email grapeot@outlook.com
git config --global push.default simple
git config --global color.ui auto
git config --global core.fileMode false
info "git config applied"

# ── 7. Default shell ─────────────────────────────────────────────────────────
section "default shell"
zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$current_shell" == "$zsh_path" ]]; then
    info "default shell already zsh"
else
    warn "Changing default shell to $zsh_path (may prompt for password)"
    chsh -s "$zsh_path"
    info "default shell set to zsh — open a new terminal to use it"
fi

# ── 8. Verify ────────────────────────────────────────────────────────────────
section "verify"
fail=0
check() {
    local cmd="$1"
    if command -v "$cmd" &>/dev/null; then
        info "$cmd: $(command -v "$cmd")"
    else
        error "$cmd: NOT FOUND"
        fail=1
    fi
}
check zsh
check git
check tmux
check uv
check trash-put
if [[ "$fail" -ne 0 ]]; then
    error "setup_ubuntu.sh finished with missing commands"
    exit 1
fi
info "setup_ubuntu.sh complete"
