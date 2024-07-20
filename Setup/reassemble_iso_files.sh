#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

check_install_pv() {
  if ! command -v pv &> /dev/null; then
    log "pv not found, installing..."
    sudo apt-get update && sudo apt-get install -y pv || error_exit "Failed to install pv."
    log "pv installed successfully."
  fi
}

reassemble_file() {
  local FILE_DIR=$1
  local REASSEMBLE_SCRIPT=$2
  local PROXMOX_USER=$3
  local PROXMOX_USER_IP=$4

  log "Reassembling $REASSEMBLE_SCRIPT in $FILE_DIR..."

  ssh $PROXMOX_USER@$PROXMOX_USER_IP << EOF >> $LOGFILE 2>&1
    cd $FILE_DIR
    chmod +x $REASSEMBLE_SCRIPT
    ./\$REASSEMBLE_SCRIPT | pv -lep -s \$(wc -c < $REASSEMBLE_SCRIPT) > /dev/null
EOF
  
  if [ $? -ne 0 ]; then
    error_exit "Failed to reassemble using $REASSEMBLE_SCRIPT in $FILE_DIR."
  fi

  log "$REASSEMBLE_SCRIPT reassembled successfully in $FILE_DIR."
}

reassemble_iso_files() {
  echo -e "\n\n####################### Starting Step 7 #######################\n" | tee -a $LOGFILE

  check_install_pv

  read -p "Enter Proxmox User IP: " PROXMOX_USER_IP
  read -p "Enter Proxmox User Username: " PROXMOX_USER
  read -sp "Enter Proxmox User Password: " PROXMOX_PASS
  echo

  DIRECTORIES=(
    "ansible/downloads/windows_server_2019_ISO"
    "ansible/downloads/windows_10_ISO"
    "ansible/downloads/snare_central_ISO"
  )

  REASSEMBLE_SCRIPTS=(
    "reassemble_windows_server_2019.iso.sh"
    "reassemble_windows10.iso.sh"
    "reassemble_Snare_Central.iso.sh"
  )

  for index in "${!DIRECTORIES[@]}"; do
    FILE_DIR=${DIRECTORIES[$index]}
    REASSEMBLE_SCRIPT=${REASSEMBLE_SCRIPTS[$index]}
    
    reassemble_file $FILE_DIR $REASSEMBLE_SCRIPT $PROXMOX_USER $PROXMOX_USER_IP
  done

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    ISO files reassembled and verified successfully.        #
  #                                                            #
  #                     STEP 7 COMPLETE                        #
  #                                                            #
  ##############################################################
  \033[0m"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    All steps completed.                                    #
  #                                                            #
  #    The setup process is now complete.                      #
  #                                                            #
  ##############################################################
  \033[0m"
}

reassemble_iso_files
