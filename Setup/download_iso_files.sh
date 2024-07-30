#!/bin/bash

LOGFILE=~/Git_Project/Snare_Lab_POC/setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

echo "[+] Build iso for scripts"
mkisofs -J -l -R -V "scripts CD" -iso-level 4 -o ~/Git_Project/Snare_Lab_POC/ansible/images/scripts_withcloudinit.iso ~/Git_Project/Snare_Lab_POC/Setup/scripts

download_iso_files() {
  echo -e "\n\n####################### Starting Step 5 #######################\n" | tee -a $LOGFILE

  log "Downloading ISO files and other required files locally..."

  cd ~/Git_Project/Snare_Lab_POC/ansible || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/ansible/"

  FILES=(
    #"https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/ubuntu-22.iso"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/virtio-win.iso"
    #"https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partaa"
    #"https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partab"
    #"https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partac"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/snare_central.vma.zst.partaa"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/snare_central.vma.zst.partab"
    #"https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partaa"
    #"https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partab"
    #"https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partac"
  )

  FILENAMES=(
    #"ubuntu-22.iso"
    "virtio-win.iso"
    #"windows10.iso.partaa"
    #"windows10.iso.partab"
    "windows10.iso.partac"
    "snare_central.vma.zst.partaa"
    "snare_central.vma.zst.partab"
    #"windows_server_2019.iso.partaa"
    #"windows_server_2019.iso.partab"
    #"windows_server_2019.iso.partac"
  )

  DIRECTORIES=(
    #"images/ubuntu_22_iso"
    "images"
    #"images/windows_10_iso"
    #"images/windows_10_iso"
    #"images/windows_10_iso"
    "images/snare_central_iso"
    "images/snare_central_iso"
    #"images/windows_server_2019_iso"
    #"images/windows_server_2019_iso"
    #"images/windows_server_2019_iso"
  )

  for index in "${!FILES[@]}"; do
    FILE_URL=${FILES[$index]}
    FILE_NAME=${FILENAMES[$index]}
    FILE_DIR=${DIRECTORIES[$index]}
    log "Downloading $FILE_NAME from $FILE_URL to $FILE_DIR..."

    if [ ! -f "$FILE_DIR/$FILE_NAME" ]; then
      wget -O "$FILE_DIR/$FILE_NAME" "$FILE_URL"
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
  #    ISO files and required files downloaded successfully    #
  #                                                            #
  #                     STEP 5 COMPLETE                        #
  #                                                            #
  ##############################################################
  \033[0m"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Run the following command:                   #
  #                                                            #
  #    ./download_snare_files.sh                               #
  #                                                            #
  ##############################################################
  \033[0m"
}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT download_snare_files.sh"
  cd ~/Git_Project/Snare_Lab_POC/Setup || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/Setup"
  ./download_snare_files.sh
}

download_iso_files
run_next_script
