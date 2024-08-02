terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://${var.pve_node_ip}:8006/api2/json"
  api_token = "${var.tokenid}=${var.tokenkey}"
  insecure  = true
  ssh {
    agent    = true
  }
}

resource "proxmox_virtual_environment_pool" "training_pool" {
  comment = "training resource pool"
  pool_id = "TRAINING"
}

data "proxmox_virtual_environment_vms" "sc" {
  tags      = ["traininglab_sc"]
}

data "proxmox_virtual_environment_vms" "ubuntu" {
  tags      = ["traininglab-server"]
}

data "proxmox_virtual_environment_vms" "win2019" {
  tags      = ["traininglab-win2019"]
}

data "proxmox_virtual_environment_vms" "ws" {
  tags      = ["traininglab-ws"]
}

locals {
  vm_id_templates = {
    win10      = data.proxmox_virtual_environment_vms.ws.vms[0].vm_id
    win2019          = data.proxmox_virtual_environment_vms.win2019.vms[0].vm_id
    ubuntu           = data.proxmox_virtual_environment_vms.ubuntu.vms[0].vm_id
    snare-central    = data.proxmox_virtual_environment_vms.sc.vms[0].vm_id
  }

  default_vm_config = {
    memory      = 4096
    cores       = 2
    sockets     = 1
    disk_size   = 60
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = {
    Linux           = local.vm_id_templates.ubuntu
    WinServer       = local.vm_id_templates.win2019
    Win10           = local.vm_id_templates.workstation
    SnareCentral    = local.vm_id_templates.snare-central
  }

  name = each.key
  pool_id = proxmox_virtual_environment_pool.training_pool.pool_id
  node_name = var.pve_node
  on_boot = false

  clone {
    vm_id = each.value
    full = false
    retries = 2
  }

  agent {
    enabled = true
  } 

  memory {
    dedicated = each.key == "Linux" ? 2048 : local.default_vm_config.memory
    dedicated = each.key == "SnareCentral" ? 16000 : local.default_vm_config.memory
  }

  cpu {
    cores       = local.default_vm_config.cores
    sockets     = local.default_vm_config.sockets
    dedicated = each.key == "SnareCentral" ? 4 : local.default_vm_config.cores
  }

  disk {
    interface    = "scsi0"
    file_format = "raw"
    size    = local.default_vm_config.disk_size
    dedicated = each.key == "SnareCentral" ? 500 : local.default_vm_config.disk_size
    datastore_id = var.storage_name
  }

  network_device {
    bridge = var.netbridge
  }

  lifecycle {
    ignore_changes = [
      disk,
    ]
  }
}

##################### OUTPUT BLOCK #####################

output "ansible_inventory" {
  value = templatefile("${path.module}/inventory_hosts.tmpl", {
    linux_ips = {
      "Linux" = proxmox_virtual_environment_vm.Linux.ipv4_addresses[1][0]
    },
    snare_central_ips = {
      "snare-central" = proxmox_virtual_environment_vm.snare-central.ipv4_addresses[1][0]
    },
    windows_ips = {
      "WinServer"  = proxmox_virtual_environment_vm.WinServer.ipv4_addresses[0][0]
      "Win10" = proxmox_virtual_environment_vm.Win10.ipv4_addresses[0][0]
    }
  })
}
