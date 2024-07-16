#!/bin/bash

LOGFILE=setup.log

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

error_exit() {
  log "ERROR: $1"
  exit 1
}

update_system_and_install_dependencies() {
  log "Updating and upgrading the system, and installing required packages..."
  sudo apt update && sudo apt upgrade -y || error_exit "System update and upgrade failed."
  sudo apt install -y git gpg nano tmux curl gnupg software-properties-common mkisofs python3-venv python3 python3-pip unzip mono-complete || error_exit "Failed to install required packages."
  log "System update and installation of dependencies completed."
  log "Next, run the script again and choose 'Create Python Virtual Environment'."
}

create_venv() {
  log "Creating and activating Python virtual environment..."
  sudo apt install -y python3-venv || error_exit "Failed to install python3-venv."
  python3 -m venv venv || error_exit "Failed to create Python virtual environment."
  echo "source $(pwd)/venv/bin/activate" >> ~/.bashrc
  source $(pwd)/venv/bin/activate || error_exit "Failed to activate Python virtual environment."
  log "Python virtual environment created and activated successfully."
  log "Exiting script after creating virtual environment."
  log "Next, run 'source venv/bin/activate' and then run the script again and choose 'Configure Proxmox Users'."
  exit 0
}

source_env() {
  if [ -f .env ]; then
    log "Sourcing .env file..."
    export $(grep -v '^#' .env | xargs)
  else
    error_exit ".env file not found! Exiting..."
  fi
}

configure_proxmox_users() {
  log "Configuring Proxmox users and roles..."
  read -p "Enter Proxmox User IP: " PROXMOX_USER_IP
  read -p "Enter Proxmox User Username: " PROXMOX_USER
  read -s PROXMOX_PASS

  log "Executing SSH commands on Proxmox server..."
  ssh $PROXMOX_USER@$PROXMOX_USER_IP << EOF > /tmp/proxmox_output.log 2>&1
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
  
  echo "Please copy the API token from the output above."
  read -p "Have you copied the API token? Type 'yes' to continue: " confirmation
  if [ "$confirmation" == "yes" ]; then
    echo "Creating .env file..."
    echo "PROXMOX_API_ID=userprovisioner@pve!provisioner-token" > .env
    echo "PROXMOX_API_TOKEN=" >> .env
    echo "PROXMOX_NODE_IP=$PROXMOX_USER_IP" >> .env
    echo "PROXMOX_NODE_NAME=pve" >> .env
    log ".env file created successfully. Please paste the copied API token in the PROXMOX_API_TOKEN field."
    nano .env
  else
    error_exit "API token not copied. Exiting..."
  fi

  log "Next, run the script again and choose 'Replace Placeholders in Configuration Files'."
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
  log "Next, run the script again and choose 'Install Ansible'."
}

install_ansible() {
  log "Installing Ansible..."
  UBUNTU_CODENAME=$(lsb_release -cs)
  wget -O- "https://keyserver.ubuntu.com/pks/lookup?fingerprint=on&op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" | sudo gpg --dearmor --yes -o /usr/share/keyrings/ansible-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/ansible-archive-keyring.gpg] http://ppa.launchpad.net/ansible/ansible/ubuntu $UBUNTU_CODENAME main" | sudo tee /etc/apt/sources.list.d/ansible.list
  sudo apt update && sudo apt install -y ansible || error_exit "Failed to install Ansible."
  log "Ansible installed successfully."
  log "Next, run the script again and choose 'Install Packer and Terraform'."
}

install_packer_terraform() {
  log "Installing Packer and Terraform..."
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install -y packer terraform || error_exit "Failed to install Packer and Terraform."
  log "Packer and Terraform installed successfully."
  log "Next, run the script again and choose 'Download ISO Files to Proxmox'."
}

download_iso() {
  local url=$1
  local filename=$2
  ssh $PROXMOX_USER@$PROXMOX_NODE_IP "cd /var/lib/vz/template/iso/ && nohup wget -O $filename $url &"
  if [ $? -eq 0 ]; then
    log "$filename download initiated."
  else
    error_exit "Failed to initiate $filename download."
  fi
}

