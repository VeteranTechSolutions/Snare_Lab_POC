#!/bin/bash

LOGFILE=~/Git_Project/Snare_Lab_POC/setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

source_env_POC() {
  ENV_PATH=~/Git_Project/Snare_Lab_POC/.env
  if [ -f $ENV_PATH ]; then
    log "Sourcing .env file..."
    source $ENV_PATH
  else
    error_exit ".env file not found at $ENV_PATH! Exiting..."
  fi
}

create_templates(){

    for directory in $(ls -d */); do
        cd $directory
        packer init .
        echo "[+] building template in: $(pwd)"
        packer build .
        cd ..
    done;

  log "Packer task templating completed successfully in all directories."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Templates created successfully in all directories.      #
  #                                                            #
  #    Next step: terraform apply                              #
  #                                                            #
  ##############################################################
  \033[0m"
}

source_env_vagrant() {
  ENV_PATH=~/Git_Project/windows-vagrant/secrets-proxmox.sh
  if [ -f $ENV_PATH ]; then
    log "Sourcing secrets-proxmox.sh file..."
    source $ENV_PATH
  else
    error_exit "secrets-proxmox.sh file not found at $ENV_PATH! Exiting..."
  fi
}

build_win11(){

make build-windows-11-23h2-uefi-proxmox

}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT task_terraforming.sh"
  cd ~/Git_Project/Snare_Lab_POC/terraform || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/terraform"
  ./task_terraforming.sh
}

source_env_POC
create_templates
source_env_vagrant
build_win11
run_next_script
