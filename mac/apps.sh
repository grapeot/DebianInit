#!/usr/bin/env bash
# apps.sh — Stage 2+3: TUI selection + brew/mas installation
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

# ── Prerequisite check ───────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    error "Homebrew not found — run bootstrap.sh first"
    exit 1
fi
if ! command -v gum &>/dev/null; then
    error "gum not found — run bootstrap.sh first"
    exit 1
fi

# ── Stage 2: TUI Selection ───────────────────────────────────────────────────
section "Stage 2: App Selection"

# Screen 1 — GUI Applications (brew cask)
CASK_CHOICES=$(gum choose --no-limit \
    --header "Select GUI Applications to install (brew cask):" \
    "Claude (claude)" \
    "ChatGPT (chatgpt)" \
    "ChatGPT Atlas (chatgpt-atlas)" \
    "Cursor (cursor)" \
    "Codex (codex)" \
    "LM Studio (lm-studio)" \
    "Ollama (ollama-app)" \
    "VS Code (visual-studio-code)" \
    "Android Studio (android-studio)" \
    "Docker (docker-desktop)" \
    "iTerm (iterm2)" \
    "Telegram (telegram)" \
    "Zoom (zoom)" \
    "DaVinci Resolve [special handler]" \
    "Gyroflow (gyroflow)" \
    "BambuStudio (bambu-studio)" \
    "OpenSCAD (openscad)" \
    "Roon (roon)" \
    "Tailscale (tailscale-app)" \
    "Windows App (windows-app)" \
    "1Password (1password)" \
    "Firefox (firefox)" \
    "Rectangle (rectangle)" \
    "Antigravity (antigravity)" \
    "Antigravity Tools [GitHub release]" \
    || true)

# Screen 2 — CLI Tools & Libraries (brew formula)
FORMULA_CHOICES=$(gum choose --no-limit \
    --header "Select CLI Tools & Libraries to install (brew formula):" \
    "ffmpeg" \
    "sox" \
    "zbar" \
    "pandoc" \
    "marp-cli" \
    "borgbackup" \
    "cmake" \
    "go" \
    "swig" \
    "astrometry-net" \
    "argyll-cms" \
    || true)

# Screen 3 — App Store
MAS_CHOICES=$(gum choose --no-limit \
    --header "Select App Store apps to install (requires Apple ID login):" \
    "Compressor (mas 424390742)" \
    "Photomator (mas 1444636541)" \
    "Xcode [manual - open App Store]" \
    || true)

# ── Stage 3: Installation ────────────────────────────────────────────────────
section "Stage 3: Installation"

install_count=0
skip_count=0
fail_count=0

# Helper: install a cask with idempotency check
install_cask() {
    local cask_name="$1"
    if brew list --cask 2>/dev/null | grep -qx "$cask_name"; then
        warn "$cask_name already installed (skipping)"
        skip_count=$((skip_count + 1))
        return
    fi
    warn "Installing cask: $cask_name..."
    if brew install --cask "$cask_name" 2>&1; then
        info "$cask_name installed"
        install_count=$((install_count + 1))
    else
        error "Failed to install $cask_name"
        fail_count=$((fail_count + 1))
    fi
}

# Helper: install a formula with idempotency check
install_formula() {
    local formula_name="$1"
    if brew list --formula 2>/dev/null | grep -qx "$formula_name"; then
        warn "$formula_name already installed (skipping)"
        skip_count=$((skip_count + 1))
        return
    fi
    warn "Installing formula: $formula_name..."
    if brew install "$formula_name" 2>&1; then
        info "$formula_name installed"
        install_count=$((install_count + 1))
    else
        error "Failed to install $formula_name"
        fail_count=$((fail_count + 1))
    fi
}