download_all_iso_files_proxmox() {
  log "Downloading all ISO files on Proxmox server. This may take a while..."
  source_env
  read -p "Enter Proxmox User Username: " PROXMOX_USER
  read -sp "Enter Proxmox User Password: " PROXMOX_PASS
  echo

  log "Executing SSH commands on Proxmox server..."
  ssh $PROXMOX_USER@$PROXMOX_NODE_IP << EOF
cd /var/lib/vz/template/iso/ || exit 1
nohup wget -O virtio-win.iso https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso &
nohup wget -O windows10.iso https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso &
nohup wget -O windows_server_2019.iso https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso &
nohup wget -O ubuntu-22.iso https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso &
EOF
  if [ $? -eq 0 ]; then
    log "ISO files download initiated."
  else
    error_exit "Failed to initiate ISO files download."
  fi
}

download_iso_files_proxmox_menu() {
  echo "ISO Download Menu:"
  echo "1) Download all ISO files"
  echo "2) Download Virtio ISO"
  echo "3) Download Windows 10 ISO"
  echo "4) Download Windows Server 2019 ISO"
  echo "5) Download Ubuntu 22.04 ISO"
  echo "6) Back to main menu"
  read -p "Enter choice [1-6]: " iso_choice
  case $iso_choice in
    1) download_all_iso_files_proxmox ;;
    2) download_iso "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso" "virtio-win.iso" ;;
    3) download_iso "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso" "windows10.iso" ;;
    4) download_iso "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66749/17763.3650.221105-1748.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso" "windows_server_2019.iso" ;;
    5) download_iso "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso" "ubuntu-22.iso" ;;
    6) log "Returning to main menu..." ;;
    *) log "Invalid option. Please select a valid choice." ;;
  esac
}

