packer {
  required_plugins {
    # see https://github.com/hashicorp/packer-plugin-proxmox
    proxmox = {
      version = "1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
    # see https://github.com/hashicorp/packer-plugin-vagrant
    vagrant = {
      version = "1.1.4"
      source  = "github.com/hashicorp/vagrant"
    }
    # see https://github.com/rgl/packer-plugin-windows-update
    windows-update = {
      version = "0.16.7"
      source  = "github.com/rgl/windows-update"
    }
  }
}

source "proxmox-iso" "windows-11-23h2-uefi-amd64" {
  proxmox_url  = "https://${var.proxmox_node}:8006/api2/json"
  node         = var.proxmox_hostname
  username     = var.proxmox_api_id
  token        = var.proxmox_api_token

  template_name            = "windows-11-23h2-uefi"
  template_description     = "See https://github.com/rgl/windows-vagrant"
  tags                     = "traininglab-win11-uefi"
  insecure_skip_tls_verify = true
  machine                  = "q35"
  bios                     = "ovmf"
  efi_config {
    efi_storage_pool = var.storage_name
  }
  cpu_type = "host"
  cores    = 2
  memory   = 4096
  vga {
    type   = "qxl"
    memory = 32
  }
  network_adapters {
    model  = "virtio"
    bridge = var.netbridge
  }
  scsi_controller = "virtio-scsi-single"
  disks {
    type         = "scsi"
    io_thread    = true
    ssd          = true
    discard      = true
    disk_size    = "60G"
    storage_pool = var.storage_name
  }
  iso_storage_pool = "local"
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  unmount_iso      = true
  additional_iso_files {
    device           = "ide0"
    unmount          = true
    iso_storage_pool = "local"
    cd_label         = "PROVISION"
    cd_files = [
      "../drivers/NetKVM/w11/amd64/*.cat",
      "../drivers/NetKVM/w11/amd64/*.inf",
      "../drivers/NetKVM/w11/amd64/*.sys",
      "../drivers/qxldod/w11/amd64/*.cat",
      "../drivers/qxldod/w11/amd64/*.inf",
      "../drivers/qxldod/w11/amd64/*.sys",
      "../drivers/vioscsi/w11/amd64/*.cat",
      "../drivers/vioscsi/w11/amd64/*.inf",
      "../drivers/vioscsi/w11/amd64/*.sys",
      "../drivers/vioserial/w11/amd64/*.cat",
      "../drivers/vioserial/w11/amd64/*.inf",
      "../drivers/vioserial/w11/amd64/*.sys",
      "../drivers/viostor/w11/amd64/*.cat",
      "../drivers/viostor/w11/amd64/*.inf",
      "../drivers/viostor/w11/amd64/*.sys",
      "../drivers/spice-guest-tools.exe",
      "../drivers/virtio-win-guest-tools.exe",
      "../scripts/provision-autounattend.ps1",
      "../scripts/provision-openssh.ps1",
      "../scripts/provision-psremoting.ps1",
      "../scripts/provision-pwsh.ps1",
      "../scripts/provision-winrm.ps1",
      "autounattend.xml",
    ]
  }
  boot_wait      = "1s"
  boot_command   = ["<up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait>"]
  os             = "win11"
  communicator   = "ssh"
  ssh_username   = var.lab_username
  ssh_password   = var.lab_password
  ssh_timeout    = "60m"
  http_directory = "."
}

build {
  sources = ["source.proxmox-iso.windows-11-23h2-uefi-amd64"]

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
    script   = "../scripts/provision.ps1"
  }

  provisioner "windows-update" {
    search_criteria = "AutoSelectOnWebSites=1 and IsInstalled=0"
    update_limit = 25
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/enable-remote-desktop.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/provision-cloudbase-init.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/eject-media.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/debloat-windows.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "../scripts/optimize.ps1"
  }
}