# ── Process cask selections ──────────────────────────────────────────────────
if [ -n "$CASK_CHOICES" ]; then
    while IFS= read -r choice; do
        [ -z "$choice" ] && continue
        case "$choice" in
            "Claude (claude)")
                install_cask "claude" ;;
            "ChatGPT (chatgpt)")
                install_cask "chatgpt" ;;
            "ChatGPT Atlas (chatgpt-atlas)")
                install_cask "chatgpt-atlas" ;;
            "Cursor (cursor)")
                install_cask "cursor" ;;
            "Codex (codex)")
                install_cask "codex" ;;
            "LM Studio (lm-studio)")
                install_cask "lm-studio" ;;
            "Ollama (ollama-app)")
                install_cask "ollama-app" ;;
            "VS Code (visual-studio-code)")
                install_cask "visual-studio-code" ;;
            "Android Studio (android-studio)")
                install_cask "android-studio" ;;
            "Docker (docker-desktop)")
                install_cask "docker-desktop" ;;
            "iTerm (iterm2)")
                install_cask "iterm2" ;;
            "Telegram (telegram)")
                install_cask "telegram" ;;
            "Zoom (zoom)")
                install_cask "zoom" ;;
            "DaVinci Resolve [special handler]")
                warn "DaVinci Resolve: delegating to davinci.sh..."
                if bash "$SCRIPT_DIR/davinci.sh"; then
                    install_count=$((install_count + 1))
                else
                    fail_count=$((fail_count + 1))
                fi ;;
            "Gyroflow (gyroflow)")
                install_cask "gyroflow" ;;
            "BambuStudio (bambu-studio)")
                install_cask "bambu-studio" ;;
            "OpenSCAD (openscad)")
                install_cask "openscad" ;;
            "Roon (roon)")
                install_cask "roon" ;;
            "Tailscale (tailscale-app)")
                install_cask "tailscale-app" ;;
            "Windows App (windows-app)")
                install_cask "windows-app" ;;
            "1Password (1password)")
                install_cask "1password" ;;
            "Firefox (firefox)")
                install_cask "firefox" ;;
            "Rectangle (rectangle)")
                install_cask "rectangle" ;;
            "Antigravity (antigravity)")
                install_cask "antigravity" ;;
            "Antigravity Tools [GitHub release]")
                if [ -d "/Applications/Antigravity Tools.app" ]; then
                    warn "Antigravity Tools already installed (skipping)"
                    skip_count=$((skip_count + 1))
                else
                    warn "Downloading Antigravity Tools from GitHub Release..."
                    AT_TAG=$(curl -sf "https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases/latest" | python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])" 2>/dev/null || echo "v4.1.30")
                    AT_VER="${AT_TAG#v}"
                    AT_URL="https://github.com/lbjlaq/Antigravity-Manager/releases/download/${AT_TAG}/Antigravity.Tools_${AT_VER}_aarch64.dmg"
                    AT_DMG="$HOME/Downloads/Antigravity_Tools.dmg"
                    if curl -L --progress-bar -o "$AT_DMG" "$AT_URL" && open "$AT_DMG"; then
                        info "Antigravity Tools DMG downloaded and opened"
                        install_count=$((install_count + 1))
                    else
                        error "Failed to download Antigravity Tools"
                        fail_count=$((fail_count + 1))
                    fi
                fi ;;
            *)
                warn "Unknown cask choice: $choice (skipping)" ;;
        esac
    done <<EOF
$CASK_CHOICES
EOF
fi

# ── Process formula selections ───────────────────────────────────────────────
if [ -n "$FORMULA_CHOICES" ]; then
    while IFS= read -r formula; do
        [ -z "$formula" ] && continue
        install_formula "$formula"
    done <<EOF
$FORMULA_CHOICES
EOF
fi

# ── Process App Store selections ─────────────────────────────────────────────
if [ -n "$MAS_CHOICES" ]; then
    while IFS= read -r choice; do
        [ -z "$choice" ] && continue
        case "$choice" in
            "Compressor (mas 424390742)")
                mas_id="424390742"
                if mas list 2>/dev/null | grep -q "$mas_id"; then
                    warn "Compressor already installed (skipping)"
                    skip_count=$((skip_count + 1))
                else
                    warn "Installing Compressor from App Store..."
                    if mas install "$mas_id"; then
                        info "Compressor installed"
                        install_count=$((install_count + 1))
                    else
                        error "Failed to install Compressor"
                        fail_count=$((fail_count + 1))
                    fi
                fi ;;
            "Photomator (mas 1444636541)")
                mas_id="1444636541"
                if mas list 2>/dev/null | grep -q "$mas_id"; then
                    warn "Photomator already installed (skipping)"
                    skip_count=$((skip_count + 1))
                else
                    warn "Installing Photomator from App Store..."
                    if mas install "$mas_id"; then
                        info "Photomator installed"
                        install_count=$((install_count + 1))
                    else
                        error "Failed to install Photomator"
                        fail_count=$((fail_count + 1))
                    fi
                fi ;;
            "Xcode [manual - open App Store]")
                warn "Xcode: opening App Store for manual install..."
                open "macappstore://apps.apple.com/app/id497799835"
                warn "Please install Xcode manually from the App Store"
                skip_count=$((skip_count + 1)) ;;
            *)
                warn "Unknown App Store choice: $choice (skipping)" ;;
        esac
    done <<EOF
$MAS_CHOICES
EOF
fi

# ── Summary ──────────────────────────────────────────────────────────────────
section "Installation Summary"
info "Installed: $install_count"
warn "Skipped:   $skip_count"
if [ "$fail_count" -gt 0 ]; then
    error "Failed:    $fail_count"
else
    info "Failed:    $fail_count"
fi

if [ "$fail_count" -gt 0 ]; then
    error "Some installations failed — review output above"
    exit 1
fi
info "apps.sh complete"
