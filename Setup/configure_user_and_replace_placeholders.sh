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
  if [ -f .env ]; then
    log "Sourcing .env file..."
    export $(grep -v '^#' .env | xargs)
  else
    error_exit ".env file not found! Exiting..."
  fi
}

configure_proxmox_users() {
  log "Configuring Proxmox users and roles..."

  read -p "Enter Proxmox User IP: " PROXMOX_USER_IP
  read -p "Enter Proxmox User Username: " PROXMOX_USER
  read -sp "Enter Proxmox User Password: " PROXMOX_PASS
  echo

  log "Executing SSH commands on Proxmox server..."
  ssh $PROXMOX_USER@$PROXMOX_USER_IP << EOF >> $LOGFILE 2>&1
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
  echo "PROXMOX_API_ID=userprovisioner@pve!provisioner-token" > .env
  echo "PROXMOX_API_TOKEN=$API_TOKEN" >> .env
  echo "PROXMOX_NODE_IP=$PROXMOX_USER_IP" >> .env
  echo "PROXMOX_NODE_NAME=pve" >> .env
  log ".env file created successfully with the captured API token."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Proxmox users configured successfully.                  #
  #                                                            #
  #    Replacing placeholders in configuration files...        #
  #                                                            #
  ##############################################################
  \033[0m"
}

replace_placeholders() {
  source_env

  log "Replacing placeholders in configuration files..."
  find . -type f ! -name "requirements.sh" -exec sed -i \
    -e "s/<proxmox_api_id>/$PROXMOX_API_ID/g" \
    -e "s/<proxmox_api_token>/$PROXMOX_API_TOKEN/g" \
    -e "s/<proxmox_node_ip>/$PROXMOX_NODE_IP/g" \
    -e "s/<proxmox_node_name>/$PROXMOX_NODE_NAME/g" {} +

  find ./packer -type f -name "example.auto.pkrvars.hcl.txt" -exec bash -c \
    'mv "$0" "${0/example.auto.pkrvars.hcl.txt/value.auto.pkrvars.hcl}"' {} \;

  find ./terraform -type f -name "example-terraform.tfvars.txt" -exec bash -c \
    'mv "$0" "${0/example-terraform.tfvars.txt/terraform.tfvars}"' {} \;

  log "Placeholders in configuration files replaced successfully."
  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Placeholders replaced successfully.                     #
  #                                                            #
  #    Run the next step: install_ansible.sh                   #
  #                                                            #
  ##############################################################
  \033[0m"
}

configure_proxmox_users
replace_placeholders