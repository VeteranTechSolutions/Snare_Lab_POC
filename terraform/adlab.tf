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
}

resource "proxmox_virtual_environment_pool" "training_pool" {
  comment = "training resource pool"
  pool_id = "TRAINING"
}

data "proxmox_virtual_environment_vms" "sc" {
  tags      = ["traininglab-sc"]
}

data "proxmox_virtual_environment_vms" "server" {
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
    workstation      = data.proxmox_virtual_environment_vms.ws.vms[0].vm_id
    win2019          = data.proxmox_virtual_environment_vms.win2019.vms[0].vm_id
    ubuntu           = data.proxmox_virtual_environment_vms.server.vms[0].vm_id
    snare-central    = data.proxmox_virtual_environment_vms.sc.vms[0].vm_id
  }

  default_vm_config = {
    memory  = 4096
    cores   = 2
    sockets = 1
    disk_size = 60
  }
}

resource "proxmox_virtual_environment_vm" "snare-central" {
  name      = "Snare-Central"
  pool_id   = proxmox_virtual_environment_pool.training_pool.pool_id
  node_name = var.pve_node
  on_boot   = false

  clone {
    vm_id  = local.vm_id_templates.snare-central
    full   = false
    retries = 2
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = 16000
  }

  cpu {
    cores   = 4
    sockets = 1
  }

  disk {
    interface    = "scsi0"
    file_format  = "raw"
    size         = "500GB"
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

resource "proxmox_virtual_environment_vm" "ubuntu" {
  name      = "Linux-Desktop"
  pool_id   = proxmox_virtual_environment_pool.training_pool.pool_id
  node_name = var.pve_node
  on_boot   = false

  clone {
    vm_id  = local.vm_id_templates.ubuntu_server
    full   = false
    retries = 2
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = local.default_vm_config.memory
  }

  cpu {
    cores   = local.default_vm_config.cores
    sockets = local.default_vm_config.sockets
  }

  disk {
    interface    = "scsi0"
    file_format  = "raw"
    size         = local.default_vm_config.disk_size
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

resource "proxmox_virtual_environment_vm" "win2019" {
  name      = "Win-Server"
  pool_id   = proxmox_virtual_environment_pool.training_pool.pool_id
  node_name = var.pve_node
  on_boot   = false

  clone {
    vm_id  = local.vm_id_templates.windows_server_2019
    full   = false
    retries = 2
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = local.default_vm_config.memory
  }

  cpu {
    cores   = local.default_vm_config.cores
    sockets = local.default_vm_config.sockets
  }

  disk {
    interface    = "scsi0"
    file_format  = "raw"
    size         = local.default_vm_config.disk_size
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

resource "proxmox_virtual_environment_vm" " workstation" {
  name      = "Win-Desktop"
  pool_id   = proxmox_virtual_environment_pool.training_pool.pool_id
  node_name = var.pve_node
  on_boot   = false

  clone {
    vm_id  = local.vm_id_templates.windows_10
    full   = false
    retries = 2
  }

  agent {
    enabled = true
  }

  memory {
    dedicated = local.default_vm_config.memory
  }

  cpu {
    cores   = local.default_vm_config.cores
    sockets = local.default_vm_config.sockets
  }

  disk {
    interface    = "scsi0"
    file_format  = "raw"
    size         = local.default_vm_config.disk_size
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
      "ubuntu" = proxmox_virtual_environment_vm.ubuntu.ipv4_addresses[1][0]
    },
    snare_central_ips = {
      "snare-central" = proxmox_virtual_environment_vm.snare-central.ipv4_addresses[1][0]
    },
    windows_ips = {
      "win2019"  = proxmox_virtual_environment_vm.win2019.ipv4_addresses[0][0]
      "workstation" = proxmox_virtual_environment_vm.workstation.ipv4_addresses[0][0]
    }
  })
}
