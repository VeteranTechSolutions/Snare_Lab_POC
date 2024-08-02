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

create_win11_uefi(){
  # Navigate to the Packer directory first
  if [ -d "$PACKER_DIR" ]; then
    cd "$PACKER_DIR/win11_uefi"
    packer init .
    echo "[+] Building Windows 10 template in: $(pwd)"
    packer build .
    cd "$PACKER_DIR"
    log "Windows 11 UEFI template created successfully."
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


# Define the next script variables
NEXT_SCRIPT="task_terraforming.sh"
NEXT_SCRIPT_DIR=~/Git_Project/Snare_Lab_POC/terraform

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT $NEXT_SCRIPT"
  cd "$NEXT_SCRIPT_DIR" || error_exit "Failed to change directory to $NEXT_SCRIPT_DIR"
  ./"$NEXT_SCRIPT"
}

# Initialize each function in the desired order
source_env_POC
create_win10
create_win2019
create_win11_uefi
create_ubuntu
run_next_script
