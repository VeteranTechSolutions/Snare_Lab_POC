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
    log "Sourcing Proxmox credentials..."
    source ../proxmox_credentials.conf
  else
    error_exit "Proxmox credentials not found! Exiting..."
  fi
}

validate_token() {
  local token=$1
  if [[ ${#token} -eq 36 ]]; then
    return 0
  else
    return 1
  fi
}

configure_proxmox_users() {
  echo -e "\n\n####################### Starting Step 3 #######################\n" | tee -a $LOGFILE

  log "Configuring Proxmox users and roles..."

  source_env

  EXISTING_USER=$(ssh $PROXMOX_USER@$PROXMOX_IP "pveum user list | grep -w 'userprovisioner@pve'")

  if [ -z "$EXISTING_USER" ]; then
    log "User does not exist. Creating user and roles..."

    ssh $PROXMOX_USER@$PROXMOX_IP << EOF
pveum role add provisioner -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Pool.Audit SDN.Use Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Console VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
pveum user add userprovisioner@pve
pveum aclmod / -user userprovisioner@pve -role provisioner
pveum user token add userprovisioner@pve provisioner-token --privsep=0
pveum aclmod /storage/local --user userprovisioner@pve --role PVEDatastoreAdmin --token userprovisioner@pve!provisioner-token
pveum user token list userprovisioner@pve provisioner-token --output-format=json
hostname
EOF

    TOKEN=$(ssh $PROXMOX_USER@$PROXMOX_IP "pveum user token list userprovisioner@pve provisioner-token --output-format=json | jq -r '.[0].value'")

    if validate_token "$TOKEN"; then
      log "Token generated and validated."
    else
      error_exit "Invalid token generated."
    fi

  else
    log "User already exists. Prompting for token..."

    TOKEN=$(whiptail --inputbox "Enter the existing token for userprovisioner@pve:" 8 78 --title "Proxmox Token" 3>&1 1>&2 2>&3)

    if validate_token "$TOKEN"; then
      log "Token validated."
    else
      error_exit "Invalid token entered."
    fi
  fi

  echo "PROXMOX_API_ID=userprovisioner@pve!provisioner-token" > ../proxmox_token.conf
  echo "PROXMOX_API_TOKEN=$TOKEN" >> ../proxmox_token.conf

  whiptail --msgbox "Proxmox users and roles configured successfully. Next, running ./replace_placeholders.sh" 8 78 --title "Step 3 Complete"

  log "Proxmox users and roles configured successfully."

  log "Making the next script (replace_placeholders.sh) executable..."
  chmod +x ../replace_placeholders.sh || error_exit "Failed to make replace_placeholders.sh executable."
  log "Next script (replace_placeholders.sh) is now executable."

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./replace_placeholders.sh                               #
  #                                                            #
  ##############################################################
  \033[0m"

  # Run the next script
  ../replace_placeholders.sh
}

main() {
  configure_proxmox_users
}

main
