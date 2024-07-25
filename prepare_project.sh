#!/bin/bash

LOGFILE=setup.log
PROJECT_ROOT=$(pwd)

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

update_system_and_install_dependencies() {
  echo -e "\n\n####################### Starting Setup #######################\n" | tee -a $LOGFILE

  log "Updating and upgrading the system, and installing required packages..."

  sudo apt update && sudo apt upgrade -y
  sudo apt install -y git

  log "System update and installation of dependencies completed."
}

log "Cloning Snare_Lab_POC repository..."
mkdir ~/Git_Project
cd ~/Git_Project
git clone https://github.com/VeteranTechSolutions/Snare_Lab_POC.git

log "Installing python3-venv..."
sudo apt install -y python3-venv || error_exit "Failed to install python3-venv."
log "python3-venv installed successfully."

log "Creating Python virtual environment..."
python3 -m venv Snare_POC_VENV || error_exit "Failed to create Python virtual environment."
log "Python virtual environment created successfully."

prepare_project() {
  log "Making project scripts executable..."
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
  
  
  

  echo -e "\033[1;34m
  ########################################################
  #                                                      #
  #                STEP 1 COMPLETE                       #
  #                                                      #
  ########################################################
  \033[0m"

  echo -e "\033[1;34m
  ##########################################################################################################################################
  #                                                                                                                                        #
  #                                                            NEXT STEP: Run the following commands:                                      #
  #                                                                                                                                        #
  #   source ~/Git_Project/Snare_POC_VENV/bin/activate && ~/Git_Project/Snare_Lab_POC/Setup/setup_credentials.sh                           #
                                                                                                                                           #
  #                                                                                                                                        #
  #                                                                                                                                        #
  #                                                                                                                                        #
  ##########################################################################################################################################
  \033[0m"
}


main() {
  update_system_and_install_dependencies
  prepare_project
}

main
