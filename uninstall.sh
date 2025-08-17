#!/usr/bin/env bash
set -euo pipefail

APP_NAME="pdf-opener"

rm -f "$HOME/.local/bin/$APP_NAME"
rm -f "$HOME/.local/share/applications/pdf-opener.desktop"
rm -f "$HOME/.local/share/icons/hicolor/128x128/apps/pdf-opener.png"

update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true

echo "Uninstalled $APP_NAME (user-local)."

