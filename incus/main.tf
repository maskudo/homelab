terraform {
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "1.0.0"
    }
  }
}

provider "incus" {
  generate_client_certificates = true
  accept_remote_certificate    = true
  default_remote               = var.remote_name

  remote {
    name    = var.remote_name
    address = var.remote_address
    token   = var.token_secret
  }
}

resource "incus_project" "kubernetes" {
  name          = "kubernetes"
  description   = "Kubernetes cluster"
  force_destroy = true
}

resource "incus_storage_pool" "default" {
  name    = "default"
  driver  = "dir"
  project = incus_project.kubernetes.name

  config = {
    source = var.default_storage_pool_path
  }
}

resource "incus_network" "kubernetes" {
  name    = "kubernetes"
  project = incus_project.kubernetes.name
  config = {
    "ipv4.address" = "10.10.10.1/24"
    "ipv4.nat"     = "true"
  }
}

resource "incus_profile" "kubernetes" {
  name    = "kubernetes"
  project = incus_project.kubernetes.name
  config = {
    "limits.cpu" = 2
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = incus_storage_pool.default.name
      path = "/"
    }
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype = "bridged"
      parent  = incus_network.kubernetes.name
    }
  }
}


resource "incus_instance" "ubuntu-server-01" {
  name     = "ubuntu-server-01"
  image    = "images:ubuntu/noble/cloud"
  project  = incus_project.kubernetes.name
  profiles = [incus_profile.kubernetes.name]
  config = {
    "boot.autostart" = true
    "limits.cpu"     = 2
    "limits.memory"  = "4GiB"
  }
  wait_for {
    type = "ipv4"
    nic  = "eth0"
  }
}

output "ubuntu-server-01-ip-address" {
  value = incus_instance.ubuntu-server-01.ipv4_address
}
