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
  tags = ["traininglab-sc"]
}

data "proxmox_virtual_environment_vms" "ubuntu_server" {
  tags = ["traininglab-server"]
}

data "proxmox_virtual_environment_vms" "win2019" {
  tags = ["traininglab-win2019"]
}

data "proxmox_virtual_environment_vms" "ws" {
  tags = ["traininglab-ws"]
}

locals {
  vm_id_templates = {
    windows_10              = data.proxmox_virtual_environment_vms.ws.vms[0].vm_id
    windows_server_2019     = data.proxmox_virtual_environment_vms.win2019.vms[0].vm_id
    ubuntu_server           = data.proxmox_virtual_environment_vms.ubuntu_server.vms[0].vm_id
    snare_central           = data.proxmox_virtual_environment_vms.sc.vms[0].vm_id
  }

  default_vm_config = {
    memory  = 4096
    cores   = 2
    sockets = 1
    disk_size = 60
  }
}

resource "proxmox_virtual_environment_vm" "snare_central" {
  name      = "Snare-Central"
  pool_id   = proxmox_virtual_environment_pool.training_pool.pool_id
  node_name = var.pve_node
  on_boot   = false

  clone {
    vm_id  = local.vm_id_templates.snare_central
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

resource "proxmox_virtual_environment_vm" "ubuntu_server" {
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

resource "proxmox_virtual_environment_vm" "win_server" {
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

resource "proxmox_virtual_environment_vm" "win_desktop" {
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
      "Linux-Desktop" = proxmox_virtual_environment_vm.ubuntu_server.ipv4_addresses[1][0]
    },
    snare_central_ips = {
      "Snare-Central" = proxmox_virtual_environment_vm.snare_central.ipv4_addresses[1][0]
    },
    windows_ips = {
      "Win-Server"  = proxmox_virtual_environment_vm.win_server.ipv4_addresses[0][0]
      "Win-Desktop" = proxmox_virtual_environment_vm.win_desktop.ipv4_addresses[0][0]
    }
  })
}
