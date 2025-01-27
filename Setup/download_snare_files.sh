#!/bin/bash

LOGFILE=~/Git_Project/Snare_Lab_POC/setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

download_snare_files() {
  echo -e "\n\n####################### Starting Step 6 #######################\n" | tee -a $LOGFILE

  log "Downloading Snare files locally..."
  cd ~/Git_Project/Snare_Lab_POC/ansible || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/ansible"

  FILES=(
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Epilog-Agent-v5.8.1-x64.exe"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-MSSQL-Agent-v5.8.1-x64.exe"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Windows-Agent-.Desktop-Only.-v5.8.1-x64.exe"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Windows-Agent-v5.8.1-x64.exe"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Windows-Agent-WEC-v5.8.1-x64.exe"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/SnareAM-v2.0.1-x64.msi"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/snaregenv2"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/SnareReflector-Windows-x64-v2.5.1.msi"
  )

  FILENAMES=(
    "Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb"
    "Snare-Epilog-Agent-v5.8.1-x64.exe"
    "Snare-MSSQL-Agent-v5.8.1-x64.exe"
    "Snare-Windows-Agent-.Desktop-Only.-v5.8.1-x64.exe"
    "Snare-Windows-Agent-v5.8.1-x64.exe"
    "Snare-Windows-Agent-WEC-v5.8.1-x64.exe"
    "SnareAM-v2.0.1-x64.msi"
    "snaregenv2"
    "SnareReflector-Windows-x64-v2.5.1.msi"
  )

  DIRECTORY="snare_products"

  mkdir -p "$DIRECTORY"

  if [ $? -ne 0 ]; then
    error_exit "Failed to create directory locally."
  fi

  log "Directory created locally."

  for index in "${!FILES[@]}"; do
    FILE_URL=${FILES[$index]}
    FILE_NAME=${FILENAMES[$index]}
    log "Downloading $FILE_NAME from $FILE_URL to $DIRECTORY..."

    if [ ! -f "$DIRECTORY/$FILE_NAME" ]; then
      wget -O "$DIRECTORY/$FILE_NAME" "$FILE_URL"
      if [ $? -ne 0 ]; then
        error_exit "Failed to download $FILE_NAME."
      else
        log "$FILE_NAME downloaded successfully."
      fi
    else
      log "$FILE_NAME already exists. Skipping download."
    fi
  done

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Snare files downloaded successfully.                    #
  #                                                            #
  #                     STEP 6 COMPLETE                        #
  #                                                            #
  ##############################################################
  \033[0m"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Run the following command:                   #
  #                                                            #
  #    ./reassemble_windows_10.iso.sh                              #
  #                                                            #
  ##############################################################
  \033[0m"
}

#run_next_script() {
#  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT reassemble_snare_central.iso.sh"
#  cd ~/Git_Project/Snare_Lab_POC/ansible/images/snare_central_iso || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/ansible/images/snare_central_iso"
#  ./reassemble_snare_central.iso.sh | tee -a $LOGFILE
#  if [ $? -ne 0 ]; then
#    error_exit "Failed to run reassemble_snare_central.iso.sh"
#  fi
#}

download_snare_files
#run_next_script
