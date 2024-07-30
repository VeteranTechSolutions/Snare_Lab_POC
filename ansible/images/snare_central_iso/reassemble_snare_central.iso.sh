#!/bin/bash

LOGFILE=~/Git_Project/Snare_Lab_POC/setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

reassemble_iso() {
  log "Starting reassembly of the parts into a single file..."

  log "Reassembling the parts..."
  cat snare_central.vma.zst.part* > "vzdump-qemu-105-2024_07_25-19_42_45.vma.zst"
  if [ $? -ne 0 ]; then
    error_exit "Failed to reassemble the parts."
  fi

  log "Listing the reassembled file to verify..."
  ls -lh "vzdump-qemu-105-2024_07_25-19_42_45.vma.zst" | tee -a $LOGFILE

  log "Generating checksum for the reassembled file..."
  shasum -a 256 "vzdump-qemu-105-2024_07_25-19_42_45.vma.zst" > reassembled_checksum.txt
  if [ $? -ne 0 ]; then
    error_exit "Failed to generate checksum for the reassembled file."
  fi

  log "Comparing checksums..."
  if diff snare_central_original_checksum.txt reassembled_checksum.txt > /dev/null; then
    log "Checksum verification passed. The files are identical."
  else
    log "Checksum verification failed. The files are not identical."
  fi

  log "Cleaning up the checksum files..."
  rm reassembled_checksum.txt
  if [ $? -ne 0 ]; then
    error_exit "Failed to clean up the checksum files."
  fi

  log "Reassembly and verification completed successfully."
}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT transfer_files.sh"
  cd ~/Git_Project/Snare_Lab_POC/Setup || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/Setup"
  ./transfer_files.sh | tee -a $LOGFILE
  if [ $? -ne 0 ]; then
    error_exit "Failed to run transfer_files.sh"
  fi
}

#run_next_script() {
#  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT reassemble_windows_server_2019.iso.sh"
#  cd ~/Git_Project/Snare_Lab_POC/ansible/images/windows_server_2019_iso/ || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/ansible/images/windows_server_2019_iso/"
#  ./reassemble_windows_server_2019.iso.sh | tee -a $LOGFILE
#  if [ $? -ne 0 ]; then
#    error_exit "Failed to run reassemble_windows_server_2019.iso.sh"
#  fi
#}

#run_next_script() {
#  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT reassemble_windows_10.iso.sh"
#  cd ~/Git_Project/Snare_Lab_POC/ansible/images/windows_10_iso || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/ansible/images/windows_10_iso"
#  ./reassemble_windows_10.iso.sh
#}

reassemble_iso
run_next_script
