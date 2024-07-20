#!/bin/bash

LOGFILE=setup.log
PROJECT_ROOT="Snare_Lab_POC"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

update_system_and_install_dependencies() {
  echo -e "\n\n####################### Starting Step 1 #######################\n" | tee -a $LOGFILE

  log "Updating and upgrading the system, and installing required packages..."

  sudo apt update && sudo apt upgrade -y && \
  sudo apt install -y git gpg nano tmux curl gnupg software-properties-common mkisofs python3-venv python3 python3-pip unzip mono-complete coreutils whiptail pv sshpass || error_exit "Failed to update and install required packages."

  log "System update and installation of dependencies completed."
}

initialize_proxmox_credentials() {
  read -p "Enter Proxmox IP Address: " PROXMOX_IP
  read -p "Enter Proxmox Username: " PROXMOX_USER
  read -sp "Enter Proxmox Password: " PROXMOX_PASS
  echo

  if [ -z "$PROXMOX_IP" ] || [ -z "$PROXMOX_USER" ] || [ -z "$PROXMOX_PASS" ]; then
    error_exit "Proxmox credentials are required."
  fi

  cat <<EOL > proxmox_credentials.conf
PROXMOX_IP=$PROXMOX_IP
PROXMOX_USER=$PROXMOX_USER
PROXMOX_PASS=$PROXMOX_PASS
EOL

  log "Proxmox credentials saved."
}

prepare_project() {
  log "Creating Git_project directory..."
  mkdir -p ~/Git_project || error_exit "Failed to create Git_project directory."
  cd ~/Git_project || error_exit "Failed to change to Git_project directory."

  log "Cloning the Git repository..."
  git clone https://github.com/VeteranTechSolutions/Snare_Lab_POC.git || error_exit "Failed to clone the Git repository."

  log "Changing to the project root directory..."
  cd Snare_Lab_POC || error_exit "Failed to change to the project root directory."

  log "Making create_venv.sh and source_venv.sh executable..."
  chmod +x create_venv.sh || error_exit "Failed to make create_venv.sh executable."
  chmod +x source_venv.sh || error_exit "Failed to make source_venv.sh executable."

  log "Running create_venv.sh..."
  ./create_venv.sh || error_exit "Failed to run create_venv.sh."

  log "Running source_venv.sh..."
  ./source_venv.sh || error_exit "Failed to run source_venv.sh."

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the project scripts.                 #
  #                                                            #
  ##############################################################
  \033[0m"
}

main() {
  update_system_and_install_dependencies
  initialize_proxmox_credentials
  prepare_project
}

main
