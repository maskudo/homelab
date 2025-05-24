terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.api_url
  api_token = var.api_token

  insecure = true

  random_vm_ids      = true
  random_vm_id_start = 90000
  random_vm_id_end   = 90999

}

resource "proxmox_virtual_environment_vm" "server" {
  name      = "server"
  node_name = var.proxmox_host
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
        address = "192.168.1.69/24"
      }
    }
  }
}
output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.server.ipv4_addresses
}
