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
    source $ENV_PATH
  else
    error_exit ".env file not found at $ENV_PATH! Exiting..."
  fi
}

replace_placeholders() {
  source_env

  log "Replacing placeholders in configuration files..."

  cd ~/Git_Project/Snare_Lab_POC

  find . -type f ! -name "requirements.sh" -exec sed -i \
      -e "s/userprovisioner@pve!provisioner-token/$PROXMOX_API_ID/g" \
      -e "s/2c57c09e-2694-495f-a030-4a4f83b902d6/$PROXMOX_API_TOKEN/g" \
      -e "s/192.168.10.21/$PROXMOX_NODE_IP/g" \
      -e "s/BackUp/$PROXMOX_NODE_NAME/g" {} +

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
  #                     STEP 3 COMPLETE                        #
  #                                                            #
  ##############################################################
  \033[0m"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Run the following command:                   #
  #                                                            #
  #    ./install_automation_tools.sh                           #
  #                                                            #
  ##############################################################
  \033[0m"
}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT install_automation_tools.sh"
  cd ~/Git_Project/Snare_Lab_POC/Setup
  ./install_automation_tools.sh
}

replace_placeholders
run_next_script
