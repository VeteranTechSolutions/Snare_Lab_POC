#!/bin/bash

LOGFILE=~/Git_Project/Snare_Lab_POC/setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

source_env() {
  ENV_PATH=~/Git_Project/Snare_Lab_POC/.env
  if [ -f $ENV_PATH ]; then
    log "Sourcing .env file..."
    set -o allexport
    source $ENV_PATH
    set +o allexport
  else
    error_exit ".env file not found at $ENV_PATH! Exiting..."
  fi
}

test_ssh_connection() {
  log "Testing SSH connection to Proxmox server..."
  ssh_user="$PROXMOX_USER"
  log "sshpass -p \"$PROXMOX_PASSWORD\" ssh -o StrictHostKeyChecking=no $ssh_user@$PROXMOX_NODE_IP \"echo 'SSH connection successful'\""
  sshpass -p "$PROXMOX_PASSWORD" ssh -o StrictHostKeyChecking=no "$ssh_user@$PROXMOX_NODE_IP" "echo 'SSH connection successful'" >> $LOGFILE 2>&1
  if [ $? -ne 0 ]; then
    error_exit "SSH connection to Proxmox server failed. Please check the credentials and network connectivity."
  fi
  log "SSH connection to Proxmox server successful."
}

transfer_files() {
  echo -e "\n\n####################### Starting File Transfer #######################\n" | tee -a $LOGFILE

  source_env

  log "Transferring local files to Proxmox server..."

  LOCAL_FILES=(
    #"~/Git_Project/Snare_Lab_POC/ansible/images/windows_server_2019_iso/windows_server_2019.iso"
    #"~/Git_Project/Snare_Lab_POC/ansible/images/windows_10_iso/windows_10.iso"
    "~/Git_Project/Snare_Lab_POC/ansible/images/ubuntu_22_iso/ubuntu-22.iso"
    "~/Git_Project/Snare_Lab_POC/ansible/images/snare_central_iso/vzdump-qemu-105-2024_07_25-19_42_45.vma.zst"
    "~/Git_Project/Snare_Lab_POC/ansible/images/snare_central_iso/vzdump-qemu-105-2024_07_25-19_42_45.vma.zst.notes"
    "~/Git_Project/Snare_Lab_POC/ansible/images/snare_central_iso/105.conf"
    "~/Git_Project/Snare_Lab_POC/ansible/images/virtio-win.iso"
    #"~/Git_Project/Snare_Lab_POC/ansible/images/scripts_withcloudinit.iso"
  )

  REMOTE_PATHS=(
    #"/var/lib/vz/template/iso/windows_server_2019.iso"
    #"/var/lib/vz/template/iso/windows_10.iso"
    "/var/lib/vz/template/iso/ubuntu-22.iso"
    "/var/lib/vz/dump/vzdump-qemu-105-2024_07_25-19_42_45.vma.zst"
    "/var/lib/vz/dump/vzdump-qemu-105-2024_07_25-19_42_45.vma.zst.notes"
    "/etc/pve/qemu-server/105.conf"
    "/var/lib/vz/template/iso/virtio-win.iso"
    #"/var/lib/vz/template/iso/scripts_withcloudinit.iso"

  )

  ssh_user="$PROXMOX_USER"

  for index in "${!LOCAL_FILES[@]}"; do
    LOCAL_FILE=${LOCAL_FILES[$index]}
    REMOTE_PATH=${REMOTE_PATHS[$index]}
    log "Checking if $REMOTE_PATH exists on Proxmox server..."

    sshpass -p "$PROXMOX_PASSWORD" ssh -o StrictHostKeyChecking=no "$ssh_user@$PROXMOX_NODE_IP" "test -f $REMOTE_PATH" >> $LOGFILE 2>&1

    if [ $? -eq 0 ]; then
      log "$REMOTE_PATH already exists. Skipping transfer."
      continue
    fi

    log "Transferring $LOCAL_FILE to $REMOTE_PATH on Proxmox server..."

    if [ ! -f ${LOCAL_FILE/#\~/$HOME} ]; then
      error_exit "Local file $LOCAL_FILE does not exist."
    fi

    log "Executing: sshpass -p \"$PROXMOX_PASSWORD\" scp -o StrictHostKeyChecking=no ${LOCAL_FILE/#\~/$HOME} $ssh_user@$PROXMOX_NODE_IP:$REMOTE_PATH"
    sshpass -p "$PROXMOX_PASSWORD" scp -o StrictHostKeyChecking=no ${LOCAL_FILE/#\~/$HOME} "$ssh_user@$PROXMOX_NODE_IP:$REMOTE_PATH" >> $LOGFILE 2>&1

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


 run_next_script() {
   log "AUTOMATICALLY RUNNING THE NEXT SCRIPT restore-sc.sh"
   cd ~/Git_Project/Snare_Lab_POC/Setup
   ./restore-sc.sh
 }

source_env
test_ssh_connection
transfer_files
run_next_script
