#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

download_snare_files() {
  echo -e "\n\n####################### Starting Step 6 #######################\n" | tee -a $LOGFILE

  log "Downloading Snare files to Proxmox server..."

  read -p "Enter Proxmox User IP: " PROXMOX_USER_IP
  read -p "Enter Proxmox User Username: " PROXMOX_USER
  read -sp "Enter Proxmox User Password: " PROXMOX_PASS
  echo

  FILES=(
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Fullyconfigured.inf"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Agent_Manager_Windows_Console_License.sl.txt"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central_License.sl.txt"
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
    "Fullyconfigured.inf"
    "Snare_Agent_Manager_Windows_Console_License.sl.txt"
    "Snare_Central_License.sl.txt"
    "Snare-Epilog-Agent-v5.8.1-x64.exe"
    "Snare-MSSQL-Agent-v5.8.1-x64.exe"
    "Snare-Windows-Agent-.Desktop-Only.-v5.8.1-x64.exe"
    "Snare-Windows-Agent-v5.8.1-x64.exe"
    "Snare-Windows-Agent-WEC-v5.8.1-x64.exe"
    "SnareAM-v2.0.1-x64.msi"
    "snaregenv2"
    "SnareReflector-Windows-x64-v2.5.1.msi"
  )

  ssh $PROXMOX_USER@$PROXMOX_USER_IP << EOF >> $LOGFILE 2>&1
    mkdir -p ansible/downloads/snareproducts
EOF

  if [ $? -ne 0 ]; then
    error_exit "Failed to create directory on Proxmox server."
  fi

  log "Directory created on Proxmox server."

  for index in "${!FILES[@]}"; do
    FILE_URL=${FILES[$index]}
    FILE_NAME=${FILENAMES[$index]}
    log "Downloading $FILE_NAME from $FILE_URL..."

    ssh $PROXMOX_USER@$PROXMOX_USER_IP "cd ansible/downloads/snareproducts && if [ ! -f $FILE_NAME ]; then wget -O $FILE_NAME $FILE_URL && [[ \$FILE_NAME == *.txt ]] && mv \$FILE_NAME \${FILE_NAME%.txt}; fi" || error_exit "Failed to initiate download of $FILE_NAME."
    log "$FILE_NAME download initiated."
  done

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Snare files download initiated successfully.            #
  #                                                            #
  #                     STEP 6 COMPLETE                        #
  #                                                            #
  ##############################################################
  \033[0m"

  log "Making the next script (reassemble_iso_files.sh) executable..."
  chmod +x reassemble_iso_files.sh || error_exit "Failed to make reassemble_iso_files.sh executable."
  log "Next script (reassemble_iso_files.sh) is now executable."

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Run the following command:                   #
  #                                                            #
  #    ./reassemble_iso_files.sh                               #
  #                                                            #
  ##############################################################
  \033[0m"
}

download_snare_files
