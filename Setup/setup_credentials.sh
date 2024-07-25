#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

get_proxmox_credentials() {
  echo -e "\n\n####################### Getting Proxmox Credentials #######################\n" | tee -a $LOGFILE

  read -p "Enter Proxmox IP: " PROXMOX_IP
  read -p "Enter Proxmox User: " PROXMOX_USER
  read -s -p "Enter Proxmox Password: " PROXMOX_PASSWORD
  echo

  # Save credentials to a local variable file
  cat <<EOL > SSHENV
export PROXMOX_IP="$PROXMOX_IP"
export PROXMOX_USER="$PROXMOX_USER"
export PROXMOX_PASSWORD="$PROXMOX_PASSWORD"
EOL

  log "Proxmox credentials saved to SSHENV"
}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT update_system_and_install_dependencies.sh"
  cd ~/Git_Project/Snare_Lab_POC/Setup
  ./update_system_and_install_dependencies.sh
}

get_proxmox_credentials
run_next_script