download_snare_files() {
  local download_dir=~/ad-training-lab/ansible/playbooks/Snare-Products
  mkdir -p $download_dir

  # Function to download the first file
  download_file_1() {
    curl -L -o $download_dir/Snare-Windows-Agent-v5.8.1-x64.exe "https://github.com/hanshoyos/ad-training-lab/releases/download/snare-products/Snare-Windows-Agent-v5.8.1-x64.exe"
  }

  # Function to download the second file
  download_file_2() {
    curl -L -o $download_dir/Snare-Windows-Agent-\(Desktop-Only\)-v5.8.1-x64.exe "https://github.com/hanshoyos/ad-training-lab/releases/download/snare-products/Snare-Windows-Agent-.Desktop-Only.-v5.8.1-x64.exe"
  }

  # Function to download the third file
  download_file_3() {
    curl -L -o $download_dir/Snare-Windows-Agent-WEC-v5.8.1-x64.exe "https://github.com/hanshoyos/ad-training-lab/releases/download/snare-products/Snare-Windows-Agent-WEC-v5.8.1-x64.exe"
  }

  # Function to download the fourth file
  download_file_4() {
    curl -L -o $download_dir/Snare-Epilog-Agent-v5.8.1-x64.exe "https://github.com/hanshoyos/ad-training-lab/releases/download/snare-products/Snare-Epilog-Agent-v5.8.1-x64.exe"
  }

  # Function to download the fifth file
  download_file_5() {
    curl -L -o $download_dir/Snare-MSSQL-Agent-v5.8.1-x64.exe "https://github.com/hanshoyos/ad-training-lab/releases/download/snare-products/Snare-MSSQL-Agent-v5.8.1-x64.exe"
  }

  # Function to download the sixth file
  download_file_6() {
    curl -L -o $download_dir/MSIBuilder.exe "https://github.com/hanshoyos/ad-training-lab/releases/download/snare-products/MSIBuilder.exe"
  }

  # Function to download the seventh file
  download_file_7() {
    curl -L -o $download_dir/Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb "https://github.com/hanshoyos/ad-training-lab/releases/download/snare-products/Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb"
  }

  # Function to download the eighth file
  download_file_8() {
    curl -L -o $download_dir/SnareAM-v2.0.1-x64.msi "https://github.com/hanshoyos/ad-training-lab/releases/download/snare-products/SnareAM-v2.0.1-x64.msi"
  }

  # Function to download the eighth file
  download_file_9() {
    curl -L -o $download_dir/SnareReflector-Windows-x64-v2.5.1.msi "https://github.com/hanshoyos/ad-training-lab/releases/download/snare-products/SnareReflector-Windows-x64-v2.5.1.msi"
  }

  # Prompt user for which files to download
  echo "Which files would you like to download?"
  echo "1) Snare-Windows-Agent-v5.8.1-x64.exe"
  echo "2) Snare-Windows-Agent-\(Desktop-Only\)-v5.8.1-x64.exe"
  echo "3) Snare-Windows-Agent-WEC-v5.8.1-x64.exe"
  echo "4) Snare-Epilog-Agent-v5.8.1-x64.exe"
  echo "5) Snare-MSSQL-Agent-v5.8.1-x64.exe"
  echo "6) MSIBuilder.exe"
  echo "7) Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb"
  echo "8) SnareAM-v2.0.1-x64.msi"
  echo "9) SnareReflector-Windows-x64-v2.5.1.msi"
  echo "10) All files"
  read -p "Enter your choice (1/2/3/4/5/6/7/8/9/10): " choice

  # Download the selected files
  case $choice in
    1)
      echo "Downloading Snare-Windows-Agent-v5.8.1-x64.exe..."
      download_file_1
      ;;
    2)
      echo "Downloading Snare-Windows-Agent-(Desktop-Only)-v5.8.1-x64.exe..."
      download_file_2
      ;;
    3)
      echo "Downloading Snare-Windows-Agent-WEC-v5.8.1-x64.exe..."
      download_file_3
      ;;
    4)
      echo "Downloading Snare-Epilog-Agent-v5.8.1-x64.exe..."
      download_file_4
      ;;
    5)
      echo "Downloading Snare-MSSQL-Agent-v5.8.1-x64.exe..."
      download_file_5
      ;;
    6)
      echo "Downloading MSIBuilder.exe..."
      download_file_6
      ;;
    7)
      echo "Downloading Snare-Ubuntu-22-Agent-v5.8.1-1-x64.deb..."
      download_file_7
      ;;
    8)
      echo "Downloading SnareAM-v2.0.1-x64.msi..."
      download_file_8
      ;;
    9)
      echo "Downloading SnareReflector-Windows-x64-v2.5.1.msi..."
      download_file_9
      ;;
    10)
      echo "Downloading all files..."
      download_file_1
      download_file_2
      download_file_3
      download_file_4
      download_file_5
      download_file_6
      download_file_7
      download_file_8
      download_file_9
      ;;
    *)
      echo "Invalid choice. Please run the script again and select a valid option."
      ;;
  esac

  echo "Download(s) completed."
}

install_ansible_collections() {
  log "Installing Ansible collections and required Python packages..."
  pip3 install ansible pywinrm jmespath || error_exit "Failed to install Python packages."
  ansible-galaxy collection install community.windows microsoft.ad || error_exit "Failed to install Ansible collections."
  log "Ansible collections and required Python packages installed successfully."
}

main_menu() {
  echo "Main Menu:"
  echo "1) Update System and Install Dependencies"
  echo "2) Create Python Virtual Environment"
  echo "3) Configure Proxmox Users"
  echo "4) Replace Placeholders in Configuration Files"
  echo "5) Install Ansible"
  echo "6) Install Packer and Terraform"
  echo "7) Download ISO Files to Proxmox"
  echo "8) Download Snare Files"
  echo "9) Install Ansible Collections and Python Packages"
  echo "10) Exit"
  read -p "Enter choice [1-10]: " main_choice
  case $main_choice in
    1) update_system_and_install_dependencies ;;
    2) create_venv ;;
    3) configure_proxmox_users ;;
    4) replace_placeholders ;;
    5) install_ansible ;;
    6) install_packer_terraform ;;
    7) download_iso_files_proxmox_menu ;;
    8) download_snare_files ;;
    9) install_ansible_collections ;;
    10) log "Exiting script. Goodbye!" ; exit 0 ;;
    *) log "Invalid option. Please select a valid choice." ;;
  esac
}

while true; do
  main_menu
done
