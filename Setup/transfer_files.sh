#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

source_env() {
  SSHENV_PATH=~/Git_Project/Snare_Lab_POC/SSHENV
  if [ -f $SSHENV_PATH ]; then
    log "Sourcing SSHENV file..."
    source $SSHENV_PATH
  else
    error_exit "SSHENV file not found at $SSHENV_PATH! Exiting..."
  fi
}

transfer_files() {
  echo -e "\n\n####################### Starting File Transfer #######################\n" | tee -a $LOGFILE

  source_env

  log "Transferring local files to Proxmox server..."

  LOCAL_FILES=(
    "~/Git_Project/Snare_Lab_POC/ansible/images/windows_server_2019_iso/windows_server_2019.iso"
    "~/Git_Project/Snare_Lab_POC/ansible/images/windows_10_iso/windows_10.iso"
    "~/Git_Project/Snare_Lab_POC/ansible/images/ubuntu_22_iso/ubuntu-22.iso"
    "~/Git_Project/Snare_Lab_POC/ansible/images/snare_central_iso/snare_central.vma.zst"
  )

  REMOTE_PATHS=(
    "/var/lib/vz/template/iso/windows_server_2019.iso"
    "/var/lib/vz/template/iso/windows_10.iso"
    "/var/lib/vz/template/iso/ubuntu-22.iso"
    "/var/lib/vz/dump/snare_central.vma.zst"
  )

  for index in "${!LOCAL_FILES[@]}"; do
    LOCAL_FILE=${LOCAL_FILES[$index]}
    REMOTE_PATH=${REMOTE_PATHS[$index]}
    log "Transferring $LOCAL_FILE to $REMOTE_PATH on Proxmox server..."

    sshpass -p "$PROXMOX_PASSWORD" scp $LOCAL_FILE $PROXMOX_USER@$PROXMOX_IP:$REMOTE_PATH >> $LOGFILE 2>&1

    if [ $? -ne 0 ]; then
      error_exit "Failed to transfer $LOCAL_FILE to $REMOTE_PATH on Proxmox server."
    else
      log "$LOCAL_FILE transferred successfully to $REMOTE_PATH."
    fi
  done

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    File transfer completed successfully.                   #
  #                                                            #
  ##############################################################
  \033[0m"
}

#run_next_script() {
#  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT task_templating.sh"
#  cd ~/Git_Project/Snare_Lab_POC/terraform
#  ./task_templating.sh
#}

transfer_files
#run_next_script
