#!/usr/bin/env bash
# bootstrap.sh — Stage 1: Unconditional base layer
# Run standalone or via setup.sh. Idempotent.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# ── Logging ─────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; RESET='\033[0m'
info()    { printf "${GREEN}✓${RESET}  %s\n" "$*"; }
warn()    { printf "${YELLOW}⚠${RESET}  %s\n" "$*"; }
error()   { printf "${RED}✗${RESET}  %s\n" "$*" >&2; }
section() { printf "\n${GREEN}═══ %s ═══${RESET}\n" "$*"; }

# ── 1. Xcode Command Line Tools ─────────────────────────────────────────────
section "Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
    info "Xcode CLT already installed: $(xcode-select -p)"
else
    warn "Xcode CLT not found — launching installer (follow the dialog, then press Enter here)"
    xcode-select --install 2>/dev/null || true
    read -r -p "Press Enter once Xcode CLT installation is complete..."
    if ! xcode-select -p &>/dev/null; then
        error "Xcode CLT still not found — aborting"
        exit 1
    fi
    info "Xcode CLT installed"
fi

# ── 2. Homebrew ──────────────────────────────────────────────────────────────
section "Homebrew"
if command -v brew &>/dev/null; then
    info "Homebrew already installed: $(brew --version | head -1)"
else
    warn "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for current session (Apple Silicon vs Intel)
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    info "Homebrew installed: $(brew --version | head -1)"
fi

# Ensure brew is in PATH regardless (handles case where brew was installed
# but not yet in current shell PATH)
if ! command -v brew &>/dev/null; then
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# ── 3. gum (charmbracelet TUI) ───────────────────────────────────────────────
section "gum"
if command -v gum &>/dev/null; then
    info "gum already installed: $(gum --version)"
else
    brew install gum
    info "gum installed"
fi

# ── 4. uv ────────────────────────────────────────────────────────────────────
section "uv (Python toolchain)"
if command -v uv &>/dev/null; then
    info "uv already installed: $(uv --version)"
else
    warn "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to PATH for current session
    export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
    if command -v uv &>/dev/null; then
        info "uv installed: $(uv --version)"
    else
        warn "uv installed but not yet in PATH — restart shell or add ~/.cargo/bin to PATH"
    fi
fi

# ── 5. Core CLI tools ────────────────────────────────────────────────────────
section "Core CLI tools"
CORE_TOOLS=(
    coreutils wget tmux ripgrep htop btop macmon p7zip rsync nmap
    shellcheck tig socat gh git-lfs exiftool neovim fd lazygit
)
for tool in "${CORE_TOOLS[@]}"; do
    if brew list --formula 2>/dev/null | grep -qx "$tool"; then
        info "$tool already installed (skipping)"
    else
        warn "Installing $tool..."
        brew install "$tool"
        info "$tool installed"
    fi
done

# ── 6. Nerd Font ─────────────────────────────────────────────────────────────
section "Nerd Font (MesloLG)"
if brew list --cask 2>/dev/null | grep -q "font-meslo-lg-nerd-font"; then
    info "font-meslo-lg-nerd-font already installed"
else
    brew install --cask font-meslo-lg-nerd-font
    info "font-meslo-lg-nerd-font installed"
fi

# ── 7. mas-cli ───────────────────────────────────────────────────────────────
section "mas-cli (App Store automation)"
if command -v mas &>/dev/null; then
    info "mas already installed: $(mas version)"
else
    brew install mas
    info "mas installed"
fi

# ── 8. oh-my-zsh ─────────────────────────────────────────────────────────────
section "oh-my-zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
    info "oh-my-zsh already installed"
else
    warn "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    info "oh-my-zsh installed"
fi

# ── 9. Git config ─────────────────────────────────────────────────────────────
section "Git configuration"
git config --global user.name "Yan Wang"
git config --global user.email grapeot@outlook.com
git config --global color.ui auto
git config --global core.fileMode false
git config --global push.default simple
info "Git config applied"

# ── 10. Dotfiles ──────────────────────────────────────────────────────────────
section "Dotfiles"
if [ -d "$HOME/.dotfiles" ]; then
    info ".dotfiles already deployed (skipping clone)"
else
    warn "Cloning .dotfiles..."
    git clone --recursive https://github.com/grapeot/.dotfiles "$HOME/.dotfiles"
    "$HOME/.dotfiles/deploy_mac.sh"
    info ".dotfiles deployed"
fi

# ── 11. System preferences ────────────────────────────────────────────────────
section "System preferences"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
info "DSDontWriteNetworkStores = TRUE"

section "bootstrap.sh complete"
info "Stage 1 finished — base layer is ready"
