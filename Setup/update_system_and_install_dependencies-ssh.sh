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
  cat <<EOL > proxmox_credentials.sh
PROXMOX_IP="$PROXMOX_IP"
PROXMOX_USER="$PROXMOX_USER"
PROXMOX_PASSWORD="$PROXMOX_PASSWORD"
EOL

  log "Proxmox credentials saved to proxmox_credentials.sh"
}

update_system_and_install_dependencies() {
  echo -e "\n\n####################### Starting Step 2 #######################\n" | tee -a $LOGFILE
  
  log "Starting system update and upgrade..."
  sudo apt update && sudo apt upgrade -y || error_exit "System update and upgrade failed."
  log "System update and upgrade completed."

  echo -e "\n\n####################### Installing Required Packages #######################\n" | tee -a $LOGFILE
  
  log "Installing required packages: git, gpg, nano, tmux, curl, gnupg, software-properties-common, mkisofs, python3-venv, python3, python3-pip, unzip, mono-complete, coreutils..."
  sudo apt install -y git gpg nano tmux curl gnupg software-properties-common sshpass mkisofs python3-venv python3 python3-pip unzip mono-complete coreutils || error_exit "Failed to install required packages."
  log "Installation of required packages completed."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    System updated and dependencies installed successfully  #
  #                                                            #
  #                     STEP 2 COMPLETE                        #
  #                                                            #
  ##############################################################
  \033[0m"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Run the following command:                   #
  #                                                            #
  #    ./configure_user_and_replace_placeholders.sh            #
  #                                                            #
  ##############################################################
  \033[0m"
}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT configure_user_and_replace_placeholders.sh"
  cd ~/Git_Project/Snare_Lab_POC/Setup
  ./configure_user_and_replace_placeholders.sh
}

get_proxmox_credentials
update_system_and_install_dependencies
run_next_script
