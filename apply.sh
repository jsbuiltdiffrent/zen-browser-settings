#!/usr/bin/env bash
# Applies the settings files in this repo to a local Zen Browser profile.
#
# Usage: ./apply.sh [/path/to/profile]
# If no path is given, it targets the flatpak default release profile.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="${1:-$HOME/.var/app/app.zen_browser.zen/.zen/b6poq6jm.Default (release)}"

if [[ -f "$REPO_DIR/settings.tar.gz.enc" && ! -f "$REPO_DIR/prefs.js" ]]; then
  echo "Decrypting settings.tar.gz.enc first..."
  "$REPO_DIR/decrypt.sh"
fi

if [[ ! -d "$PROFILE_DIR" ]]; then
  echo "Profile directory not found: $PROFILE_DIR" >&2
  exit 1
fi

FILES=(
  prefs.js
  prefs-1.js
  handlers.json
  containers.json
  extension-preferences.json
  zen-themes.json
  zen-keyboard-shortcuts.json
  xulstore.json
  search.json.mozlz4
)

BACKUP_DIR="$PROFILE_DIR/settings-backup-$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Close Zen Browser before applying, or changes may be overwritten on exit."
echo "Backing up existing files to: $BACKUP_DIR"

for f in "${FILES[@]}"; do
  [[ -f "$PROFILE_DIR/$f" ]] && cp "$PROFILE_DIR/$f" "$BACKUP_DIR/"
  if [[ -f "$REPO_DIR/$f" ]]; then
    cp "$REPO_DIR/$f" "$PROFILE_DIR/$f"
    echo "Applied $f"
  fi
done

echo "Done. Backup of previous settings saved in: $BACKUP_DIR"
