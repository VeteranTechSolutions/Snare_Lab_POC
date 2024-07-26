#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

make_update_script_executable() {
  log "Making update script executable..."
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/setup_credentials.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/update_system_and_install_dependencies.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/configure_user_and_replace_placeholders.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/download_iso_files.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/restore_sc.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/execute_remote_script.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/download_snare_files.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/install_automation_tools.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/reassemble_iso_files.sh 
  chmod +x ~/Git_Project/Snare_Lab_POC/Setup/transfer_files.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/ansible/images/windows_10_iso/reassemble_windows_10.iso.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/ansible/images/windows_server_2019_iso/reassemble_windows_server_2019.iso.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/ansible/images/snare_central_iso/reassemble_snare_central.iso.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/terraform/task_terraforming.sh
  chmod +x ~/Git_Project/Snare_Lab_POC/packer/task_templating.sh
}



get_proxmox_credentials() {
  echo -e "\n\n####################### Getting Proxmox Credentials #######################\n" | tee -a $LOGFILE

  read -p "Enter Proxmox IP: " PROXMOX_IP
  read -p "Enter Proxmox User: " PROXMOX_USER
  read -p "Enter Proxmox Node Name: " PROXMOX_NODE_NAME
  read -s -p "Enter Proxmox Password: " PROXMOX_PASSWORD
  
  echo

  # Save credentials to a specified location
  SSHENV_PATH=~/Git_Project/Snare_Lab_POC/SSHENV
  cat <<EOL > $SSHENV_PATH
export PROXMOX_IP="$PROXMOX_IP"
export PROXMOX_USER="$PROXMOX_USER"
export PROXMOX_NODE_NAME="$PROXMOX_NODE_NAME"
export PROXMOX_PASSWORD="$PROXMOX_PASSWORD"

EOL

  log "Proxmox credentials saved to $SSHENV_PATH"
}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT update_system_and_install_dependencies.sh"
  cd ~/Git_Project/Snare_Lab_POC/Setup
  ./update_system_and_install_dependencies.sh
}

get_proxmox_credentials
run_next_script
