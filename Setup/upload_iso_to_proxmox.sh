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

source_env() {
  if [ -f proxmox_credentials.conf ]; then
    log "Sourcing proxmox_credentials.conf file..."
    source proxmox_credentials.conf
  else
    error_exit "proxmox_credentials.conf file not found! Exiting..."
  fi
}

upload_iso() {
  local iso_file=$1

  log "Uploading $iso_file to Proxmox host..."

  sshpass -p $PROXMOX_PASS scp -o StrictHostKeyChecking=no $iso_file $PROXMOX_USER@$PROXMOX_IP:/var/lib/vz/template/iso/ || error_exit "Failed to upload $iso_file to Proxmox host."

  log "Uploaded $iso_file to Proxmox host successfully."
}

main() {
  source_env

  upload_iso "ansible/downloads/windows_10_ISO/reassembled_windows10.iso"
  upload_iso "ansible/downloads/windows_server_2019_ISO/reassembled_windows_server_2019.iso"
  upload_iso "ansible/downloads/snare_central_ISO/reassembled_snare_central.iso"
  upload_iso "ansible/downloads/virtio-win.iso"

  whiptail --msgbox "ISO files uploaded to Proxmox host successfully. Setup is complete." 8 78 --title "Setup Complete"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    SETUP COMPLETE: All ISO files uploaded successfully.    #
  #                                                            #
  ##############################################################
  \033[0m"
}

main
