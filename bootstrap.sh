#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Bootstrap script to secure files, install Ansible and deps, run playbook, then reboot

PLAYBOOK="playbook.yml"
LOG_FILE="bootstrap.log"

# Logging function
log() {
  local ts
  ts="$(date +'%Y-%m-%d %H:%M:%S')"
  echo "[${ts}] $*" | tee -a "$LOG_FILE"
}

# Ensure running as root
if [[ "$EUID" -ne 0 ]]; then
  log "[!] This script must be run as root. Exiting."
  exit 1
fi

# Ensure playbook file exists
for file in "$PLAYBOOK"; do
  if [[ -e "$file" ]]; then
    chmod 600 "$file"
  else
    log "[!] Missing expected file: $file"
    exit 1
  fi
done

# Detect package manager
if ! command -v apt-get &>/dev/null; then
  log "[!] apt-get not found. Cannot install packages. Exiting."
  exit 1
fi

# Update package cache once
log "Updating APT package cache"
apt-get update -qq

# Install required packages if missing
packages=(ansible python3-debian)
for pkg in "${packages[@]}"; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    log "Installing package: $pkg"
    DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
  fi
done

# Run Ansible playbook
log "Running Ansible playbook: $PLAYBOOK"
ansible-playbook "$PLAYBOOK" --connection=local

# Reboot system
log "Ansible completed successfully. Rebooting in 5 seconds."
sleep 5
reboot