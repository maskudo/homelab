#Set your public SSH key here
variable "ssh_key" {
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2bl3yHCcGK2dvde0CYmWmcYWiBSju3OuVyj4O9afJp mk489"
}
#Establish which Proxmox host you'd like to spin a VM up on
variable "proxmox_host" {
  default = "mk489-nixos"
}

variable "proxmox_host_ip" {
  default = "192.168.1.67"
}

#Specify which template name you'd like to use
variable "template_name" {
  default = "ubuntu-2404-cloud"
}
#Specify which template id you'd like to use
variable "template_id" {
  default = 8000
}
#Establish which nic you would like to utilize
variable "nic_name" {
  default = "vmbr0"
}
#Provide the url of the host you would like the API to communicate on.
#It is safe to default to setting this as the URL for what you used
#as your `proxmox_host`, although they can be different
variable "api_url" {
  default = "https://192.168.1.67:8006/api2/json"
}

variable "datastore_id" {
  default = "ssd-storage"
}

variable "private_key" {
  default = "~/.ssh/id_ed25519"
}

#Blank var for use by terraform.tfvars
variable "token_secret" {
}
#Blank var for use by terraform.tfvars
variable "token_id" {
}
#
#Blank var for use by terraform.tfvars
variable "api_token" {
}

#Blank var for use by terraform.tfvars
variable "username" {
}
#
#Blank var for use by terraform.tfvars
variable "password" {
}
