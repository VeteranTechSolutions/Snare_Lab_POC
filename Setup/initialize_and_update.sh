#!/bin/bash

LOGFILE=setup.log
PROJECT_ROOT="Snare_Lab_POC"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  whiptail --msgbox "ERROR: $1" 8 78 --title "Error"
  exit 1
}

check_install_whiptail() {
  if ! command -v whiptail &> /dev/null; then
    log "whiptail not found, installing..."
    sudo apt-get update && sudo apt-get install -y whiptail || error_exit "Failed to install whiptail."
    log "whiptail installed successfully."
  fi
}

initialize_proxmox_credentials() {
  check_install_whiptail

  PROXMOX_IP=$(whiptail --inputbox "Enter Proxmox IP Address:" 8 78 --title "Proxmox Setup" 3>&1 1>&2 2>&3)
  PROXMOX_USER=$(whiptail --inputbox "Enter Proxmox Username:" 8 78 --title "Proxmox Setup" 3>&1 1>&2 2>&3)
  PROXMOX_PASS=$(whiptail --passwordbox "Enter Proxmox Password:" 8 78 --title "Proxmox Setup" 3>&1 1>&2 2>&3)

  if [ -z "$PROXMOX_IP" ] || [ -z "$PROXMOX_USER" ] || [ -z "$PROXMOX_PASS" ]; then
    error_exit "Proxmox credentials are required."
  fi

  cat <<EOL > proxmox_credentials.conf
PROXMOX_IP=$PROXMOX_IP
PROXMOX_USER=$PROXMOX_USER
PROXMOX_PASS=$PROXMOX_PASS
EOL

  whiptail --msgbox "Proxmox credentials saved. Proceeding with the setup." 8 78 --title "Proxmox Setup"

  log "Proxmox credentials initialized."
}

update_system_and_install_dependencies() {
  echo -e "\n\n####################### Starting Step 1 #######################\n" | tee -a $LOGFILE

  log "Updating and upgrading the system, and installing required packages..."

  {
    sudo apt update && sudo apt upgrade -y && \
    sudo apt install -y git gpg nano tmux curl gnupg software-properties-common mkisofs python3-venv python3 python3-pip unzip mono-complete coreutils whiptail pv
  } | tee -a $LOGFILE | whiptail --gauge "Updating and upgrading the system, and installing required packages..." 8 78 0

  if [ $? -ne 0 ]; then
    error_exit "Failed to update and install required packages."
  fi

  log "System update and installation of dependencies completed."

  log "Changing to the project root directory..."
  cd $PROJECT_ROOT || error_exit "Failed to change to the project root directory."

  whiptail --msgbox "System update and installation of dependencies completed. Next, running ./source_venv.sh" 8 78 --title "Step 1 Complete"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./source_venv.sh                                        #
  #                                                            #
  ##############################################################
  \033[0m"

  # Run the next script
  ./source_venv.sh
}

main() {
  initialize_proxmox_credentials
  update_system_and_install_dependencies
}

main
