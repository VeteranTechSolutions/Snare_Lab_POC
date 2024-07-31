packer {
  required_plugins {
    # see https://github.com/hashicorp/packer-plugin-qemu
    qemu = {
      version = "1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
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

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "iso_url" {
  type    = string
  default = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1.240331-1435.ge_release_SERVER_EVAL_x64FRE_en-us.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:16442d1c0509bcbb25b715b1b322a15fb3ab724a42da0f384b9406ca1c124ed4"
}

variable "proxmox_node" {
  type    = string
  default = env("PROXMOX_NODE")
}

variable "vagrant_box" {
  type = string
}

source "qemu" "windows-2025-uefi-amd64" {
  accelerator  = "kvm"
  machine_type = "q35"
  cpus         = 2
  memory       = 4096
  qemuargs = [
    ["-bios", "/usr/share/ovmf/OVMF.fd"],
    ["-cpu", "host"],
    ["-device", "qemu-xhci"],
    ["-device", "virtio-tablet"],
    ["-device", "virtio-scsi-pci,id=scsi0"],
    ["-device", "scsi-hd,bus=scsi0.0,drive=drive0"],
    ["-device", "virtio-net,netdev=user.0"],
    ["-vga", "qxl"],
    ["-device", "virtio-serial-pci"],
    ["-chardev", "socket,path=/tmp/{{ .Name }}-qga.sock,server,nowait,id=qga0"],
    ["-device", "virtserialport,chardev=qga0,name=org.qemu.guest_agent.0"],
    ["-chardev", "spicevmc,id=spicechannel0,name=vdagent"],
    ["-device", "virtserialport,chardev=spicechannel0,name=com.redhat.spice.0"],
    ["-spice", "unix,addr=/tmp/{{ .Name }}-spice.socket,disable-ticketing"],
  ]
  boot_wait      = "1s"
  boot_command   = ["<up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait>"]
  disk_interface = "virtio-scsi"
  disk_cache     = "unsafe"
  disk_discard   = "unmap"
  disk_size      = var.disk_size
  floppy_files = [
    "drivers/NetKVM/w11/amd64/*.cat",
    "drivers/NetKVM/w11/amd64/*.inf",
    "drivers/NetKVM/w11/amd64/*.sys",
    "drivers/qxldod/w11/amd64/*.cat",
    "drivers/qxldod/w11/amd64/*.inf",
    "drivers/qxldod/w11/amd64/*.sys",
    "drivers/vioscsi/w11/amd64/*.cat",
    "drivers/vioscsi/w11/amd64/*.inf",
    "drivers/vioscsi/w11/amd64/*.sys",
    "drivers/vioserial/w11/amd64/*.cat",
    "drivers/vioserial/w11/amd64/*.inf",
    "drivers/vioserial/w11/amd64/*.sys",
    "drivers/viostor/w11/amd64/*.cat",
    "drivers/viostor/w11/amd64/*.inf",
    "drivers/viostor/w11/amd64/*.sys",
    "provision-autounattend.ps1",
    "provision-openssh.ps1",
    "provision-psremoting.ps1",
    "provision-pwsh.ps1",
    "provision-winrm.ps1",
    "tmp/windows-2025-uefi/autounattend.xml",
  ]
  format                   = "qcow2"
  headless                 = true
  net_device               = "virtio-net"
  http_directory           = "."
  iso_url                  = var.iso_url
  iso_checksum             = var.iso_checksum
  shutdown_command         = "shutdown /s /t 0 /f /d p:4:1 /c \"Packer Shutdown\""
  communicator             = "ssh"
  ssh_username             = "vagrant"
  ssh_password             = "vagrant"
  ssh_timeout              = "4h"
  ssh_file_transfer_method = "sftp"
}

source "proxmox-iso" "windows-2025-uefi-amd64" {
  template_name            = "template-windows-2025-uefi"
  template_description     = "See https://github.com/rgl/windows-vagrant"
  tags                     = "windows-2025-uefi;template"
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node
  machine                  = "q35"
  bios                     = "ovmf"
  efi_config {
    efi_storage_pool = "local-lvm"
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
    bridge = "vmbr0"
  }
  scsi_controller = "virtio-scsi-single"
  disks {
    type         = "scsi"
    io_thread    = true
    ssd          = true
    discard      = true
    disk_size    = "${var.disk_size}M"
    storage_pool = "local-lvm"
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
      "drivers/NetKVM/w11/amd64/*.cat",
      "drivers/NetKVM/w11/amd64/*.inf",
      "drivers/NetKVM/w11/amd64/*.sys",
      "drivers/qxldod/w11/amd64/*.cat",
      "drivers/qxldod/w11/amd64/*.inf",
      "drivers/qxldod/w11/amd64/*.sys",
      "drivers/vioscsi/w11/amd64/*.cat",
      "drivers/vioscsi/w11/amd64/*.inf",
      "drivers/vioscsi/w11/amd64/*.sys",
      "drivers/vioserial/w11/amd64/*.cat",
      "drivers/vioserial/w11/amd64/*.inf",
      "drivers/vioserial/w11/amd64/*.sys",
      "drivers/viostor/w11/amd64/*.cat",
      "drivers/viostor/w11/amd64/*.inf",
      "drivers/viostor/w11/amd64/*.sys",
      "drivers/spice-guest-tools.exe",
      "drivers/virtio-win-guest-tools.exe",
      "provision-autounattend.ps1",
      "provision-guest-tools-qemu-kvm.ps1",
      "provision-openssh.ps1",
      "provision-psremoting.ps1",
      "provision-pwsh.ps1",
      "provision-winrm.ps1",
      "tmp/windows-2025-uefi/autounattend.xml",
    ]
  }
  boot_wait      = "1s"
  boot_command   = ["<up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait><up><wait>"]
  os             = "win11"
  ssh_username   = "vagrant"
  ssh_password   = "vagrant"
  ssh_timeout    = "60m"
  http_directory = "."
}

build {
  sources = [
    "source.qemu.windows-2025-uefi-amd64",
    "source.proxmox-iso.windows-2025-uefi-amd64",
  ]

  provisioner "powershell" {
    use_pwsh = true
    script   = "disable-windows-updates.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "disable-windows-defender.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    only     = ["qemu.windows-2025-uefi-amd64"]
    script   = "provision-guest-tools-qemu-kvm.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "provision.ps1"
  }

  provisioner "windows-update" {
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "enable-remote-desktop.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "provision-cloudbase-init.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "eject-media.ps1"
  }

  provisioner "powershell" {
    use_pwsh = true
    script   = "optimize.ps1"
  }

  post-processor "vagrant" {
    except               = ["proxmox-iso.windows-2025-uefi-amd64"]
    output               = var.vagrant_box
    vagrantfile_template = "Vagrantfile-uefi.template"
  }
}
