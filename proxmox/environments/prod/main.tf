provider "proxmox" {
  endpoint  = var.api_url
  api_token = var.api_token

  insecure = true

  random_vm_ids      = true
  random_vm_id_start = 90000
  random_vm_id_end   = 90999

  ssh {
    agent       = false
    username    = var.username
    password    = var.password
    private_key = file(var.private_key)
    node {
      name    = var.proxmox_host
      address = var.proxmox_host_ip
    }
  }
}

module "ubuntu_template" {
  source       = "../../modules/ubuntu_template"
  name         = "ubuntu-2404-template"
  node_name    = var.proxmox_host
  datastore_id = var.datastore_id
  ssh_key      = var.ssh_key
  username     = "ubuntu"
  disk_size    = 20
}


module "server" {
  source       = "../../modules/proxmox_vm"
  name         = "home-server"
  ip_address   = "192.168.1.199/24"
  node_name    = var.proxmox_host
  template_id  = module.ubuntu_template.vm_id
  datastore_id = var.datastore_id
  ssh_key      = var.ssh_key
  disk_size    = 80
  memory_size  = 4096
  cpu_cores    = 4
}

output "vm_id_home_server" {
  value       = module.server.vm_id
  description = "Id of home-server VMs"

}
