terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = var.name
  node_name = var.node_name
  started   = false
  clone {
    vm_id = var.template_id
  }

  agent {
    enabled = false
  }

  memory {
    dedicated = var.memory_size
  }

  cpu {
    cores = var.cpu_cores
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "virtio0"
    size         = var.disk_size
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    datastore_id = var.datastore_id

    user_account {
      keys     = [var.ssh_key]
      username = "ubuntu"
      password = ""
    }

    ip_config {
      ipv4 {
        address = var.ip_address
        gateway = var.gateway
      }
    }
  }
}
