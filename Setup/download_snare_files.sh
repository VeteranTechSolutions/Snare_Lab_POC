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

  log "Downloading Snare files locally..."
cd ~/Git_Project/Snare_Lab_POC/ansible

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

  DIRECTORY="snareproducts"

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
      wget -O "$DIRECTORY/$FILE_NAME" "$FILE_URL" || error_exit "Failed to download $FILE_NAME."
      log "$FILE_NAME downloaded successfully."
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
  #    ./reassemble_iso_files.sh                               #
  #                                                            #
  ##############################################################
  \033[0m"
}

make_executable() {
  log "Making Image Script Executables"
   chmod +x ~/Git_Project/Snare_Lab_POC/ansible/windows_10_ISO/reassemble_windows10.iso.sh
   chmod +x ~/Git_Project/Snare_Lab_POC/ansible/windows_10_ISO/reassemble_ windows_server_2019.iso.sh
   chmod +x ~/Git_Project/Snare_Lab_POC/ansible/windows_10_ISO/reassemble_Snare_Central.iso.sh
}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT reassemble_windows10.iso.sh"
  cd ~/Git_Project/Snare_Lab_POC/ansible/windows_10_ISO
  ./reassemble_windows10.iso.sh
}





download_snare_files
make_executable
run_next_script
