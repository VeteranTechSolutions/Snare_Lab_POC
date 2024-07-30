packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
    windows-update = {
      version = "0.14.3"
      source = "github.com/rgl/windows-update"
    }
  }
}

source "proxmox-iso" "traininglab-win11" {
  proxmox_url  = "https://${var.proxmox_node}:8006/api2/json"
  node         = var.proxmox_hostname
  username     = var.proxmox_api_id
  token        = var.proxmox_api_token
  
  #iso_file     = "local:iso/windpws_server_2019.iso" #-- uncomment if you want to use local iso file and comment the next four lines
  iso_checksum             = "sha256:36DE5ECB7A0DAA58DCE68C03B9465A543ED0F5498AA8AE60AB45FB7C8C4AE402"
  iso_url                  = "https://software.download.prss.microsoft.com/dbazure/Win11_23H2_English_x64v2.iso?t=dccab1b1-6b8c-4b9b-be1d-fed30614a950&P1=1722372578&P2=601&P3=2&P4=h2I4r2Z7vwLhNQIgIajkjIEVSFZjEYRwsdtKvpgnD93On8va%2bOFQxbrPKiQae7nW%2fwOCTj%2fEVOGYFMxIAYwjvPU4sS%2fHbKtSRuSwAjwbThtkvYho%2fqeYMoUN8JbSC%2bSzf6YC6y%2fTI9npa3%2fBQnCaPpqgxZO4LFgubexl4RqJDMrXemE31ba5yAlnV7VZxqVM1FZd5Cp1%2fbf4cTn2NuOb6Zh4dkXEnOF8Ogox9phyNBmKnPbN4bu4I1cIwsdoBsua9e7G9bHZxjpYJ7rSmKDmFJQ67kgvIFkskkQ3o0YYvXOEEhDlCd3zDFfTgTGsSMmpmfgYeYQlc1KIgFgapLlHqw%3d%3d"
  iso_storage_pool         = "local"
  iso_download_pve = true

  communicator             = "ssh"
  ssh_username             = var.lab_username
  ssh_password             = var.lab_password
  ssh_timeout              = "30m"
  qemu_agent               = true
  cores                    = 6
  cpu_type                  = "host"
  memory                   = 8192
  vm_name                  = "traininglab-win11"
  tags                     = "traininglab-win11"
  template_description     = "TrainingLab Windows 11 Template - Sysprep done"
  insecure_skip_tls_verify = true
  unmount_iso = true
  task_timeout = "30m"

  additional_iso_files {
    cd_files =["autounattend.xml"]
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
    efi_storage_pool        = var.efi_storage_pool
    efi_type                = var.efi_type
    pre_enrolled_keys       = var.pre_enrolled_keys
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
  sources = ["sources.proxmox-iso.traininglab-win11"]
  
  provisioner "windows-update" {
    search_criteria = "AutoSelectOnWebSites=1 and IsInstalled=0"
    update_limit = 25
  }

  provisioner "file" {
    source      = "server-sysprep.xml"
    destination = "C:/Users/Public/sysprep.xml"
  }

  provisioner "windows-shell" {
    inline = [
    "c:\\windows\\system32\\sysprep\\sysprep.exe /mode:vm /generalize /oobe /shutdown /unattend:C:\\Users\\Public\\sysprep.xml",
    ]
  }
}
