#!/bin/bash

LOGFILE=remote_execution.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

source_env() {
  ENV_PATH=~/Git_Project/Snare_Lab_POC/.env
  if [ -f $ENV_PATH ]; then
    log "Sourcing .env file..."
    set -o allexport
    source $ENV_PATH
    set +o allexport
  else
    error_exit ".env file not found at $ENV_PATH! Exiting..."
  fi
}

execute_remote_script() {
  log "Executing restore_sc.sh on Proxmox server..."
  ssh_user="$PROXMOX_USER"
  remote_script_path="/var/lib/vz/dump/restore_sc.sh"

  log "sshpass -p \"$PROXMOX_PASSWORD\" ssh -o StrictHostKeyChecking=no $ssh_user@$PROXMOX_NODE_IP \"chmod +x $remote_script_path && $remote_script_path\""
  sshpass -p "$PROXMOX_PASSWORD" ssh -o StrictHostKeyChecking=no "$ssh_user@$PROXMOX_NODE_IP" "chmod +x $remote_script_path && $remote_script_path" >> $LOGFILE 2>&1

  if [ $? -ne 0 ]; then
    error_exit "Failed to execute restore_sc.sh on Proxmox server."
  fi
  log "restore_sc.sh executed successfully on Proxmox server."
}

log "Starting remote script execution process..."
source_env
execute_remote_script
log "Remote script execution process complete."
