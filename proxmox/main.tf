terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  # References our vars.tf file to plug in the api_url 
  pm_api_url = var.api_url
  # References our secrets.tfvars file to plug in our token_id
  pm_api_token_id = var.token_id
  # References our secrets.tfvars to plug in our token_secret 
  pm_api_token_secret = var.token_secret
  # Default to `true` unless you have TLS working within your pve setup 
  pm_tls_insecure = true
}

# Creates a proxmox_vm_qemu entity named blog_demo_test
resource "proxmox_vm_qemu" "test" {
  name        = "test-vm-01"
  target_node = var.proxmox_host

  clone      = var.template_name
  full_clone = "true"

  cores   = 2
  sockets = 1
  memory  = 2048
  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot    = "ide1"
    size    = "20G"
    type    = "cloudinit"
    storage = "ssd-storage" # Name of storage local to the host you are spinning the VM up on
    discard = true
  }

  network {
    id="1"
    model     = "virtio"
    bridge    = var.nic_name
    firewall  = false
    link_down = false
  }

  #
  # lifecycle {
  #   ignore_changes = [
  #     network,
  #   ]
  # }
  #provisioner "local-exec" {
  # Provisioner commands can be run here.
  # We will use provisioner functionality to kick off ansible
  # playbooks in the future
  #command = "touch /home/tcude/test.txt"
  #}
}
