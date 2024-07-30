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
  proxmox_url               = "https://192.168.10.20:8006/api2/json"
  token                     = "dc8b3782-82eb-403f-b9ad-fc5cd2f75ff9"
  username                  = "userprovisioner@pve!provisioner-token"
  node                      = "pve"

  machine                   = "q35"
  bios                      = "ovmf"
  ballooning_minimum        = "0"
  os                        = "l26"
  disable_kvm               = false
  
  
  
  #template_name            = "windows2022-std.microsoft.com"

  iso_file                  = "local:iso/Win11_23H2_English_x64v2.iso"
  #iso_url                  = "${var.iso_url}"
  #iso_checksum             = "${var.iso_checksum}"
  iso_storage_pool          = "local"
  iso_download_pve = true

  communicator              = "ssh"
  ssh_username              = "Administrator"
  ssh_password              = "password"
  ssh_timeout               = "30m"
  qemu_agent                = true
  cores                     = 4
  cpu_type                  = "host"
  memory                    = 4096
  vm_name                   = "traininglab-win11"
  tags                      = "windows11"
  template_description      = "TrainingLab Workstation Template"
  insecure_skip_tls_verify  = true
  unmount_iso               = true
  task_timeout              = "20m"

additional_iso_files {
    cd_files =["Autounattend.xml"]
    cd_label = "auto-win11.iso"
    iso_storage_pool = "local"
    unmount      = true
  }

  additional_iso_files {
    device       = "sata0"
    iso_url     = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"
    iso_checksum = "none"
    iso_storage_pool = "local"
    unmount      = true
  }

# EFI disk for secure boot
  efi_config {
    efi_storage_pool        = "local-zfs"
    efi_type                = "4m"
    pre_enrolled_keys       = "true"
  }

  network_adapters {
    bridge      = "vmbr0"
    model       = "virtio"
    firewall    = false
    mac_address = ""
  }

  disks {
    cache_mode    = "writeback"
    disk_size     = "50G"
    format        = "raw"
    storage_pool  = "local-zfs"
    type          = "sata"
  }

  scsi_controller           = "virtio-scsi-single"

}

build {
  sources = ["sources.proxmox-iso.windows"]
  
  provisioner "windows-update" {
    search_criteria = "AutoSelectOnWebSites=1 and IsInstalled=0"
    update_limit = 25
  }

  provisioner "file" {
    source      = "ws-sysprep.xml"
    destination = "C:/Users/Public/sysprep.xml"
  }

  provisioner "windows-shell" {
    inline = [
    "c:\\windows\\system32\\sysprep\\sysprep.exe /mode:vm /generalize /oobe /shutdown /unattend:C:\\Users\\Public\\sysprep.xml",
    ]
  }
}
