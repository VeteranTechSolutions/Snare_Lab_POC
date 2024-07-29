packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
    windows-update = {
       version = "0.16.7"
       source  = "github.com/rgl/windows-update"
    }
  }
}

source "proxmox-iso" "windows" {

  communicator = "${var.communicator}"
# extra drive for Autounnatended.xml
  additional_iso_files {
    unmount                 = "true"
    device                  = "sata4"
    iso_storage_pool        = "${var.iso_storage_pool}"
    cd_files                = "${var.cd_files}"
  }

  additional_iso_files {
    unmount                 = "true"
    device                  = "sata5"
    iso_file                = "${var.virtio_iso_file}"
  }
# EFI disk for secure boot
  efi_config {
    efi_storage_pool        = "${var.efi_config.efi_storage_pool}"
    efi_type                = "${var.efi_config.efi_type}"
    pre_enrolled_keys       = "${var.efi_config.pre_enrolled_keys}"
  }

  boot_command              = "${var.boot_command}"
  boot_wait                 = "${var.boot_wait}"
  bios                      = "${var.bios}"
  disks {
    cache_mode              = "${var.disks.cache_mode}"
    disk_size               = "${var.disks.disk_size}"
    format                  = "${var.disks.format}"
    storage_pool            = "${var.disks.storage_pool}"
    type                    = "${var.disks.type}"
  }
  memory                    = "${var.memory}"
  ballooning_minimum        = "${var.ballooning_minimum}"
  cores                     = "${var.cores}"
  sockets                   = "${var.sockets}"
  os                        = "${var.os}"
  disable_kvm               = "${var.disable_kvm}"
  cpu_type                  = "${var.cpu_type}"
  network_adapters {
    bridge                  = "${var.network_adapters.bridge}"
    model                   = "${var.network_adapters.model}"
    firewall                = "${var.network_adapters.firewall}"
    mac_address             = "${var.network_adapters.mac_address}"
  }

  machine                   = "${var.machine}"
  iso_file                  = "${var.iso_file}"
  node                      = "${var.proxmox_node}"
  proxmox_url               = "${var.proxmox_url}"
  token                     = "${var.proxmox_token}"
  username                  = "${var.proxmox_username}"
  template_name             = "${var.template}.${local.packer_timestamp}"
  unmount_iso               = "${var.unmount_iso}"
  insecure_skip_tls_verify  = "${var.insecure_skip_tls_verify}"
  scsi_controller           = "${var.scsi_controller}"
  winrm_password            = "${var.winrm_password}"
  winrm_timeout             = "8h"
  winrm_username            = "${var.winrm_username}"
  tags                      = "${var.tags}"
  task_timeout              = "${var.task_timeout}"
  qemu_agent                = "${var.qemu_agent}"
  vga {
    type                    = "${var.vga.type}"
    memory                  = "${var.vga.memory}"
  }
}

build {
  sources = ["source.proxmox-iso.windows"]
  provisioner "powershell" {
    elevated_password = "${var.winrm_password}"
    elevated_user     = "${var.winrm_username}"
    script            = "./extra/scripts/windows/shared/phase-1.ps1"
  }
  
  provisioner "windows-update" {
    search_criteria = "AutoSelectOnWebSites=1 and IsInstalled=0"
    update_limit = 25
  }

  provisioner "file" {
    destination = "C:\\Users\\Administrator\\Desktop\\extend-trial.cmd"
    source      = "./extra/scripts/windows/shared/extend-trial.cmd"
  }

  provisioner "powershell" {
    elevated_password = "${var.winrm_password}"
    elevated_user     = "${var.winrm_username}"
    script            = "./extra/scripts/windows/shared/phase-5a.software.ps1"
  }

  provisioner "powershell" {
    elevated_password = "${var.winrm_password}"
    elevated_user     = "${var.winrm_username}"
    script            = "./extra/scripts/windows/shared/phase-5d.windows-compress.ps1"
  }

  provisioner "file" {
    destination = "C:\\Windows\\System32\\Sysprep\\unattend.xml"
    source      = "${var.sysprep_unattended}"
  }

  provisioner "powershell" {
    inline = ["Write-Output Phase-5-Deprovisioning", "if (!(Test-Path -Path $Env:SystemRoot\\system32\\Sysprep\\unattend.xml)){ Write-Output 'No file';exit (10)}", "& $Env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quit /quiet /unattend:C:\\Windows\\system32\\sysprep\\unattend.xml"]
  }

}
