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
    dedicated = 1024
  }

  disk {
    datastore_id = var.datastore_id
    interface    = "virtio0"
  }

  initialization {
    datastore_id = var.datastore_id
    dns {
      servers = ["1.1.1.1"]
    }

    user_account {
      keys     = [var.ssh_key]
      username = "ubuntu"
      password = ""
    }

    ip_config {
      ipv4 {
        address = var.ip_address
      }
    }
  }
}
