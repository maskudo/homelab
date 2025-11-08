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
      parent  = "vmbr0"
    }
  }
}


resource "incus_instance" "ubuntu-server-01" {
  name     = "ubuntu-server-01"
  image    = "images:ubuntu/noble/cloud"
  type     = "virtual-machine"
  project  = incus_project.kubernetes.name
  profiles = [incus_profile.kubernetes.name]
  config = {
    "boot.autostart"       = true
    "limits.cpu"           = 2
    "limits.memory"        = "4GiB"
    "cloud-init.user-data" = <<EOF
      #cloud-config
      users:
        - name: ubuntu
          ssh_authorized_keys:
            - ${file("~/.ssh/id_ed25519.pub")}
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
      package_update: true
      package_upgrade: true
      package_reboot_if_required: true
      packages:
        - openssh-server
        - nfs-common
        - open-iscsi
    EOF
  }
}

resource "incus_instance" "ubuntu-worker" {
  count    = 2
  name     = "ubuntu-worker-0${count.index}"
  type     = "virtual-machine"
  image    = "images:ubuntu/noble/cloud"
  project  = incus_project.kubernetes.name
  profiles = [incus_profile.kubernetes.name]
  config = {
    "boot.autostart"       = true
    "limits.cpu"           = 2
    "limits.memory"        = "6GiB"
    "cloud-init.user-data" = <<EOF
      #cloud-config
      users:
        - name: ubuntu
          ssh_authorized_keys:
            - ${file("~/.ssh/id_ed25519.pub")}
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
      package_update: true
      package_upgrade: true
      package_reboot_if_required: true
      packages:
        - openssh-server
        - nfs-common
        - open-iscsi
    EOF
  }
}

output "ubuntu-server-01-ip-address" {
  value = incus_instance.ubuntu-server-01.ipv4_address
}

output "ubuntu-workers-ip-addresss" {
  value = { for idx, instance in incus_instance.ubuntu-worker : instance.name => instance.ipv4_address }
}
