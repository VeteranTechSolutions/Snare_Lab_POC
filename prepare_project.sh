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
git clone https://github.com/VeteranTechSolutions/Snare_Lab_POC.git
cd Snare_Lab_POC

log "Installing python3-venv..."
sudo apt install -y python3-venv || error_exit "Failed to install python3-venv."
log "python3-venv installed successfully."

log "Creating Python virtual environment..."
python3 -m venv Snare_POC_VENV || error_exit "Failed to create Python virtual environment."
log "Python virtual environment created successfully."

prepare_project() {
  log "Making project scripts executable..."
  chmod +x ./create_venv.sh
  chmod +x ./Setup/update_system_and_install_dependencies.sh
  chmod +x ./Setup/configure_user_and_replace_placeholders.sh
  chmod +x ./Setup/download_iso_files.sh
  chmod +x ./Setup/download_snare_files.sh
  chmod +x ./Setup/install_automation_tools.sh
  chmod +x ./Setup/reassemble_iso_files.sh
  chmod +x ./Setup/upload_iso.sh

  echo -e "\033[1;34m
  ########################################################
  #                                                      #
  #                STEP 1 COMPLETE                       #
  #                                                      #
  ########################################################
  \033[0m"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Run the following commands:                  #
  #                                                            #
  #    cd ..                                                   #
  #    source Snare_POC_VENV/bin/activate                      #
  #    ./Snare_Lab_POC/Setup/configure_user_and_replace_placeholders.sh  #
  #                                                            #
  ##############################################################
  \033[0m"
}

create_source_env_script() {
  log "Creating source_env.sh script..."
  cat <<EOF > source_env.sh
#!/bin/bash
cd ..
source Snare_POC_VENV/bin/activate
EOF
  chmod +x source_env.sh
  log "source_env.sh script created successfully."
}

main() {
  update_system_and_install_dependencies
  prepare_project
  create_source_env_script
}

main
