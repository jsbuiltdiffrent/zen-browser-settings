#!/usr/bin/env bash
# Bundles the plaintext settings files into settings.tar.gz.enc, encrypted
# with AES-256.
#
# Passphrase: set ZEN_SETTINGS_PASSPHRASE beforehand (e.g. via
# `read -s -p "Passphrase: " ZEN_SETTINGS_PASSPHRASE && export ZEN_SETTINGS_PASSPHRASE`)
# for environments without a real TTY. Otherwise openssl prompts directly.
#
# Usage: ./encrypt.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

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

EXISTING=()
for f in "${FILES[@]}"; do
  [[ -f "$f" ]] && EXISTING+=("$f")
done

if [[ ${#EXISTING[@]} -eq 0 ]]; then
  echo "No settings files found in $REPO_DIR" >&2
  exit 1
fi

tar -czf settings.tar.gz "${EXISTING[@]}"
if [[ -n "${ZEN_SETTINGS_PASSPHRASE:-}" ]]; then
  openssl enc -aes-256-cbc -salt -pbkdf2 -in settings.tar.gz -out settings.tar.gz.enc -pass env:ZEN_SETTINGS_PASSPHRASE
else
  openssl enc -aes-256-cbc -salt -pbkdf2 -in settings.tar.gz -out settings.tar.gz.enc
fi
rm settings.tar.gz

echo "Encrypted archive written to settings.tar.gz.enc"
echo "Commit and push this file. The plaintext files remain untracked (see .gitignore)."
