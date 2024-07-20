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
  if [ -f ../proxmox_credentials.conf ]; then
    log "Sourcing proxmox_credentials.conf file..."
    source ../proxmox_credentials.conf
  else
    error_exit "proxmox_credentials.conf file not found! Exiting..."
  fi
}

configure_proxmox_users() {
  source_env

  log "Checking if Proxmox user already exists..."

  USER_EXISTS=$(ssh -o StrictHostKeyChecking=no $PROXMOX_USER@$PROXMOX_IP "pveum user list | grep -c 'userprovisioner@pve'")

  if [ "$USER_EXISTS" -eq "1" ]; then
    log "User already exists. Prompting for existing API token."
    PROXMOX_API_TOKEN=$(whiptail --inputbox "Enter existing API token:" 8 78 --title "Existing API Token" 3>&1 1>&2 2>&3)

    if [ ${#PROXMOX_API_TOKEN} -ne 36 ]; then
      error_exit "Invalid API token length. Expected 36 characters."
    fi

    echo "PROXMOX_API_ID=userprovisioner@pve!provisioner-token" > .env
    echo "PROXMOX_API_TOKEN=$PROXMOX_API_TOKEN" >> .env
    echo "PROXMOX_NODE_IP=$PROXMOX_IP" >> .env
    echo "PROXMOX_NODE_NAME=pve" >> .env
    log "API token saved to .env file."
  else
    log "Configuring Proxmox users and roles..."

    ssh -o StrictHostKeyChecking=no $PROXMOX_USER@$PROXMOX_IP << EOF > /tmp/proxmox_output.log 2>&1
pveum role add provisioner -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Pool.Audit SDN.Use Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Console VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
pveum user add userprovisioner@pve
pveum aclmod / -user userprovisioner@pve -role provisioner
pveum user token add userprovisioner@pve provisioner-token --privsep=0
pveum aclmod /storage/local --user userprovisioner@pve --role PVEDatastoreAdmin --token userprovisioner@pve!provisioner-token
pveum user token list userprovisioner@pve provisioner-token --output-format=json
hostname
EOF

    log "SSH command output:"
    cat /tmp/proxmox_output.log | tee -a $LOGFILE

    API_TOKEN=$(grep -Po '(?<=│ value │ )\S+(?=\s+│)' /tmp/proxmox_output.log)

    if [ -z "$API_TOKEN" ]; then
      error_exit "Failed to capture API token."
    fi

    echo "PROXMOX_API_ID=userprovisioner@pve!provisioner-token" > .env
    echo "PROXMOX_API_TOKEN=$API_TOKEN" >> .env
    echo "PROXMOX_NODE_IP=$PROXMOX_IP" >> .env
    echo "PROXMOX_NODE_NAME=pve" >> .env
    log "API token saved to .env file."
  fi
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
}

main() {
  configure_proxmox_users
  replace_placeholders

  whiptail --msgbox "Proxmox users configured and placeholders replaced successfully. Next, running ./install_automation_tools.sh" 8 78 --title "Step 3 Complete"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./install_automation_tools.sh                           #
  #                                                            #
  ##############################################################
  \033[0m"

  # Make the next script executable and run it
  chmod +x ./install_automation_tools.sh || error_exit "Failed to make install_automation_tools.sh executable."
  ./install_automation_tools.sh
}

main
