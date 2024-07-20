#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

update_system_and_install_dependencies() {
  echo -e "\n\n####################### Starting Step 1 #######################\n" | tee -a $LOGFILE
  
  log "Starting system update and upgrade..."
  sudo apt update && sudo apt upgrade -y || error_exit "System update and upgrade failed."
  log "System update and upgrade completed."

  echo -e "\n\n####################### Installing Required Packages #######################\n" | tee -a $LOGFILE
  
  log "Installing required packages: git, gpg, nano, tmux, curl, gnupg, software-properties-common, mkisofs, python3-venv, python3, python3-pip, unzip, mono-complete, coreutils..."
  sudo apt install -y git gpg nano tmux curl gnupg software-properties-common mkisofs python3-venv python3 python3-pip unzip mono-complete coreutils || error_exit "Failed to install required packages."
  log "Installation of required packages completed."

  log "Making the next script (create_venv.sh) executable..."
  chmod +x create_venv.sh || error_exit "Failed to make create_venv.sh executable."
  log "Next script (create_venv.sh) is now executable."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    System updated and dependencies installed successfully  #
  #                                                            #
  #                     STEP 1 COMPLETE                        #
  #                                                            #
  ##############################################################
  \033[0m"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Run the following command:                   #
  #                                                            #
  #    ./create_venv.sh                                        #
  #                                                            #
  ##############################################################
  \033[0m"
}

update_system_and_install_dependencies
