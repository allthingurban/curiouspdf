#!/usr/bin/env bash
set -euo pipefail

APP_NAME="curiouspdf"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/128x128/apps"

mkdir -p "$BIN_DIR" "$APPS_DIR" "$ICON_DIR"

# Install binary
install -m 0755 "$ROOT_DIR/curiouspdf.py" "$BIN_DIR/$APP_NAME"

# Install icon (a 128x128 PNG)
if [ -f "$ROOT_DIR/icons/curiouspdf.png" ]; then
  install -m 0644 "$ROOT_DIR/icons/curiouspdf.png" "$ICON_DIR/curiouspdf.png"
fi

# Install desktop file
# Replace Exec/TryExec to match our installed binary name
tmpdesk="$(mktemp)"
sed -e "s|Exec=curiouspdf|Exec=$APP_NAME|g" \
    -e "s|TryExec=curiouspdf|TryExec=$APP_NAME|g" \
    "$ROOT_DIR/curiouspdf.desktop" > "$tmpdesk"
install -m 0644 "$tmpdesk" "$APPS_DIR/curiouspdf.desktop"
rm -f "$tmpdesk"

# Refresh desktop DB and icon cache (ignore if tools absent)
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true

echo "Installed to:"
echo "  $BIN_DIR/$APP_NAME"
echo "  $APPS_DIR/curiouspdf.desktop"
echo "  $ICON_DIR/curiouspdf.png (if provided)"
echo
echo "It should now appear in your app menu as 'CuriousPDF'."
echo
echo "Optional: set as default for PDFs:"
echo "  xdg-mime default curiouspdf.desktop application/pdf"