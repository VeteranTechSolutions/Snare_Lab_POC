#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

install_ansible() {
  log "Installing Ansible..."
  sudo apt update
  sudo apt install -y ansible
  log "Ansible installed successfully."
}

install_packer_terraform() {
  log "Installing Packer and Terraform..."
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update
  sudo apt install -y packer terraform
  log "Packer and Terraform installed successfully."
}

install_ansible_collections() {
  log "Installing Ansible collections and required Python packages..."
  pip3 install ansible pywinrm jmespath
  ansible-galaxy collection install community.windows community.general microsoft.ad
  log "Ansible collections and required Python packages installed successfully."
}

main() {
  install_ansible
  install_packer_terraform
  install_ansible_collections

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./download_lab_ISO_and_snare_products.sh                #
  #                                                            #
  ##############################################################
  \033[0m"

  # Make the next script executable
  chmod +x ./download_lab_ISO_and_snare_products.sh
}

main
