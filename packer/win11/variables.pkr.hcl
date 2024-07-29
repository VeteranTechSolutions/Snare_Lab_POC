variable "ballooning_minimum" {
  type    = string
  default = "0"
}

variable "bios" {
  type    = string
  default = "ovmf"
}

variable "boot_command" {
  type = list(string)
  default = [
    "<wait3s><space><wait3s><space><wait3s><space><wait3s><space><wait5s><space><wait5s><space><wait5s><space><wait5s><space><wait5s><space>"
  ]
}

variable "boot_wait" {
  type    = string
  default = "10s"
}

variable "cd_files" {
  type = list(string)
  default = []
}

variable "communicator" {
  type    = string
  default = "winrm"
}

variable "cores" {
  type    = string
  default = "1"
}

variable "cpu_type" {
  type    = string
  default = "host"
}

variable "disable_kvm" {
  type    = bool
  default = false
}

variable "disks" {
  type = object({
    cache_mode   = string
    disk_size    = string
    format       = string
    storage_pool = string
    type         = string
  })
  default = {
    cache_mode   = "none"
    disk_size    = "50G"
    format       = "raw"
    storage_pool = "local"
    type         = "virtio"
  }
}

variable "efi_config" {
  type = object({
    efi_storage_pool = string
    efi_type         = string
    pre_enrolled_keys = bool
  })
  default = {
    efi_storage_pool = "local"
    efi_type         = "4m"
    pre_enrolled_keys = true
  }
}

variable "insecure_skip_tls_verify" {
  type    = bool
  default = true
}

variable "iso_file" {
  type    = string
  default = ""
}

variable "iso_storage_pool" {
  type    = string
  default = "local"
}

variable "machine" {
  type    = string
  default = "q35"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "network_adapters" {
  type = object({
    bridge      = string
    model       = string
    firewall    = bool
    mac_address = string
  })
  default = {
    bridge      = "vmbr0"
    model       = "virtio"
    firewall    = false
    mac_address = ""
  }
}

variable "os" {
  type    = string
  default = "l26"
}

variable "proxmox_node" {
  type    = string
  default = ""
}

variable "proxmox_token" {
  type    = string
  default = ""
  sensitive = true
}

variable "proxmox_url" {
  type    = string
  default = ""
}

variable "proxmox_username" {
  type    = string
  default = ""
}

variable "qemu_agent" {
  type    = bool
  default = true
}

variable "scsi_controller" {
  type    = string
  default = "virtio-scsi-single"
}

variable "sockets" {
  type    = string
  default = "1"
}

variable "sysprep_unattended" {
  type    = string
  default = ""
}

variable "task_timeout" {
  type    = string
  default = "15m"
}

variable "template" {
  type    = string
  default = ""
}

variable "unmount_iso" {
  type    = bool
  default = true
}

variable "winrm_username" {
  type = string
  default = "root"
}

variable "winrm_password" {
  type = string
  sensitive = true
  default = "password"
}

variable "winrm_port" {
  type = number
  default = 22
}

variable "vga" {
    type = object({
      type = string
      memory = string
    })
    default = {
      type = "std"
      memory = "256"
    }
  }

variable "virtio_iso_file" {
  type    = string
  default = "virtio-win.iso"
}

variable "use_efi" {
  type    = bool
  default = false
}

variable "tags" {
  type = string
  default = "uefi;template"
}

variable "pre_enrolled_keys" {
  type = bool
  default = false
}

variable "efi_type" {
  type    = string
  default = "4m"
}

variable "efi_storage_pool" {
  type    = string
  default = "local"
}
