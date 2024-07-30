packer {
  required_plugins {
    windows-update = {
      version = ">=0.14.1"
      source = "github.com/rgl/windows-update"
    }
    qemu = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
    alicloud = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/alicloud"
    }
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
  }
}

source "proxmox-iso" "windows" {

  communicator = "winrm"
# extra drive for Autounnatended.xml
  
additional_iso_files {
    device                  = "sata4"
    iso_storage_pool        = "local"
    cd_files                = ["Autounattend.xml", "bootstrap.ps1"]
    cd_label                = "cidata"
    unmount                 = "true"
  }

  additional_iso_files {
    device                  = "sata5"
    iso_file                = "local:iso/virtio-win.iso"
    unmount                 = "true"
  }
# EFI disk for secure boot
  efi_config {
    efi_storage_pool        = "local-zfs"
    efi_type                = "4m"
    pre_enrolled_keys       = "true"
  }

  boot_command              = ["<wait3s><space><wait3s><space><wait3s><space><wait3s><space><wait5s><space><wait5s><space><wait5s><space><wait5s><space><wait5s><space>"]
  boot_wait                 = "5s"
  bios                      = "ovmf"
  disks {
    cache_mode    = "writeback"
    disk_size     = "50G"
    format        = "raw"
    storage_pool  = "local-zfs"
    type          = "scsi"
  }
  memory                    = "4096"
  ballooning_minimum        = "0"
  cores                     = "4"
  sockets                   = "1"
  os                        = "win11"
  disable_kvm               = false
  cpu_type                  = "host"
  network_adapters {
    bridge      = "vmbr0"
    model       = "virtio"
    firewall    = false
    mac_address = ""
  }

  machine                   = "q35"
  iso_file                  = "local:iso/Win11_23H2_English_x64v2.iso"
  #iso_url                   = "${var.iso_url}"
  #iso_checksum              = "${var.iso_checksum}"
  node                      = "pve"
  proxmox_url               = "https://192.168.10.20:8006/api2/json"
  token                     = "dc8b3782-82eb-403f-b9ad-fc5cd2f75ff9"
  username                  = "userprovisioner@pve!provisioner-token"
  template_name             = "windows11"
  unmount_iso               = true
  insecure_skip_tls_verify  = true
  scsi_controller           = "virtio-scsi-single"
  winrm_password            = "password"
  winrm_timeout             = "8h"
  winrm_username            = "Administrator"
  tags                      = "windows11"
  task_timeout              = "20m"
  qemu_agent                = true
  vga {
    type                    = "virtio"
    memory                  = "32"
  }
}

build {
  sources = ["source.proxmox-iso.windows"]
  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./phase-1.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "1h"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./phase-2.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "1h"
  }

  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    update_limit = 10
  }

  provisioner "windows-restart" {
    restart_timeout = "1h"
  }

  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    update_limit = 10
  }

  provisioner "windows-restart" {
    restart_timeout = "1h"
  }

  provisioner "file" {
    destination = "C:\\Users\\Administrator\\Desktop\\extend-trial.cmd"
    source      = "./extend-trial.cmd"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./phase-5a.software.ps1"
  }

  provisioner "powershell" {
    elevated_password = "password"
    elevated_user     = "Administrator"
    script            = "./phase-5d.windows-compress.ps1"
  }
  provisioner "windows-restart" {
    restart_timeout = "1h"
  }

  provisioner "file" {
    destination = "C:\\Windows\\System32\\Sysprep\\unattend.xml"
    source      = "./unattend.xml"
  }

  provisioner "powershell" {
    inline = ["Write-Output Phase-5-Deprovisioning", "if (!(Test-Path -Path $Env:SystemRoot\\system32\\Sysprep\\unattend.xml)){ Write-Output 'No file';exit (10)}", "& $Env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quit /quiet /unattend:C:\\Windows\\system32\\sysprep\\unattend.xml"]
  }

}
