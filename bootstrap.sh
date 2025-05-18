#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Bootstrap script to secure files, set user password, install Ansible and deps, run playbook, then reboot

USERNAME="kali"
VAULT_FILE=".vault_pass.txt"
HASH_FILE="kali-newpassword.hash"
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

# Secure sensitive files
for file in "$VAULT_FILE" "$HASH_FILE" "$PLAYBOOK"; do
  if [[ -e "$file" ]]; then
    chmod 600 "$file"
  else
    log "[!] Missing expected file: $file"
  fi
done

# Validate password hash file
if [[ ! -f "$HASH_FILE" ]]; then
  log "[!] Password hash file not found: $HASH_FILE"
  exit 1
fi
HASHED_PASSWORD=$(<"$HASH_FILE")

# Set local user password
if id "$USERNAME" &>/dev/null; then
  log "Setting password for user '$USERNAME'"
  usermod --password "$HASHED_PASSWORD" "$USERNAME"
else
  log "[!] User '$USERNAME' does not exist"
  exit 1
fi

# Detect package manager
if ! command -v apt-get &>/dev/null; then
  log "[!] apt-get not found. Cannot install packages. Exiting."
  exit 1
fi

# Update package cache once
log "Updating package cache"
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
ansible-playbook "$PLAYBOOK" --connection=local --vault-password-file "$VAULT_FILE"

# Reboot system
log "Ansible completed successfully. Rebooting in 5 seconds."
sleep 5
reboot