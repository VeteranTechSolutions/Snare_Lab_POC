#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

install_ansible() {
  echo -e "\n\n####################### Starting Step 4 #######################\n" | tee -a $LOGFILE

  log "Installing Ansible..."

  UBUNTU_CODENAME=$(lsb_release -cs)
  log "Detected Ubuntu codename: $UBUNTU_CODENAME"

  log "Adding Ansible PPA and installing Ansible..."
  sudo apt-add-repository --yes --update ppa:ansible/ansible || error_exit "Failed to add Ansible PPA."
  sudo apt update || error_exit "Failed to update package list."
  sudo apt install -y ansible || error_exit "Failed to install Ansible."

  log "Ansible installed successfully."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Ansible installed successfully.                         #
  #                                                            #
  ##############################################################
  \033[0m"
}

install_packer_and_terraform() {
  echo -e "\n\n####################### Continuing Step 4 #######################\n" | tee -a $LOGFILE

  log "Installing Packer and Terraform..."

  log "Adding HashiCorp GPG key and repository..."
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null || error_exit "Failed to add HashiCorp GPG key."
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list || error_exit "Failed to add HashiCorp repository."

  log "Updating package list..."
  sudo apt update || error_exit "Failed to update package list."

  log "Installing Packer..."
  sudo apt install -y packer || error_exit "Failed to install Packer."

  log "Installing Terraform..."
  sudo apt install -y terraform || error_exit "Failed to install Terraform."

  log "Packer and Terraform installed successfully."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Packer and Terraform installed successfully.            #
  #                                                            #
  ##############################################################
  \033[0m"
}

install_ansible_collections() {
  echo -e "\n\n####################### Completing Step 4 #######################\n" | tee -a $LOGFILE

  log "Installing Ansible collections and required Python packages..."

  log "Installing required Python packages: ansible, pywinrm, jmespath..."
  pip3 install ansible pywinrm jmespath || error_exit "Failed to install Python packages."

  log "Installing Ansible collections: community.windows, community.general, microsoft.ad..."
  ansible-galaxy collection install community.windows community.general microsoft.ad || error_exit "Failed to install Ansible collections."

  log "Ansible collections and required Python packages installed successfully."

  echo -e "\033[1;32m
  ##############################################################
  #                                                            #
  #    Ansible collections and Python packages installed       #
  #    successfully.                                           #
  #                                                            #
  #                     STEP 4 COMPLETE                        #
  #                                                            #
  ##############################################################
  \033[0m"

   echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Run the following command:                   #
  #                                                            #
  #    ./download_lab_ISO_and_snare_products.sh                #
  #                                                            #
  ##############################################################
  \033[0m"
}

run_next_script() {
  log "AUTOMATICALLY RUNNING THE NEXT SCRIPT download_iso_files.sh"
  cd ~/Git_Project/Snare_Lab_POC/Setup
  ./download_iso_files.sh
}


install_ansible
install_packer_and_terraform
install_ansible_collections
run_next_script



