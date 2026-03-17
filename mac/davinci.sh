#!/usr/bin/env bash
# davinci.sh — Stage 4: DaVinci Resolve API download
# Run standalone or called from apps.sh. Idempotent.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# ── Logging ─────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; RESET='\033[0m'
info()    { printf "${GREEN}✓${RESET}  %s\n" "$*"; }
warn()    { printf "${YELLOW}⚠${RESET}  %s\n" "$*"; }
error()   { printf "${RED}✗${RESET}  %s\n" "$*" >&2; }
section() { printf "\n${GREEN}═══ %s ═══${RESET}\n" "$*"; }

section "DaVinci Resolve"

# ── Check if already installed ───────────────────────────────────────────────
if [ -d "/Applications/DaVinci Resolve" ]; then
    info "DaVinci Resolve already installed at /Applications/DaVinci Resolve"
    exit 0
fi

# ── API download flow ─────────────────────────────────────────────────────────
warn "DaVinci Resolve not found — attempting API download (~6.5 GB)..."

BMD_VERSION_URL="https://www.blackmagicdesign.com/api/support/latest-stable-version/davinci-resolve/mac"
BMD_REGISTER_BASE="https://www.blackmagicdesign.com/api/register/us/download"

# Step 1: Get latest version info and extract downloadId
warn "Fetching latest version info from Blackmagic API..."
VERSION_JSON=$(curl -sf "$BMD_VERSION_URL" || true)

if [ -z "$VERSION_JSON" ]; then
    error "Failed to reach Blackmagic API"
    warn "Falling back to manual download..."
    open "https://www.blackmagicdesign.com/products/davinciresolve"
    warn "Please download and install DaVinci Resolve manually from the page that just opened."
    exit 1
fi

# Extract downloadId using python3 (always available on macOS)
DOWNLOAD_ID=$(python3 -c "
import json, sys
try:
    data = json.loads('''$VERSION_JSON''')
    # The free version key is 'linux' or 'mac' depending on API version
    # Try common keys
    for key in ['mac', 'Mac', 'downloadId', 'id']:
        if key in data:
            val = data[key]
            if isinstance(val, dict):
                for subkey in ['downloadId', 'id', 'releaseId']:
                    if subkey in val:
                        print(val[subkey])
                        sys.exit(0)
            else:
                print(val)
                sys.exit(0)
    # Try nested structure
    if isinstance(data, dict):
        for v in data.values():
            if isinstance(v, dict) and 'downloadId' in v:
                print(v['downloadId'])
                sys.exit(0)
    print('', end='')
except Exception as e:
    print('', end='')
" 2>/dev/null || true)

if [ -z "$DOWNLOAD_ID" ]; then
    error "Could not extract downloadId from API response"
    warn "API response was: $VERSION_JSON"
    warn "Falling back to manual download..."
    open "https://www.blackmagicdesign.com/products/davinciresolve"
    warn "Please download and install DaVinci Resolve manually from the page that just opened."
    exit 1
fi

info "Got downloadId: $DOWNLOAD_ID"

# Step 2: POST registration to get signed download URL
warn "Requesting signed download URL..."
REGISTER_URL="${BMD_REGISTER_BASE}/${DOWNLOAD_ID}"

REGISTER_BODY='{"firstname":"Setup","lastname":"Script","email":"setup@localhost","phone":"","country":"us","product":"DaVinci Resolve"}'

DOWNLOAD_URL=$(curl -sf \
    -X POST \
    -H "Content-Type: application/json;charset=UTF-8" \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
    -H "Referer: https://www.blackmagicdesign.com/products/davinciresolve" \
    -d "$REGISTER_BODY" \
    "$REGISTER_URL" || true)

if [ -z "$DOWNLOAD_URL" ]; then
    error "Registration API returned empty response"
    warn "Falling back to manual download..."
    open "https://www.blackmagicdesign.com/products/davinciresolve"
    warn "Please download and install DaVinci Resolve manually from the page that just opened."
    exit 1
fi

# The response should be the signed URL directly or contain it
# Some API versions return JSON, others return the URL directly
SIGNED_URL=$(python3 -c "
import json, sys
data = '''$DOWNLOAD_URL'''
data = data.strip()
# Try to parse as JSON first
try:
    obj = json.loads(data)
    for key in ['url', 'download_url', 'link', 'downloadUrl']:
        if key in obj:
            print(obj[key])
            sys.exit(0)
    # Check if value itself looks like a URL
    for v in obj.values():
        if isinstance(v, str) and v.startswith('http'):
            print(v)
            sys.exit(0)
except Exception:
    pass
# If it looks like a URL directly
if data.startswith('http'):
    print(data)
" 2>/dev/null || true)

if [ -z "$SIGNED_URL" ]; then
    error "Could not extract signed download URL from registration response"
    warn "Response was: $DOWNLOAD_URL"
    warn "Falling back to manual download..."
    open "https://www.blackmagicdesign.com/products/davinciresolve"
    warn "Please download and install DaVinci Resolve manually from the page that just opened."
    exit 1
fi

info "Got signed download URL"

# Step 3: Download the installer
DOWNLOAD_DIR="$HOME/Downloads"

# Determine extension from URL (.zip or .dmg)
EXTENSION="zip"
case "$SIGNED_URL" in
    *.dmg*) EXTENSION="dmg" ;;
    *.zip*) EXTENSION="zip" ;;
    *.pkg*) EXTENSION="pkg" ;;
esac
INSTALLER_FILE="$DOWNLOAD_DIR/DaVinci_Resolve.$EXTENSION"

warn "Downloading DaVinci Resolve (~6.5 GB) to $INSTALLER_FILE ..."
warn "This will take a while — please be patient."

if ! curl -L --progress-bar -o "$INSTALLER_FILE" "$SIGNED_URL"; then
    error "Download failed"
    warn "Falling back to manual download..."
    open "https://www.blackmagicdesign.com/products/davinciresolve"
    warn "Please download and install DaVinci Resolve manually from the page that just opened."
    exit 1
fi

info "Download complete: $INSTALLER_FILE"

# Step 4: Open the installer
warn "Opening installer — follow the on-screen instructions to install..."
open "$INSTALLER_FILE"
warn "After installation completes, you can close this terminal."
info "davinci.sh complete — installer opened"
