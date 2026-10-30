#!/usr/bin/env bash
# Change Ubuntu apt mirrors to ubuntu.pishgaman.net
# Supports both classic /etc/apt/sources.list and deb822 (.sources) formats (Ubuntu 24.04+)
# Usage: sudo bash change-ubuntu-mirror.sh [restore]

set -euo pipefail

MIRROR="${MIRROR:-http://ubuntu.pishgaman.net/ubuntu}"
BACKUP_DIR="/etc/apt/mirror-backup"

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root: sudo bash $0" >&2
  exit 1
fi

# ---------- Restore mode ----------
if [[ "${1:-}" == "restore" ]]; then
  if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "No backup found in $BACKUP_DIR" >&2
    exit 1
  fi
  [[ -f "$BACKUP_DIR/sources.list" ]] && cp -a "$BACKUP_DIR/sources.list" /etc/apt/sources.list
  [[ -f "$BACKUP_DIR/ubuntu.sources" ]] && cp -a "$BACKUP_DIR/ubuntu.sources" /etc/apt/sources.list.d/ubuntu.sources
  echo "Original sources restored."
  apt-get update
  exit 0
fi

# ---------- Backup (only once, so the original is never overwritten) ----------
mkdir -p "$BACKUP_DIR"
[[ -f /etc/apt/sources.list && ! -f "$BACKUP_DIR/sources.list" ]] && cp -a /etc/apt/sources.list "$BACKUP_DIR/sources.list"
[[ -f /etc/apt/sources.list.d/ubuntu.sources && ! -f "$BACKUP_DIR/ubuntu.sources" ]] && cp -a /etc/apt/sources.list.d/ubuntu.sources "$BACKUP_DIR/ubuntu.sources"

# Regex of known Ubuntu hosts (main archive, security, country mirrors, ports excluded)
HOSTS_REGEX='https?://([a-z]{2}\.)?archive\.ubuntu\.com/ubuntu/?|https?://security\.ubuntu\.com/ubuntu/?|https?://[A-Za-z0-9.-]+/ubuntu/?'

replace_in_file() {
  local f="$1"
  # Skip ports.ubuntu.com (arm/other archs) - not handled by this mirror path
  sed -i -E "/ports\.ubuntu\.com/! s#(${HOSTS_REGEX})#${MIRROR}/#g" "$f"
  # Normalize accidental double slash at the end (…/ubuntu//)
  sed -i -E "s#(${MIRROR//\//\\/})/+#\1/#g" "$f"
}

changed=0

# Classic format
if [[ -f /etc/apt/sources.list ]] && grep -qE '^\s*deb' /etc/apt/sources.list; then
  replace_in_file /etc/apt/sources.list
  changed=1
fi

# deb822 format
for f in /etc/apt/sources.list.d/*.sources; do
  [[ -e "$f" ]] || continue
  # Only touch Ubuntu official sources
  if grep -qE 'ubuntu\.com|/ubuntu' "$f"; then
    replace_in_file "$f"
    changed=1
  fi
done

# Old-style list files in sources.list.d that point to Ubuntu archives
for f in /etc/apt/sources.list.d/*.list; do
  [[ -e "$f" ]] || continue
  if grep -qE 'archive\.ubuntu\.com|security\.ubuntu\.com' "$f"; then
    replace_in_file "$f"
    changed=1
  fi
done

if [[ $changed -eq 0 ]]; then
  echo "No apt sources file found to change." >&2
  exit 1
fi

echo "Mirror set to: $MIRROR"
echo "Running apt-get update ..."
apt-get update
echo "Done. To revert: sudo bash $0 restore"
