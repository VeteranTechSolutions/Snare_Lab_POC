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

install_ansible() {
  log "Installing Ansible..."
  UBUNTU_CODENAME=$(lsb_release -cs)
  wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmor --yes -o /usr/share/keyrings/ansible-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
  sudo apt update && sudo apt install -y ansible || error_exit "Failed to install Ansible."
  log "Ansible installed successfully."
}

install_packer_terraform() {
  log "Installing Packer and Terraform..."
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y packer terraform || error_exit "Failed to install Packer and Terraform."
  log "Packer and Terraform installed successfully."
}

install_ansible_collections() {
  log "Installing Ansible collections and required Python packages..."
  pip3 install ansible pywinrm jmespath || error_exit "Failed to install Python packages."
  ansible-galaxy collection install community.windows community.general microsoft.ad || error_exit "Failed to install Ansible collections."
  log "Ansible collections and required Python packages installed successfully."
}

main() {
  install_ansible
  install_packer_terraform
  install_ansible_collections

  whiptail --msgbox "Ansible, Packer, and Terraform installed successfully. Next, running ./download_lab_ISO_and_snare_products.sh" 8 78 --title "Step 4 Complete"

  echo -e "\033[1;34m
  ##############################################################
  #                                                            #
  #    NEXT STEP: Running the following command:               #
  #                                                            #
  #    ./download_lab_ISO_and_snare_products.sh                #
  #                                                            #
  ##############################################################
  \033[0m"

  # Make the next script executable and run it
  chmod +x ./download_lab_ISO_and_snare_products.sh || error_exit "Failed to make download_lab_ISO_and_snare_products.sh executable."
  ./download_lab_ISO_and_snare_products.sh
}

main
