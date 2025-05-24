provider "proxmox" {
  endpoint  = var.api_url
  api_token = var.api_token

  insecure = true

  random_vm_ids      = true
  random_vm_id_start = 90000
  random_vm_id_end   = 90999

}

locals {
  vm_config = [
    {
      name       = "balancer"
      ip_address = "192.168.1.69/24"
    },
    {
      name       = "server0"
      ip_address = "192.168.1.71/24"
    },
    {
      name       = "server1"
      ip_address = "192.168.1.72/24"
    },
    {
      name       = "server2"
      ip_address = "192.168.1.73/24"
    },
    {
      name       = "node0"
      ip_address = "192.168.1.76/24"
    },
    {
      name       = "node1"
      ip_address = "192.168.1.78/24"
    }
  ]
}

module "server" {
  source       = "./modules/proxmox_vm/"
  for_each     = { for vm in local.vm_config : vm.name => vm }
  name         = each.value.name
  ip_address   = each.value.ip_address
  node_name    = var.proxmox_host
  template_id  = var.template_id
  datastore_id = var.datastore_id
  ssh_key      = var.ssh_key
}

output "vm_id" {
  value       = { for name, mod in module.server : name => mod.vm_id }
  description = "Ids of created VMs"
}
