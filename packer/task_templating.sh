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

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT task_terraforming.sh"
  cd ~/Git_Project/Snare_Lab_POC/terraform || error_exit "Failed to change directory to ~/Git_Project/Snare_Lab_POC/terraform"
  ./task_terraforming.sh
}

source_env
create_templates
run_next_script
