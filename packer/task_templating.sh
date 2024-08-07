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

# Check for global debug mode
DEBUG_MODE=false
if [[ "$1" == "--debug" ]]; then
  DEBUG_MODE=true
  shift
fi

create_win10() {
  cd "$PACKER_DIR/win10"

  # Initialize Packer configuration
  packer init .
  # Enable verbose logging for Packer
  export PACKER_LOG=1
  # Define a log file path
  export PACKER_LOG_PATH="$PACKER_DIR/win10/packer.log"
  echo "[+] Building Windows 10 template in: $(pwd)"
  # Run Packer build with verbosity and optionally in debug mode
  if [ "$DEBUG_MODE" = true ]; then
    packer build -debug .
  else
    packer build .
  fi
  # Navigate back to the original directory
  cd "$PACKER_DIR"
  # Log success message
  log "Windows 10 template created successfully."
}

create_win11_uefi() {
  cd "$PACKER_DIR/win11-uefi"

  packer init .
  # Enable verbose logging for Packer
  export PACKER_LOG=1
  # Define a log file path
  export PACKER_LOG_PATH="$PACKER_DIR/win11-uefi/packer.log"
  echo "[+] Building Windows 11 UEFI template in: $(pwd)"
  # Run Packer build with verbosity and optionally in debug mode
  if [ "$DEBUG_MODE" = true ]; then
    packer build -debug .
  else
    packer build .
  fi
  cd "$PACKER_DIR"
  log "Windows 11 UEFI template created successfully."
}

create_win2019() {
  cd "$PACKER_DIR/win2019"

  packer init .
  # Enable verbose logging for Packer
  export PACKER_LOG=1
  # Define a log file path
  export PACKER_LOG_PATH="$PACKER_DIR/win2019/packer.log"
  echo "[+] Building Windows Server 2019 template in: $(pwd)"
  # Run Packer build with verbosity and optionally in debug mode
  if [ "$DEBUG_MODE" = true ]; then
    packer build -debug .
  else
    packer build .
  fi
  cd "$PACKER_DIR"
  log "Windows Server 2019 template created successfully."
}

create_ubuntu() {
  cd "$PACKER_DIR/ubuntu-server"

  packer init .
  # Enable verbose logging for Packer
  export PACKER_LOG=1
  # Define a log file path
  export PACKER_LOG_PATH="$PACKER_DIR/ubuntu-server/packer.log"
  echo "[+] Building Ubuntu Server template in: $(pwd)"
  # Run Packer build with verbosity and optionally in debug mode
  if [ "$DEBUG_MODE" = true ]; then
    packer build -debug .
  else
    packer build .
  fi
  cd "$PACKER_DIR"
  log "Ubuntu Server template created successfully."
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
