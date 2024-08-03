#!/bin/bash

LOGFILE=~/Git_Project/Snare_Lab_POC/setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

# Source the environment variables
source_env_POC() {
  ENV_PATH=~/Git_Project/Snare_Lab_POC/.env
  if [ -f "$ENV_PATH" ]; then
    log "Sourcing .env file..."
    source "$ENV_PATH"
  else
    error_exit ".env file not found at $ENV_PATH! Exiting..."
  fi
}

# Load environment variables
source_env_POC

# Variables sourced from .env
BACKUP_FILE="/var/lib/vz/dump/vzdump-qemu-105-2024_07_25-19_42_45.vma.zst"
STORAGE_NAME="local-zfs"

# Function to find the next available VM ID using SSH
get_next_vm_id() {
  local max_id
  max_id=$(sshpass -p "$PROXMOX_PASSWORD" ssh "$PROXMOX_USER@$PROXMOX_NODE_IP" \
    "qm list | awk 'NR>1 {print \$1}' | sort -n | tail -1")

  if [[ -z "$max_id" ]]; then
    next_id=100
  else
    next_id=$((max_id + 1))
  fi
  echo "$next_id"
}

# Find the next available VM ID
NEXT_VM_ID=$(get_next_vm_id)
log "Next available VM ID is: $NEXT_VM_ID"

# Restore the VM using SSH
restore_vm() {
  log "Attempting to restore VM with ID $NEXT_VM_ID from backup $BACKUP_FILE"
  sshpass -p "$PROXMOX_PASSWORD" ssh "$PROXMOX_USER@$PROXMOX_NODE_IP" \
    "qmrestore $BACKUP_FILE $NEXT_VM_ID --storage $STORAGE_NAME"

  if [[ $? -eq 0 ]]; then
    log "VM restored successfully with ID $NEXT_VM_ID."
  else
    log "Failed to restore VM."
    return 1
  fi
}

# Define the next script variables
NEXT_SCRIPT="prepare-drivers.sh"
NEXT_SCRIPT_DIR=~/Git_Project/Snare_Lab_POC/Setup

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT $NEXT_SCRIPT"
  cd "$NEXT_SCRIPT_DIR" || error_exit "Failed to change directory to $NEXT_SCRIPT_DIR"
  ./"$NEXT_SCRIPT"
}

# Attempt to restore the VM
restore_vm && run_next_script