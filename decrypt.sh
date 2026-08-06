#!/usr/bin/env bash
# Decrypts settings.tar.gz.enc back into the plaintext settings files.
#
# Passphrase: set ZEN_SETTINGS_PASSPHRASE beforehand (e.g. via
# `read -s -p "Passphrase: " ZEN_SETTINGS_PASSPHRASE && export ZEN_SETTINGS_PASSPHRASE`)
# for environments without a real TTY. Otherwise openssl prompts directly.
#
# Usage: ./decrypt.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

if [[ ! -f settings.tar.gz.enc ]]; then
  echo "settings.tar.gz.enc not found in $REPO_DIR" >&2
  exit 1
fi

if [[ -n "${ZEN_SETTINGS_PASSPHRASE:-}" ]]; then
  openssl enc -d -aes-256-cbc -pbkdf2 -in settings.tar.gz.enc -out settings.tar.gz -pass env:ZEN_SETTINGS_PASSPHRASE
else
  openssl enc -d -aes-256-cbc -pbkdf2 -in settings.tar.gz.enc -out settings.tar.gz
fi
tar -xzf settings.tar.gz
rm settings.tar.gz

echo "Decrypted settings files are now present in $REPO_DIR"
