#!/bin/bash

LOGFILE=~/Git_Project/Snare_Lab_POC/setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

source_env_POC() {
  ENV_PATH=~/Git_Project/Snare_Lab_POC/.env
  if [ -f $ENV_PATH ]; then
    log "Sourcing .env file..."
    source $ENV_PATH
  else
    error_exit ".env file not found at $ENV_PATH! Exiting..."
  fi
}

PACKER_DIR=~/Git_Project/Snare_Lab_POC/packer

create_win10(){
  # Navigate to the Packer directory first
  if [ -d "$PACKER_DIR" ]; then
    cd "$PACKER_DIR/win10"
    packer init .
    echo "[+] Building Windows 10 template in: $(pwd)"
    packer build .
    cd "$PACKER_DIR"
    log "Windows 10 template created successfully."
  else
    log "Packer directory not found!"
  fi
}

create_win2019(){
  # Navigate to the Packer directory first
  if [ -d "$PACKER_DIR" ]; then
    cd "$PACKER_DIR/win2019"
    packer init .
    echo "[+] Building Windows Server 2019 template in: $(pwd)"
    packer build .
    cd "$PACKER_DIR"
    log "Windows Server 2019 template created successfully."
  else
    log "Packer directory not found!"
  fi
}

create_ubuntu(){
  # Navigate to the Packer directory first
  if [ -d "$PACKER_DIR" ]; then
    cd "$PACKER_DIR/ubuntu-server"
    packer init .
    echo "[+] Building Ubuntu Server template in: $(pwd)"
    packer build .
    cd "$PACKER_DIR"
    log "Ubuntu Server template created successfully."
  else
    log "Packer directory not found!"
  fi
}

source_env_vagrant() {
  ENV_PATH=~/Git_Project/Snare_Lab_POC/packer/win11/secrets-proxmox.sh
  if [ -f $ENV_PATH ]; then
    log "Sourcing secrets-proxmox.sh file..."
    source $ENV_PATH
  else
    error_exit "secrets-proxmox.sh file not found at $ENV_PATH! Exiting..."
  fi
}

build_win11(){

log "Changing Directory to log ~/Git_Project/Snare_Lab_POC/packer/win11/"
cd ~/Git_Project/Snare_Lab_POC/packer/win11/

log "Running MAKE Build for windows-11-23h2-uefi-proxmox"
make build-windows-11-23h2-uefi-proxmox

}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT task_terraforming.sh"
  cd ~/Git_Project/Snare_Lab_POC/terraform || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/terraform"
  ./task_terraforming.sh
}

# Initialize each function in the desired order
source_env_POC
create_win10
create_win2019
create_ubuntu
source_env_vagrant
build_win11
run_next_script
