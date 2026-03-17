#!/usr/bin/env bash
# setup.sh — Main entry point, orchestrates all stages
# Mac Setup — Generative Kernel v1.0
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# ── Logging ─────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; RESET='\033[0m'
BOLD='\033[1m'
info()    { printf "${GREEN}✓${RESET}  %s\n" "$*"; }
warn()    { printf "${YELLOW}⚠${RESET}  %s\n" "$*"; }
error()   { printf "${RED}✗${RESET}  %s\n" "$*" >&2; }
section() { printf "\n${GREEN}═══ %s ═══${RESET}\n" "$*"; }

START_TIME=$(date +%s)

# ── Banner ───────────────────────────────────────────────────────────────────
printf '\n%s' "${BOLD}${GREEN}"
printf "  ╔═══════════════════════════════════════╗\n"
printf "  ║   Mac Setup — Generative Kernel v1.0  ║\n"
printf "  ╚═══════════════════════════════════════╝\n"
printf '%s\n' "${RESET}"

# ── macOS guard ───────────────────────────────────────────────────────────────
if [[ "$(uname -s)" != "Darwin" ]]; then
    error "This script is macOS-only. Detected: $(uname -s)"
    exit 1
fi
info "Platform: macOS $(sw_vers -productVersion)"

# ── Architecture detection ────────────────────────────────────────────────────
ARCH=$(uname -m)
if [[ "$ARCH" != "arm64" ]]; then
    error "This setup requires Apple Silicon (arm64). Detected: $ARCH"
    exit 1
fi
info "Architecture: Apple Silicon (arm64)"

# ── Stage 1: Bootstrap (critical — abort on failure) ─────────────────────────
section "Stage 1: Bootstrap (base layer)"
if bash "$SCRIPT_DIR/bootstrap.sh"; then
    info "Stage 1 complete"
else
    error "Stage 1 (bootstrap) failed — cannot continue"
    exit 1
fi

# ── Stage 2+3: Apps (non-critical — continue on failure) ─────────────────────
section "Stage 2+3: App Selection & Installation"
if bash "$SCRIPT_DIR/apps.sh"; then
    info "Stage 2+3 complete"
else
    warn "Stage 2+3 (apps) had failures — continuing to verification"
fi

# ── Stage 4: DaVinci Resolve — only if not already handled by apps.sh ────────
# (apps.sh calls davinci.sh internally if selected; this provides a
#  standalone path if setup.sh is invoked without apps.sh interaction)
section "Stage 4: DaVinci Resolve (standalone check)"
if [ -d "/Applications/DaVinci Resolve" ]; then
    info "DaVinci Resolve already installed — skipping"
else
    warn "DaVinci Resolve not found — run mac/davinci.sh separately if desired"
fi

# ── Stage 5: Verification ─────────────────────────────────────────────────────
section "Stage 5: Post-Install Verification"
if bash "$SCRIPT_DIR/verify.sh"; then
    info "Stage 5 complete — all checks passed"
else
    warn "Stage 5 had verification failures — see output above"
fi

# ── Elapsed time ─────────────────────────────────────────────────────────────
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

section "Setup Complete"
info "Total elapsed time: ${MINUTES}m ${SECONDS}s"
info "Your Mac is ready. Restart your terminal to pick up all PATH changes."
