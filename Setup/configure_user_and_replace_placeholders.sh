#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

source_sshenv() {
  SSHENV_PATH=~/Git_Project/Snare_Lab_POC/SSHENV
  if [ -f $SSHENV_PATH ]; then
    log "Sourcing SSHENV file..."
    source $SSHENV_PATH
  else
    error_exit "SSHENV file not found at $SSHENV_PATH! Exiting..."
  fi
}

test_ssh_connection() {
  log "Testing SSH connection to Proxmox server..."
  sshpass -p "$PROXMOX_PASSWORD" ssh -o StrictHostKeyChecking=no $PROXMOX_USER@$PROXMOX_IP "echo 'SSH connection successful'" >> $LOGFILE 2>&1
  if [ $? -ne 0 ]; then
    error_exit "SSH connection to Proxmox server failed. Please check the credentials and network connectivity."
  fi
  log "SSH connection to Proxmox server successful."
}

configure_proxmox_users() {
  echo -e "\n\n####################### Starting Step 3 #######################\n" | tee -a $LOGFILE

  log "Configuring Proxmox users and roles..."

  log "Executing SSH commands on Proxmox server..."
  sshpass -p "$PROXMOX_PASSWORD" ssh -o StrictHostKeyChecking=no $PROXMOX_USER@$PROXMOX_IP << EOF >> $LOGFILE 2>&1
pveum role add provisioner -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Pool.Audit SDN.Use Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Console VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
pveum user add userprovisioner@pve
pveum aclmod / -user userprovisioner@pve -role provisioner
pveum user token add userprovisioner@pve provisioner-token --privsep=0
pveum aclmod /storage/local --user userprovisioner@pve --role PVEDatastoreAdmin --token userprovisioner@pve!provisioner-token
pveum user token list userprovisioner@pve provisioner-token --output-format=json
hostname
EOF

  if [ $? -ne 0 ]; then
    error_exit "Failed to execute SSH commands on Proxmox server."
  fi

  log "SSH command output logged to $LOGFILE"

  # Capture the API token value from the log file using regex
  API_TOKEN=$(grep -oP '│ value\s*│\s*\K[a-f0-9\-]{36}' $LOGFILE)

  if [ -z "$API_TOKEN" ]; then
    error_exit "Failed to capture API token."
  fi

  echo "Creating .env file..."
  echo "PROXMOX_API_ID=userprovisioner@pve!provisioner-token" > ~/Git_Project/Snare_Lab_POC/.env
  echo "PROXMOX_API_TOKEN=$API_TOKEN" >> ~/Git_Project/Snare_Lab_POC/.env
  echo "PROXMOX_NODE_IP=$PROXMOX_IP" >> ~/Git_Project/Snare_Lab_POC/.env
  echo "PROXMOX_NODE_NAME=$PROXMOX_NODE_NAME" >> ~/Git_Project/Snare_Lab_POC/.env
  echo "PROXMOX_USER=$PROXMOX_USER" >> ~/Git_Project/Snare_Lab_POC/.env
  echo "PROXMOX_PASSWORD=$PROXMOX_PASSWORD" >> ~/Git_Project/Snare_Lab_POC/.env
  log ".env file created successfully with the captured API token."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Proxmox users configured successfully.                  #
  #                                                            #
  ##############################################################
  \033[0m"
}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT replace_placeholders.sh"
  cd ~/Git_Project/Snare_Lab_POC/Setup
  ./replace_placeholders.sh
}

source_sshenv
test_ssh_connection
configure_proxmox_users
run_next_script
