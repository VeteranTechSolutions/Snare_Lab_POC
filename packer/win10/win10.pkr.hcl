packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
    windows-update = {
       version = "0.16.7"
       source  = "github.com/rgl/windows-update"
    }
  }
}

source "proxmox-iso" "traininglab-ws" {
  proxmox_url  = "https://${var.proxmox_node}:8006/api2/json"
  node         = var.proxmox_hostname
  username     = var.proxmox_api_id
  token        = var.proxmox_api_token
  
  #iso_file     = "local:iso/windows_10.iso" #-- uncomment if you want to use local iso file and comment the next four lines
  iso_checksum             = "sha256:ef7312733a9f5d7d51cfa04ac497671995674ca5e1058d5164d6028f0938d668"
  iso_url                  = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
  iso_storage_pool         = "local"
  iso_download_pve = true

  communicator             = "ssh"
  ssh_username             = var.lab_username
  ssh_password             = var.lab_password
  ssh_timeout              = "60m"
  qemu_agent               = true
  cores                    = 6
  cpu_type                  = "host"
  memory                   = 8192
  vm_name                  = "traininglab-ws"
  tags                     = "traininglab-ws"
  template_description     = "TrainingLab Workstation Template"
  insecure_skip_tls_verify = true
  unmount_iso = true
  task_timeout = "60m"

   additional_iso_files {
    device           = "ide0"
    unmount          = true
    iso_storage_pool = "local"
    cd_label         = "PROVISION"
    cd_files = [
      "../drivers/NetKVM/w10/amd64/*.cat",
      "../drivers/NetKVM/w10/amd64/*.inf",
      "../drivers/NetKVM/w10/amd64/*.sys",
      "../drivers/qxldod/w10/amd64/*.cat",
      "../drivers/qxldod/w10/amd64/*.inf",
      "../drivers/qxldod/w10/amd64/*.sys",
      "../drivers/vioscsi/w10/amd64/*.cat",
      "../drivers/vioscsi/w10/amd64/*.inf",
      "../drivers/vioscsi/w10/amd64/*.sys",
      "../drivers/vioserial/w10/amd64/*.cat",
      "../drivers/vioserial/w10/amd64/*.inf",
      "../drivers/vioserial/w10/amd64/*.sys",
      "../drivers/viostor/w10/amd64/*.cat",
      "../drivers/viostor/w10/amd64/*.inf",
      "../drivers/viostor/w10/amd64/*.sys",
      "../drivers/spice-guest-tools.exe",
      "../drivers/virtio-win-guest-tools.exe",
      "../scripts/provision-autounattend.ps1",
      "../scripts/provision-guest-tools-qemu-kvm.ps1",
      "../scripts/provision-openssh.ps1",
      "../scripts/provision-psremoting.ps1",
      "../scripts/provision-pwsh.ps1",
      "../scripts/provision-winrm.ps1",
      "../scripts/disable-windows-updates.ps1",
      "../scripts/remove-one-drive.ps1",
      "../scripts/remove-apps.ps1",
      "../scripts/disable-windows-defender.ps1",
      "../scripts/enable-remote-desktop.ps1",
      "../scripts/provision-cloudbase-init.ps1",
      #"../scripts/debloat-windows.ps1",
      "../scripts/optimize.ps1",
      "../scripts/Windows10SysPrepDebloater.ps1",
      "../scripts/eject-media.ps1",
      "autounattend.xml",
    ]
  }

  network_adapters {
    bridge = var.netbridge
  }

  disks {
    type              = "scsi"
    disk_size         = "50G"
    storage_pool = var.storage_name
    discard = true
    io_thread = true
  }

  scsi_controller = "virtio-scsi-single"
}

build {
  sources = ["sources.proxmox-iso.traininglab-ws"]
  
  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/enable-remote-desktop.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/disable-windows-updates.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/disable-windows-defender.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/remove-one-drive.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/remove-apps.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/provision-guest-tools-qemu-kvm.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/provision.ps1"
  }

  #provisioner "windows-update" {
  #  search_criteria = "AutoSelectOnWebSites=1 and IsInstalled=0"
  #  update_limit = 25
  #}

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/provision-cloudbase-init.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/eject-media.ps1"
  }
  
  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/Windows10SysPrepDebloater.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/optimize.ps1"
  }

  provisioner "windows-restart" {
  }

}
