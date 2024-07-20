#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  whiptail --msgbox "ERROR: $1" 8 78 --title "Error"
  exit 1
}

create_venv() {
  echo -e "\n\n####################### Starting Step 2 #######################\n" | tee -a $LOGFILE

  log "Creating and activating Python virtual environment..."

  {
    sudo apt install -y python3-venv && \
    python3 -m venv venv && \
    echo "source $(pwd)/venv/bin/activate" >> ~/.bashrc && \
    source $(pwd)/venv/bin/activate
  } | tee -a $LOGFILE | whiptail --gauge "Creating and activating Python virtual environment..." 8 78 0

  if [ $? -ne 0 ]; then
    error_exit "Failed to create and activate Python virtual environment."
  fi

  log "Python virtual environment created and activated successfully."

  log "Making the next script (configure_user_and_replace_placeholders.sh) executable..."
  chmod +x ../configure_user_and_replace_placeholders.sh || error_exit "Failed to make configure_user_and_replace_placeholders.sh executable."
  log "Next script (configure_user_and_replace_placeholders.sh) is now executable."

  whiptail --msgbox "Python virtual environment created and activated successfully. Next, running ./configure_user_and_replace_placeholders.sh" 8 78 --title "Step 2 Complete"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./configure_user_and_replace_placeholders.sh            #
  #                                                            #
  ##############################################################
  \033[0m"

  # Run the next script
  ../configure_user_and_replace_placeholders.sh
}

main() {
  create_venv
}

main
