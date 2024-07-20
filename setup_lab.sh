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

validate_proxmox_credentials() {
  log "Validating Proxmox credentials..."
  if ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 $PROXMOX_USER@$PROXMOX_IP "echo 2>&1" && [ $? -eq 0 ]; then
    log "Proxmox credentials validated successfully."
    return 0
  else
    log "Failed to validate Proxmox credentials."
    return 1
  fi
}

initialize_proxmox_credentials() {
  check_install_whiptail

  while true; do
    PROXMOX_IP=$(whiptail --inputbox "Enter Proxmox IP Address:" 8 78 --title "Proxmox Setup" 3>&1 1>&2 2>&3)
    PROXMOX_USER=$(whiptail --inputbox "Enter Proxmox Username:" 8 78 --title "Proxmox Setup" 3>&1 1>&2 2>&3)
    PROXMOX_PASS=$(whiptail --passwordbox "Enter Proxmox Password:" 8 78 --title "Proxmox Setup" 3>&1 1>&2 2>&3)

    if [ -z "$PROXMOX_IP" ] || [ -z "$PROXMOX_USER" ] || [ -z "$PROXMOX_PASS" ]; then
      error_exit "Proxmox credentials are required."
    fi

    log "Testing Proxmox credentials..."
    if validate_proxmox_credentials; then
      cat <<EOL > proxmox_credentials.conf
PROXMOX_IP=$PROXMOX_IP
PROXMOX_USER=$PROXMOX_USER
PROXMOX_PASS=$PROXMOX_PASS
EOL

      whiptail --msgbox "Proxmox credentials saved. Proceeding with the setup." 8 78 --title "Proxmox Setup"
      log "Proxmox credentials initialized."
      break
    else
      whiptail --msgbox "Invalid Proxmox credentials. Please try again." 8 78 --title "Error"
    fi
  done
}

update_system_and_install_dependencies() {
  echo -e "\n\n####################### Starting Step 1 #######################\n" | tee -a $LOGFILE

  log "Updating and upgrading the system, and installing required packages..."

  sudo apt update && sudo apt upgrade -y && \
  sudo apt install -y git gpg nano tmux curl gnupg software-properties-common mkisofs python3-venv python3 python3-pip unzip mono-complete coreutils whiptail pv sshpass || error_exit "Failed to update and install required packages."

  log "System update and installation of dependencies completed."
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

  whiptail --msgbox "System update and installation of dependencies completed. Virtual environment setup completed. Next, running the project scripts." 8 78 --title "Step 1 Complete"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the project scripts.                 #
  #                                                            #
  ##############################################################
  \033[0m"

  # Now you can proceed with the next steps in your setup process
}

main() {
  initialize_proxmox_credentials
  update_system_and_install_dependencies
  prepare_project
}

main
