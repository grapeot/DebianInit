#!/usr/bin/env bash
# verify.sh — Stage 5: Post-install verification
# Run standalone or via setup.sh.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# ── Logging ─────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; RESET='\033[0m'
info()    { printf "${GREEN}✓${RESET}  %s\n" "$*"; }
warn()    { printf "${YELLOW}⚠${RESET}  %s\n" "$*"; }
error()   { printf "${RED}✗${RESET}  %s\n" "$*" >&2; }
section() { printf "\n${GREEN}═══ %s ═══${RESET}\n" "$*"; }

pass_count=0
fail_count=0
total_count=0

check_pass() { info "$1"; pass_count=$((pass_count + 1)); total_count=$((total_count + 1)); }
check_fail() { error "$1"; fail_count=$((fail_count + 1)); total_count=$((total_count + 1)); }
check_warn() { warn "$1"; total_count=$((total_count + 1)); }

# ── 1. Core commands ──────────────────────────────────────────────────────────
section "Core CLI Commands"

check_cmd() {
    local cmd="$1"
    local label="${2:-$1}"
    if command -v "$cmd" &>/dev/null; then
        local ver
        ver=$("$cmd" --version 2>/dev/null | head -1 || echo "version unknown")
        check_pass "$label: $ver"
    else
        check_fail "$label: NOT FOUND"
    fi
}

check_cmd "brew"     "Homebrew"
check_cmd "git"      "git"
check_cmd "nvim"     "Neovim"
check_cmd "tmux"     "tmux"
check_cmd "rg"       "ripgrep"
check_cmd "fd"       "fd"
check_cmd "lazygit"  "lazygit"
check_cmd "gh"       "GitHub CLI"
check_cmd "gum"      "gum"

# uv lives in ~/.cargo/bin or ~/.local/bin — check both
if command -v uv &>/dev/null; then
    ver=$(uv --version 2>/dev/null | head -1 || echo "version unknown")
    check_pass "uv: $ver"
else
    check_fail "uv: NOT FOUND (expected in ~/.cargo/bin or ~/.local/bin)"
fi

# Optional: node (only if installed)
if command -v node &>/dev/null; then
    ver=$(node --version 2>/dev/null || echo "version unknown")
    check_pass "node (optional): $ver"
else
    check_warn "node: not installed (optional)"
fi

# Optional: go (only if installed)
if command -v go &>/dev/null; then
    ver=$(go version 2>/dev/null | head -1 || echo "version unknown")
    check_pass "go (optional): $ver"
else
    check_warn "go: not installed (optional)"
fi

# ── 2. Brew cask apps in /Applications ───────────────────────────────────────
section "Applications in /Applications"

check_app() {
    local app_name="$1"
    local app_path="/Applications/${app_name}.app"
    if [ -d "$app_path" ]; then
        check_pass "$app_name.app"
    else
        check_warn "$app_name.app: not installed (optional)"
    fi
}

check_app "iTerm"
check_app "Visual Studio Code"
check_app "Claude"
check_app "ChatGPT"
check_app "Cursor"
check_app "Firefox"
check_app "Telegram"
check_app "Rectangle"
check_app "1Password"
check_app "Tailscale"
check_app "Zoom"
check_app "DaVinci Resolve"

# ── 3. System preferences ─────────────────────────────────────────────────────
section "System Preferences"

DS_STORE_VAL=$(defaults read com.apple.desktopservices DSDontWriteNetworkStores 2>/dev/null || echo "0")
if [ "$DS_STORE_VAL" = "1" ]; then
    check_pass "DSDontWriteNetworkStores = TRUE"
else
    check_fail "DSDontWriteNetworkStores not set (expected 1, got: $DS_STORE_VAL)"
fi

# ── 4. Dotfiles ───────────────────────────────────────────────────────────────
section "Dotfiles"

if [ -d "$HOME/.dotfiles" ]; then
    check_pass "\$HOME/.dotfiles exists"
else
    check_fail "\$HOME/.dotfiles: NOT FOUND"
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    check_pass "\$HOME/.oh-my-zsh exists"
else
    check_fail "\$HOME/.oh-my-zsh: NOT FOUND"
fi

# ── 5. Git config ─────────────────────────────────────────────────────────────
section "Git Configuration"

GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ "$GIT_NAME" = "Yan Wang" ]; then
    check_pass "git user.name = $GIT_NAME"
else
    check_fail "git user.name: expected 'Yan Wang', got '$GIT_NAME'"
fi

if [ "$GIT_EMAIL" = "grapeot@outlook.com" ]; then
    check_pass "git user.email = $GIT_EMAIL"
else
    check_fail "git user.email: expected 'grapeot@outlook.com', got '$GIT_EMAIL'"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
section "Verification Summary"
printf "  Passed:  ${GREEN}%d${RESET}\n" "$pass_count"
printf "  Skipped: ${YELLOW}%d${RESET}\n" "$((total_count - pass_count - fail_count))"
printf "  Failed:  ${RED}%d${RESET}\n" "$fail_count"
printf "  Total:   %d checks\n" "$total_count"

if [ "$fail_count" -gt 0 ]; then
    error "$fail_count check(s) failed — review output above"
    exit 1
fi

info "All required checks passed!"
