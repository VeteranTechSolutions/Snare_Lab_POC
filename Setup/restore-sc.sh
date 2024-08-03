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

# Variables from .env
BACKUP_FILE="/var/lib/vz/dump/vzdump-qemu-106-2024_07_17-10_57_18.vma.zst"
STORAGE_NAME="local-zfs"
PROXMOX_API_URL="https://${PROXMOX_NODE_IP}:8006/api2/json"

# Function to find the next available VM ID
get_next_vm_id() {
  local max_id
  max_id=$(curl -s -k -H "Authorization: PVEAPIToken=${PROXMOX_API_ID}=${PROXMOX_API_TOKEN}" \
    "${PROXMOX_API_URL}/cluster/resources?type=vm" | jq '.data[].vmid' | sort -n | tail -1)

  if [[ -z "$max_id" ]]; then
    next_id=100
  else
    next_id=$((max_id + 1))
  fi
  echo "$next_id"
}

# Find the next available VM ID
NEXT_VM_ID=$(get_next_vm_id)
echo "Next available VM ID is: $NEXT_VM_ID"

# Restore the VM
restore_vm() {
  local response
  response=$(curl -s -k -X POST -H "Authorization: PVEAPIToken=${PROXMOX_API_ID}=${PROXMOX_API_TOKEN}" \
    -d "vmid=$NEXT_VM_ID" \
    -d "storage=$STORAGE_NAME" \
    -d "archive=$BACKUP_FILE" \
    "${PROXMOX_API_URL}/nodes/${PROXMOX_NODE_NAME}/vzdump" | jq '.data')

  if [[ "$response" == "null" ]]; then
    echo "Failed to restore VM."
    return 1
  else
    echo "VM restored successfully with ID $NEXT_VM_ID."
  fi
}

# Attempt to restore the VM
restore_vm