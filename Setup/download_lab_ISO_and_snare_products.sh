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

create_directories() {
  log "Creating necessary directories for ISO files and Snare products..."
  mkdir -p ansible/downloads/windows_10_ISO
  mkdir -p ansible/downloads/windows_server_2019_ISO
  mkdir -p ansible/downloads/snare_central_ISO
  mkdir -p ansible/downloads/snareproducts
  log "Directories created successfully."
}

download_files() {
  log "Downloading ISO files and Snare products..."

  log "Downloading Windows 10 ISO files..."
  curl -L -o ansible/downloads/windows_10_ISO/windows10.iso.partaa https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partaa || error_exit "Failed to download windows10.iso.partaa."
  curl -L -o ansible/downloads/windows_10_ISO/windows10.iso.partab https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partab || error_exit "Failed to download windows10.iso.partab."
  curl -L -o ansible/downloads/windows_10_ISO/windows10.iso.partac https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partac || error_exit "Failed to download windows10.iso.partac."
  curl -L -o ansible/downloads/windows_10_ISO/windows10_original_checksum.txt https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10_original_checksum.txt || error_exit "Failed to download windows10_original_checksum.txt."

  log "Downloading Windows Server 2019 ISO files..."
  curl -L -o ansible/downloads/windows_server_2019_ISO/windows_server_2019.iso.partaa https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partaa || error_exit "Failed to download windows_server_2019.iso.partaa."
  curl -L -o ansible/downloads/windows_server_2019_ISO/windows_server_2019.iso.partab https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partab || error_exit "Failed to download windows_server_2019.iso.partab."
  curl -L -o ansible/downloads/windows_server_2019_ISO/windows_server_2019.iso.partac https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partac || error_exit "Failed to download windows_server_2019.iso.partac."
  curl -L -o ansible/downloads/windows_server_2019_ISO/windows_server_2019_original_checksum.txt https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019_original_checksum.txt || error_exit "Failed to download windows_server_2019_original_checksum.txt."

  log "Downloading Snare Central ISO files..."
  curl -L -o ansible/downloads/snare_central_ISO/Snare_Central.vma.zst.partaa https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central.vma.zst.partaa || error_exit "Failed to download Snare_Central.vma.zst.partaa."
  curl -L -o ansible/downloads/snare_central_ISO/Snare_Central.vma.zst.partab https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central.vma.zst.partab || error_exit "Failed to download Snare_Central.vma.zst.partab."
  curl -L -o ansible/downloads/snare_central_ISO/Snare_Central_original_checksum.txt https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central_original_checksum.txt || error_exit "Failed to download Snare_Central_original_checksum.txt."
  curl -L -o ansible/downloads/snare_central_ISO/reassemble_Snare_Central.iso.sh https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/reassemble_Snare_Central.iso.sh || error_exit "Failed to download reassemble_Snare_Central.iso.sh."
  chmod +x ansible/downloads/snare_central_ISO/reassemble_Snare_Central.iso.sh || error_exit "Failed to make reassemble_Snare_Central.iso.sh executable."

  log "Downloading VirtIO driver..."
  curl -L -o ansible/downloads/virtio-win.iso https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/virtio-win.iso || error_exit "Failed to download virtio-win.iso."

  log "Downloading Snare products..."
  curl -L -o ansible/downloads/snareproducts/Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb || error_exit "Failed to download Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb."
  curl -L -o ansible/downloads/snareproducts/Fullyconfigured.inf https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Fullyconfigured.inf || error_exit "Failed to download Fullyconfigured.inf."
  curl -L -o ansible/downloads/snareproducts/Snare_Agent_Manager_Windows_Console_License.sl.txt https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Agent_Manager_Windows_Console_License.sl.txt || error_exit "Failed to download Snare_Agent_Manager_Windows_Console_License.sl.txt."
  mv ansible/downloads/snareproducts/Snare_Agent_Manager_Windows_Console_License.sl.txt ansible/downloads/snareproducts/Snare_Agent_Manager_Windows_Console_License.sl || error_exit "Failed to rename Snare_Agent_Manager_Windows_Console_License.sl.txt."
  curl -L -o ansible/downloads/snareproducts/Snare_Central_License.sl.txt https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central_License.sl.txt || error_exit "Failed to download Snare_Central_License.sl.txt."
  mv ansible/downloads/snareproducts/Snare_Central_License.sl.txt ansible/downloads/snareproducts/Snare_Central_License.sl || error_exit "Failed to rename Snare_Central_License.sl.txt."
  curl -L -o ansible/downloads/snareproducts/Snare-Epilog-Agent-v5.8.1-x64.exe https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Epilog-Agent-v5.8.1-x64.exe || error_exit "Failed to download Snare-Epilog-Agent-v5.8.1-x64.exe."
  curl -L -o ansible/downloads/snareproducts/Snare-MSSQL-Agent-v5.8.1-x64.exe https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-MSSQL-Agent-v5.8.1-x64.exe || error_exit "Failed to download Snare-MSSQL-Agent-v5.8.1-x64.exe."
  curl -L -o ansible/downloads/snareproducts/Snare-Windows-Agent-.Desktop-Only.-v5.8.1-x64.exe https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Windows-Agent-.Desktop-Only.-v5.8.1-x64.exe || error_exit "Failed to download Snare-Windows-Agent-.Desktop-Only.-v5.8.1-x64.exe."
  curl -L -o ansible/downloads/snareproducts/Snare-Windows-Agent-v5.8.1-x64.exe https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Windows-Agent-v5.8.1-x64.exe || error_exit "Failed to download Snare-Windows-Agent-v5.8.1-x64.exe."
  curl -L -o ansible/downloads/snareproducts/Snare-Windows-Agent-WEC-v5.8.1-x64.exe https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Windows-Agent-WEC-v5.8.1-x64.exe || error_exit "Failed to download Snare-Windows-Agent-WEC-v5.8.1-x64.exe."
  curl -L -o ansible/downloads/snareproducts/SnareAM-v2.0.1-x64.msi https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/SnareAM-v2.0.1-x64.msi || error_exit "Failed to download SnareAM-v2.0.1-x64.msi."
  curl -L -o ansible/downloads/snareproducts/snaregenv2 https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/snaregenv2 || error_exit "Failed to download snaregenv2."
  curl -L -o ansible/downloads/snareproducts/SnareReflector-Windows-x64-v2.5.1.msi https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/SnareReflector-Windows-x64-v2.5.1.msi || error_exit "Failed to download SnareReflector-Windows-x64-v2.5.1.msi."

  log "All files downloaded successfully."
}

main() {
  create_directories
  download_files

  whiptail --msgbox "ISO files and Snare products downloaded successfully. Next, running ./reassemble_iso_files.sh" 8 78 --title "Step 5 Complete"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./reassemble_iso_files.sh                               #
  #                                                            #
  ##############################################################
  \033[0m"

  # Make the next script executable and run it
  chmod +x ./reassemble_iso_files.sh || error_exit "Failed to make reassemble_iso_files.sh executable."
  ./reassemble_iso_files.sh
}

main
