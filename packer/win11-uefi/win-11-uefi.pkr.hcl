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

source "proxmox-iso" "traininglab-win11-uefi" {
  proxmox_url              = "https://${var.proxmox_node}:8006/api2/json"
  node                     = var.proxmox_hostname
  username                 = var.proxmox_api_id
  token                    = var.proxmox_api_token
  
  iso_checksum             = "sha256:c8dbc96b61d04c8b01faf6ce0794fdf33965c7b350eaa3eb1e6697019902945c"
  iso_url                  = ""https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
  iso_storage_pool         = "local"
  #iso_download_pve = true
  
  
  #http_directory = "."
  #boot_wait      = "30s"

  communicator             = "ssh"
  ssh_username             = var.lab_username
  ssh_password             = var.lab_password
  ssh_timeout              = "60m"
  qemu_agent               = true
  cores                    = 4
  cpu_type                 = "host"
  memory                   = 8192
  vm_name                  = "traininglab-win11-uefi"
  tags                     = "traininglab-win11-uefi"
  template_description     = "See https://github.com/rgl/windows-vagrant"
  insecure_skip_tls_verify = true
  unmount_iso              = true
  task_timeout             = "60m" 
  machine                  = "q35"
  os                       = "win11"
  

  vga {
    type   = "qxl"
    memory = 32
  }

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  scsi_controller = "virtio-scsi-single"

  disks {
    type              = "scsi"
    disk_size         = "50G"
    storage_pool      = var.storage_name
    discard           = true
    io_thread         = true
  }

  additional_iso_files {
    device           = "ide0"
    unmount          = true
    iso_storage_pool = "local"
    cd_label         = "PROVISION"
    cd_files = [
      "../drivers/smbus/w11/*",
      "../drivers/pvpanic/w11/*",
      "../drivers/qemufwcfg/w11/*",
      "../drivers/qemuserial/w11/*",
      "../drivers/qxl/w11/*",
      "../drivers/amd64/w11/*",
      "../drivers/Balloon/w11/*",
      "../drivers/fwcfg/w11/*",
      "../drivers/NetKVM/w11/amd64/*",
      "../drivers/qxldod/w11/amd64/*",
      "../drivers/viofs/w11/amd64/*",
      "../drivers/sriov/w11/amd64/*",
      "../drivers/vioscsi/w11/amd64/*",
      "../drivers/vioserial/w11/amd64/*",
      "../drivers/viostor/w11/amd64/*",
      "../drivers/viogpudo/w11/*",
      "../drivers/vioinput/w11/*",
      "../drivers/viorng/w11/*",
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
      "../scripts/optimize.ps1",
      "../scripts/Windows10SysPrepDebloater.ps1",
      "../scripts/eject-media.ps1",
      "autounattend.xml",
    ]
  }

build {
  sources = ["source.proxmox-iso.traininglab-win11-uefi"]

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
    restart_timeout = "15m" # Increase this if needed
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
    restart_timeout = "15m" # Increase this if needed
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/optimize.ps1"
  }

  provisioner "windows-restart" {
  }

}
