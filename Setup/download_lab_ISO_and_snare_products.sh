#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

download_iso_files() {
  log "Downloading ISO files..."

  mkdir -p ansible/downloads/windows_10_ISO
  mkdir -p ansible/downloads/windows_server_2019_ISO
  mkdir -p ansible/downloads/snare_central_ISO

  wget -O ansible/downloads/virtio-win.iso "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/virtio-win.iso"

  wget -O ansible/downloads/windows_10_ISO/windows10.iso.partaa "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partaa"
  wget -O ansible/downloads/windows_10_ISO/windows10.iso.partab "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partab"
  wget -O ansible/downloads/windows_10_ISO/windows10.iso.partac "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10.iso.partac"
  wget -O ansible/downloads/windows_10_ISO/windows10_original_checksum.txt "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows10_original_checksum.txt"

  wget -O ansible/downloads/windows_server_2019_ISO/windows_server_2019.iso.partaa "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partaa"
  wget -O ansible/downloads/windows_server_2019_ISO/windows_server_2019.iso.partab "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partab"
  wget -O ansible/downloads/windows_server_2019_ISO/windows_server_2019.iso.partac "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019.iso.partac"
  wget -O ansible/downloads/windows_server_2019_ISO/windows_server_2019_original_checksum.txt "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/windows_server_2019_original_checksum.txt"

  wget -O ansible/downloads/snare_central_ISO/Snare_Central.vma.zst.partaa "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central.vma.zst.partaa"
  wget -O ansible/downloads/snare_central_ISO/Snare_Central.vma.zst.partab "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central.vma.zst.partab"
  wget -O ansible/downloads/snare_central_ISO/Snare_Central_original_checksum.txt "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central_original_checksum.txt"

  wget -O ansible/downloads/snare_central_ISO/reassemble_Snare_Central.iso.sh "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/reassemble_Snare_Central.iso.sh"
  wget -O ansible/downloads/windows_10_ISO/reassemble_windows10.iso.sh "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/reassemble_windows10.iso.sh"

  chmod +x ansible/downloads/snare_central_ISO/reassemble_Snare_Central.iso.sh
  chmod +x ansible/downloads/windows_10_ISO/reassemble_windows10.iso.sh

  log "ISO files downloaded successfully."
}

download_snare_files() {
  log "Downloading Snare files..."

  mkdir -p ansible/downloads/snareproducts

  wget -O ansible/downloads/snareproducts/Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb"
  wget -O ansible/downloads/snareproducts/Fullyconfigured.inf "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Fullyconfigured.inf"
  wget -O ansible/downloads/snareproducts/Snare_Agent_Manager_Windows_Console_License.sl "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Agent_Manager_Windows_Console_License.sl.txt"
  wget -O ansible/downloads/snareproducts/Snare_Central_License.sl "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare_Central_License.sl.txt"
  wget -O ansible/downloads/snareproducts/Snare-Epilog-Agent-v5.8.1-x64.exe "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Epilog-Agent-v5.8.1-x64.exe"
  wget -O ansible/downloads/snareproducts/Snare-MSSQL-Agent-v5.8.1-x64.exe "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-MSSQL-Agent-v5.8.1-x64.exe"
  wget -O ansible/downloads/snareproducts/Snare-Windows-Agent-Desktop-Only-v5.8.1-x64.exe "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Windows-Agent-Desktop-Only-v5.8.1-x64.exe"
  wget -O ansible/downloads/snareproducts/Snare-Windows-Agent-v5.8.1-x64.exe "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Windows-Agent-v5.8.1-x64.exe"
  wget -O ansible/downloads/snareproducts/Snare-Windows-Agent-WEC-v5.8.1-x64.exe "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/Snare-Windows-Agent-WEC-v5.8.1-x64.exe"
  wget -O ansible/downloads/snareproducts/SnareAM-v2.0.1-x64.msi "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/SnareAM-v2.0.1-x64.msi"
  wget -O ansible/downloads/snareproducts/snaregenv2 "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/snaregenv2"
  wget -O ansible/downloads/snareproducts/SnareReflector-Windows-x64-v2.5.1.msi "https://github.com/VeteranTechSolutions/Snare_Lab_POC/releases/download/POC_downloads/SnareReflector-Windows-x64-v2.5.1.msi"

  mv ansible/downloads/snareproducts/Snare_Agent_Manager_Windows_Console_License.sl.txt ansible/downloads/snareproducts/Snare_Agent_Manager_Windows_Console_License.sl
  mv ansible/downloads/snareproducts/Snare_Central_License.sl.txt ansible/downloads/snareproducts/Snare_Central_License.sl

  log "Snare files downloaded successfully."
}

main() {
  download_iso_files
  download_snare_files

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./reassemble_iso_files.sh                               #
  #                                                            #
  ##############################################################
  \033[0m"

  # Make the next script executable
  chmod +x ./reassemble_iso_files.sh
}

main
