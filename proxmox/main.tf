provider "proxmox" {
  endpoint  = var.api_url
  api_token = var.api_token

  insecure = true

  random_vm_ids      = true
  random_vm_id_start = 90000
  random_vm_id_end   = 90999

}

module "server" {
  source       = "./modules/proxmox_vm/"
  name         = "server-01"
  node_name    = var.proxmox_host
  template_id  = var.template_id
  datastore_id = var.datastore_id
  ssh_key      = var.ssh_key
}
output "vm_id" {
  value       = module.server.vm_id
  description = "Vm id of created vm"
}
