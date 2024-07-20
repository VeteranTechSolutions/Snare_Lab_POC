#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

reassemble_iso_files() {
  log "Reassembling the parts of the ISO files..."

  # Reassemble Windows 10 ISO
  echo "Reassembling Windows 10 ISO..."
  cd ansible/downloads/windows_10_ISO
  cat windows10.iso.part* > windows10.iso
  shasum -a 256 windows10.iso > reassembled_checksum.txt
  if diff windows10_original_checksum.txt reassembled_checksum.txt > /dev/null; then
    log "Windows 10 ISO checksum verification passed."
  else
    log "Windows 10 ISO checksum verification failed."
  fi
  rm reassembled_checksum.txt

  # Reassemble Windows Server 2019 ISO
  echo "Reassembling Windows Server 2019 ISO..."
  cd ../windows_server_2019_ISO
  cat windows_server_2019.iso.part* > windows_server_2019.iso
  shasum -a 256 windows_server_2019.iso > reassembled_checksum.txt
  if diff windows_server_2019_original_checksum.txt reassembled_checksum.txt > /dev/null; then
    log "Windows Server 2019 ISO checksum verification passed."
  else
    log "Windows Server 2019 ISO checksum verification failed."
  fi
  rm reassembled_checksum.txt

  # Reassemble Snare Central VMA
  echo "Reassembling Snare Central VMA..."
  cd ../snare_central_ISO
  cat Snare_Central.vma.zst.part* > Snare_Central.vma.zst
  shasum -a 256 Snare_Central.vma.zst > reassembled_checksum.txt
  if diff Snare_Central_original_checksum.txt reassembled_checksum.txt > /dev/null; then
    log "Snare Central VMA checksum verification passed."
  else
    log "Snare Central VMA checksum verification failed."
  fi
  rm reassembled_checksum.txt

  log "Reassembling of ISO files completed."
}

main() {
  reassemble_iso_files

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Uploading the ISO files to Proxmox host      #
  #                                                            #
  #    ./upload_iso_to_proxmox.sh                              #
  #                                                            #
  ##############################################################
  \033[0m"

  # Make the next script executable
  chmod +x ./upload_iso_to_proxmox.sh
}

main
