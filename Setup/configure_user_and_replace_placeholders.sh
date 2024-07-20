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

configure_proxmox_user() {
  log "Configuring Proxmox user and roles..."

  USER_EXISTS=$(ssh -o StrictHostKeyChecking=no $PROXMOX_USER@$PROXMOX_IP "pveum user list | grep -c 'userprovisioner@pve'")

  if [ "$USER_EXISTS" -eq 0 ]; then
    log "Creating Proxmox user and roles..."
    ssh $PROXMOX_USER@$PROXMOX_IP << EOF
pveum role add provisioner -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Pool.Audit SDN.Use Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Console VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
pveum user add userprovisioner@pve
pveum aclmod / -user userprovisioner@pve -role provisioner
pveum user token add userprovisioner@pve provisioner-token --privsep=0
EOF
  fi

  TOKEN=$(ssh $PROXMOX_USER@$PROXMOX_IP "pveum user token list userprovisioner@pve provisioner-token --output-format=json" | jq -r '.[].value')

  log "Proxmox API token captured: $TOKEN"

  cat <<EOL >> proxmox_credentials.conf
PROXMOX_API_ID=userprovisioner@pve!provisioner-token
PROXMOX_API_TOKEN=$TOKEN
EOL

  log "Proxmox API token saved."
}

replace_placeholders() {
  log "Replacing placeholders in configuration files..."
  source proxmox_credentials.conf

  find . -type f ! -name "requirements.sh" -exec sed -i \
    -e "s/<proxmox_api_id>/$PROXMOX_API_ID/g" \
    -e "s/<proxmox_api_token>/$PROXMOX_API_TOKEN/g" \
    -e "s/<proxmox_node_ip>/$PROXMOX_IP/g" \
    -e "s/<proxmox_node_name>/pve/g" {} +

  log "Placeholders in configuration files replaced successfully."
}

main() {
  source_proxmox_credentials
  configure_proxmox_user
  replace_placeholders

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./install_automation_tools.sh                           #
  #                                                            #
  ##############################################################
  \033[0m"
}

main
