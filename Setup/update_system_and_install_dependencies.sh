#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

update_system_and_install_dependencies() {
  log "Updating and upgrading the system, and installing required packages..."
  sudo apt update && sudo apt upgrade -y || error_exit "System update and upgrade failed."
  sudo apt install -y git gpg nano tmux curl gnupg software-properties-common mkisofs python3-venv python3 python3-pip unzip mono-complete coreutils || error_exit "Failed to ins>
  log "System update and installation of dependencies completed."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    System updated and dependencies installed successfully  #
  #                                                            #
  #    Run the next step: create_venv.sh                       #
  #                                                            #
  ##############################################################
  \033[0m"
}

update_system_and_install_dependencies
