#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

source_proxmox_credentials() {
  if [ -f proxmox_credentials.conf ]; then
    log "Sourcing Proxmox credentials from proxmox_credentials.conf file..."
    source proxmox_credentials.conf
  else
    log "Proxmox credentials file not found! Exiting..."
    exit 1
  fi
}

upload_iso_to_proxmox() {
  log "Uploading ISO files to Proxmox host..."

  ISO_DIR="/var/lib/vz/template/iso"
  DUMP_DIR="/var/lib/vz/dump"

  # Upload Windows 10 ISO
  log "Uploading Windows 10 ISO..."
  sshpass -p "$PROXMOX_PASS" scp ansible/downloads/windows_10_ISO/windows10.iso $PROXMOX_USER@$PROXMOX_IP:$ISO_DIR
  log "Windows 10 ISO uploaded."

  # Upload Windows Server 2019 ISO
  log "Uploading Windows Server 2019 ISO..."
  sshpass -p "$PROXMOX_PASS" scp ansible/downloads/windows_server_2019_ISO/windows_server_2019.iso $PROXMOX_USER@$PROXMOX_IP:$ISO_DIR
  log "Windows Server 2019 ISO uploaded."

  # Upload Snare Central VMA
  log "Uploading Snare Central VMA..."
  sshpass -p "$PROXMOX_PASS" scp ansible/downloads/snare_central_ISO/Snare_Central.vma.zst $PROXMOX_USER@$PROXMOX_IP:$DUMP_DIR
  log "Snare Central VMA uploaded."

  # Upload VirtIO ISO
  log "Uploading VirtIO ISO..."
  sshpass -p "$PROXMOX_PASS" scp ansible/downloads/virtio-win.iso $PROXMOX_USER@$PROXMOX_IP:$ISO_DIR
  log "VirtIO ISO uploaded."

  log "All ISO files uploaded successfully."
}

main() {
  source_proxmox_credentials
  upload_iso_to_proxmox

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Setup complete.                              #
  #                                                            #
  ##############################################################
  \033[0m"
}

main
