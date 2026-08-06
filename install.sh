#!/usr/bin/env bash
# One-line installer for crossr on macOS.
#
#   curl -fsSL https://raw.githubusercontent.com/MotionComplex/crossr-releases/main/install.sh | bash
#
# Why this exists: crossr is not notarised by Apple, and a DMG downloaded through a
# browser carries com.apple.quarantine. On macOS 15 that means the app refuses to open
# and the old right-click → Open bypass is gone, leaving either a trip through System
# Settings → Privacy & Security or an xattr command.
#
# Files fetched with curl are never quarantined in the first place. So this is not a
# workaround for Gatekeeper — it simply never triggers it. Same app, same ad-hoc
# signature, no dialog to click through.
set -euo pipefail

REPO="MotionComplex/crossr-releases"
APP="/Applications/crossr.app"

say() { printf '\033[1m%s\033[0m\n' "$*"; }

# Resolve the newest release without needing gh or a token.
say "Finding the latest crossr release…"
DMG_URL="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | grep -o '"browser_download_url": *"[^"]*\.dmg"' \
    | head -1 \
    | sed 's/.*"\(https[^"]*\)"/\1/')"

if [ -z "$DMG_URL" ]; then
    echo "error: could not find a .dmg in the latest release of $REPO" >&2
    exit 1
fi

VERSION="$(basename "$DMG_URL" .dmg | sed 's/^crossr-//')"
say "Installing crossr $VERSION"

WORK="$(mktemp -d)"
trap 'hdiutil detach "$WORK/mnt" >/dev/null 2>&1 || true; rm -rf "$WORK"' EXIT

curl -fsSL "$DMG_URL" -o "$WORK/crossr.dmg"

mkdir -p "$WORK/mnt"
hdiutil attach "$WORK/crossr.dmg" -mountpoint "$WORK/mnt" -nobrowse -quiet

# Quit any running copy first: replacing the bundle underneath a live process leaves it
# running from a deleted binary, and the menu-bar icon stays until it is killed.
if pgrep -x crossr >/dev/null 2>&1; then
    say "Quitting the running copy…"
    osascript -e 'quit app "crossr"' >/dev/null 2>&1 || pkill -x crossr || true
    sleep 1
fi

rm -rf "$APP"
cp -R "$WORK/mnt/crossr.app" "$APP"

# Belt and braces. curl does not set the quarantine attribute, but a previous
# browser-downloaded install may have left one on /Applications, and cp -R can carry
# extended attributes across.
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

say "Installed $APP"
open "$APP"

cat <<'NOTE'

crossr is starting. Its setup window will ask for two permissions:

  · Accessibility     — to forward and swallow keystrokes
  · Input Monitoring  — to see key presses at all

Both rows deep-link straight to the right System Settings pane and turn green on
their own once granted. macOS will also ask once for Local Network access — allow
it, or crossr cannot find the other machine.
NOTE
