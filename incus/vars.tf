#Blank var for use by terraform.tfvars
variable "token_secret" {
}

variable "remote_name" {
  default = "aspire"
}

variable "remote_address" {
  default = "https://192.168.1.67:8443"
}

variable "default_storage_pool_path" {
  default = "/mnt/ssd/incus"
}
