#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

download_iso_files() {
  echo -e "\n\n####################### Starting Step 5 #######################\n" | tee -a $LOGFILE

  log "Downloading ISO files and other required files on Proxmox server..."

  read -p "Enter Proxmox User IP: " PROXMOX_USER_IP
  read -p "Enter Proxmox User Username: " PROXMOX_USER
  echo

  FILES=(
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/ubuntu-22.iso"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/virtio-win.iso"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partaa"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partab"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partac"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10_original_checksum.txt"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central.vma.zst.partaa"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central.vma.zst.partab"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central_original_checksum.txt"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/reassemble_Snare_Central.iso.sh"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/reassemble_windows10.iso.sh"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partaa"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partab"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partac"
    "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019_original_checksum.txt"
  )

  FILENAMES=(
    "ubuntu-22.iso"
    "virtio-win.iso"
    "windows10.iso.partaa"
    "windows10.iso.partab"
    "windows10.iso.partac"
    "windows10_original_checksum.txt"
    "Snare_Central.vma.zst.partaa"
    "Snare_Central.vma.zst.partab"
    "Snare_Central_original_checksum.txt"
    "reassemble_Snare_Central.iso.sh"
    "reassemble_windows10.iso.sh"
    "windows_server_2019.iso.partaa"
    "windows_server_2019.iso.partab"
    "windows_server_2019.iso.partac"
    "windows_server_2019_original_checksum.txt"
  )

  DIRECTORIES=(
    "ansible/downloads/ubuntu_ISO"
    "ansible/downloads"
    "ansible/downloads/windows_10_ISO"
    "ansible/downloads/windows_10_ISO"
    "ansible/downloads/windows_10_ISO"
    "ansible/downloads/windows_10_ISO"
    "ansible/downloads/snare_central_ISO"
    "ansible/downloads/snare_central_ISO"
    "ansible/downloads/snare_central_ISO"
    "ansible/downloads/snare_central_ISO"
    "ansible/downloads/windows_10_ISO"
    "ansible/downloads/windows_server_2019_ISO"
    "ansible/downloads/windows_server_2019_ISO"
    "ansible/downloads/windows_server_2019_ISO"
    "ansible/downloads/windows_server_2019_ISO"
  )

  ssh $PROXMOX_USER@$PROXMOX_USER_IP << EOF >> $LOGFILE 2>&1
    mkdir -p ansible/downloads/ubuntu_ISO ansible/downloads/windows_10_ISO ansible/downloads/snare_central_ISO ansible/downloads/windows_server_2019_ISO
EOF

  if [ $? -ne 0 ]; then
    error_exit "Failed to create directories on Proxmox server."
  fi

  log "Directories created on Proxmox server."

  for index in "${!FILES[@]}"; do
    FILE_URL=${FILES[$index]}
    FILE_NAME=${FILENAMES[$index]}
    FILE_DIR=${DIRECTORIES[$index]}
    log "Downloading $FILE_NAME from $FILE_URL to $FILE_DIR..."

    ssh $PROXMOX_USER@$PROXMOX_USER_IP "cd $FILE_DIR && if [ ! -f $FILE_NAME ]; then nohup wget -O $FILE_NAME $FILE_URL & fi" || error_exit "Failed to initiate download of $FILE_NAME."
    log "$FILE_NAME download initiated."
  done

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    ISO files and required files download initiated         #
  #    successfully.                                           #
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
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT install_automation_tools.sh"
  cd ~/Git_Project/Snare_Lab_POC/Setup
  ./download_snare_files.sh
}


download_iso_files
run_next_script
