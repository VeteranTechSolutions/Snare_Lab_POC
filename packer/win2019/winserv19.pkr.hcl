packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
    windows-update = {
      version = "0.16.7"
      source = "github.com/rgl/windows-update"
    }
  }
}

source "proxmox-iso" "traininglab-win2019" {
  proxmox_url  = "https://${var.proxmox_node}:8006/api2/json"
  node         = var.proxmox_hostname
  username     = var.proxmox_api_id
  token        = var.proxmox_api_token
  
  #iso_file     = "local:iso/windpws_server_2019.iso" #-- uncomment if you want to use local iso file and comment the next four lines
  iso_checksum             = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"
  iso_url                  = "https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
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
  vm_name                  = "traininglab-win2019"
  tags                     = "traininglab-win2019"
  template_description     = "TrainingLab WindowsServer Template - Sysprep done"
  insecure_skip_tls_verify = true
  unmount_iso = true
  task_timeout = "60m"

  additional_iso_files {
    device           = "ide0"
    unmount          = true
    iso_storage_pool = "local"
    cd_label         = "PROVISION"
    cd_files = [
      "../drivers/amd64/*",
      "../drivers/Balloon/*",
      "../drivers/cert/*",
      "../drivers/data/*",
      "../drivers/fwcfg/*",
      "../drivers/guest-agent/*",
      "../drivers/i386/*",
      "../drivers/NetKVM/*",
      "../drivers/pvpanic/*",
      "../drivers/qemufwcfg/*",
      "../drivers/qemupciserial/*",
      "../drivers/qxl/*",
      "../drivers/qxldod/*",
      "../drivers/smbus/*",
      "../drivers/sriov/*",
      "../drivers/viofs/*",
      "../drivers/viogpudo/*",
      "../drivers/vioinput/*",
      "../drivers/viorng/*",
      "../drivers/vioscsi/*",
      "../drivers/vioserial/*",
      "../drivers/viostor/*",
      "../drivers/virtio-win_license.txt",
      "../drivers/virtio-win-gt-x64.msi",
      "../drivers/virtio-win-gt-x86.msi",
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
  sources = ["sources.proxmox-iso.traininglab-win2019"]
  
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

  provisioner "windows-restart" {
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

  provisioner "windows-restart" {
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
