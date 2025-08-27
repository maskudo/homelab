variable "name" {}

variable "node_name" {
  default = "mk489-nixos"
}

variable "template_id" {
  default = 8000
}

variable "datastore_id" {
  default = "ssd-storage"
}

variable "ssh_key" {
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ2bl3yHCcGK2dvde0CYmWmcYWiBSju3OuVyj4O9afJp mk489"
}

variable "ip_address" {
  default = "dhcp"
}

variable "gateway" {
  default = "192.168.1.254"
}

variable "disk_size" {
  default = 20
}

variable "memory_size" {
  default = 2048
}

variable "cpu_cores" {
  default = 2
}
