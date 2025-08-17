#!/usr/bin/env bash
set -euo pipefail

APP_NAME="pdf-opener"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/128x128/apps"

mkdir -p "$BIN_DIR" "$APPS_DIR" "$ICON_DIR"

# Install binary
install -m 0755 "$ROOT_DIR/pdf_opener.py" "$BIN_DIR/$APP_NAME"

# Install icon (a 128x128 PNG)
if [ -f "$ROOT_DIR/icons/pdf-opener.png" ]; then
  install -m 0644 "$ROOT_DIR/icons/pdf-opener.png" "$ICON_DIR/pdf-opener.png"
fi

# Install desktop file
# Replace Exec/TryExec to match our installed binary name
tmpdesk="$(mktemp)"
sed -e "s|Exec=pdf-opener|Exec=$APP_NAME|g" \
    -e "s|TryExec=pdf-opener|TryExec=$APP_NAME|g" \
    "$ROOT_DIR/pdf-opener.desktop" > "$tmpdesk"
install -m 0644 "$tmpdesk" "$APPS_DIR/pdf-opener.desktop"
rm -f "$tmpdesk"

# Refresh desktop DB and icon cache (ignore if tools absent)
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true

echo "Installed to:"
echo "  $BIN_DIR/$APP_NAME"
echo "  $APPS_DIR/pdf-opener.desktop"
echo "  $ICON_DIR/pdf-opener.png (if provided)"
echo
echo "It should now appear in your app menu as 'PDF Opener'."
echo
echo "Optional: set as default for PDFs:"
echo "  xdg-mime default pdf-opener.desktop application/pdf"

