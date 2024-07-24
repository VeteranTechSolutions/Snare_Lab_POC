#!/bin/bash

LOGFILE=setup.log
EXPECTED_DIR="Snare_Lab_POC"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

create_venv() {
  echo -e "\n\n####################### Starting Step 2 #######################\n" | tee -a $LOGFILE

  if [ "$(basename $(pwd))" != "$EXPECTED_DIR" ]; then
    error_exit "This script must be run from the $EXPECTED_DIR directory."
  fi

  log "Creating and activating Python virtual environment..."

  log "Installing python3-venv..."
  sudo apt install -y python3-venv || error_exit "Failed to install python3-venv."
  log "python3-venv installed successfully."

  log "Creating Python virtual environment..."
  python3 -m venv venv || error_exit "Failed to create Python virtual environment."
  log "Python virtual environment created successfully."

  log "Updating .bashrc to activate virtual environment on login..."
  echo "source $(pwd)/venv/bin/activate" >> ~/.bashrc
  log ".bashrc updated successfully."

  log "Activating Python virtual environment..."
  source $(pwd)/venv/bin/activate || error_exit "Failed to activate Python virtual environment."
  log "Python virtual environment activated successfully."

  log "Making the next script (configure_user_and_replace_placeholders.sh) executable..."
  chmod +x ./Setup/configure_user_and_replace_placeholders.sh || error_exit "Failed to make configure_user_and_replace_placeholders.sh executable."
  log "Next script (configure_user_and_replace_placeholders.sh) is now executable."

  echo -e "\033[1;32m
  ########################################################
  #                                                      #
  #                STEP 2 COMPLETE                       #
  #                                                      #
  ########################################################
  \033[0m"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Run the following commands:                  #
  #                                                            #
  #    source venv/bin/activate                                #
  #    ./configure_user_and_replace_placeholders.sh            #
  #                                                            #
  ##############################################################
  \033[0m"

  exit 0
}

create_venv
