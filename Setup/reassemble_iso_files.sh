#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

reassemble_iso_files() {
  echo -e "\n\n####################### Starting Step 7 #######################\n" | tee -a $LOGFILE

  log "Reassembling the parts of the ISO files..."
  mkdir ~/Git_Project/Snare_Lab_POC/ansible/images

  FILES=(
    "windows_server_2019.iso"
    "windows10.iso"
    "Snare_Central.vma.zst"
  )

  DIRECTORIES=(
    "windows_server_2019_ISO"
    "windows_10_ISO"
    "snare_central_ISO"
  )

  REASSEMBLE_SCRIPTS=(
    "reassemble_windows_server_2019.iso.sh"
    "reassemble_windows10.iso.sh"
    "reassemble_Snare_Central.iso.sh"
  )

  for index in "${!FILES[@]}"; do
    FILE_NAME=${FILES[$index]}
    FILE_DIR=${DIRECTORIES[$index]}
    REASSEMBLE_SCRIPT=${REASSEMBLE_SCRIPTS[$index]}
    
    log "Reassembling $FILE_NAME in $FILE_DIR..."
    
    cd $FILE_DIR || error_exit "Failed to change directory to $FILE_DIR."
    chmod +x $REASSEMBLE_SCRIPT
    ./$REASSEMBLE_SCRIPT >> $LOGFILE 2>&1
    
    if [ $? -ne 0 ]; then
      error_exit "Failed to reassemble $FILE_NAME in $FILE_DIR."
    fi

    log "$FILE_NAME reassembled successfully in $FILE_DIR."
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
