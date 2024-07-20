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

reassemble_file() {
  local parts_path=$1
  local output_file=$2
  local checksum_file=$3

  log "Reassembling the parts for $output_file..."

  cat $parts_path/* > $output_file || error_exit "Failed to reassemble $output_file."

  log "Reassembled file $output_file."
  
  log "Generating checksum for $output_file..."
  shasum -a 256 $output_file > reassembled_checksum.txt || error_exit "Failed to generate checksum for $output_file."

  log "Comparing checksums..."
  if diff $checksum_file reassembled_checksum.txt > /dev/null; then
    log "Checksum verification passed for $output_file. The files are identical."
  else
    error_exit "Checksum verification failed for $output_file. The files are not identical."
  fi

  log "Cleaning up temporary checksum file..."
  rm reassembled_checksum.txt || error_exit "Failed to clean up temporary checksum file."

  log "Reassembly and verification of $output_file completed successfully."
}

main() {
  reassemble_file "ansible/downloads/windows_10_ISO" "ansible/downloads/windows_10_ISO/reassembled_windows10.iso" "ansible/downloads/windows_10_ISO/windows10_original_checksum.txt"
  reassemble_file "ansible/downloads/windows_server_2019_ISO" "ansible/downloads/windows_server_2019_ISO/reassembled_windows_server_2019.iso" "ansible/downloads/windows_server_2019_ISO/windows_server_2019_original_checksum.txt"
  reassemble_file "ansible/downloads/snare_central_ISO" "ansible/downloads/snare_central_ISO/reassembled_snare_central.iso" "ansible/downloads/snare_central_ISO/Snare_Central_original_checksum.txt"

  whiptail --msgbox "ISO files reassembled and verified successfully. Next, running ./install_snare_agents.sh" 8 78 --title "Step 6 Complete"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./install_snare_agents.sh                               #
  #                                                            #
  ##############################################################
  \033[0m"

  # Make the next script executable and run it
  chmod +x ./install_snare_agents.sh || error_exit "Failed to make install_snare_agents.sh executable."
  ./install_snare_agents.sh
}

main
