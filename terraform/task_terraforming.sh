#!/bin/bash

LOGFILE=~/Git_Project/Snare_Lab_POC/setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

working_directory=~/Git_Project/Snare_Lab_POC/terraform

run_terraform() {

log "Change to Present Working Directory to $worworking_directory"
cd $worworking_directory


  echo -e "\n\n####################### Starting Terraform Apply #######################\n" | tee -a $LOGFILE

  log "Initializing Terraform..."
  terraform init >> $LOGFILE 2>&1 || error_exit "Terraform init failed."

  log "Applying Terraform configuration..."
  terraform apply -auto-approve >> $LOGFILE 2>&1 || error_exit "Terraform apply failed."

  log "Extracting Ansible inventory..."
  terraform output -raw ansible_inventory > ../ansible/inventory/hosts.yml || error_exit "Failed to extract Ansible inventory."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Terraform applied successfully.                         #
  #                                                            #
  #    Ansible inventory created: ../ansible/inventory/hosts.yml #
  #                                                            #
  #    Next step: run the Ansible playbook inside the ansible folder! #
  #                                                            #
  #    Command: ansible-playbook ad_setup.yml                  #
  #                                                            #
  ##############################################################
  \033[0m"
}

run_terraform
