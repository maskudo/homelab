# AGENTS.md

This file provides guidance to AI code assistants when working with code in this repository.

## Repository Overview

This is a homelab infrastructure repository managing multiple compute environments (Proxmox VMs, Incus containers) and application deployments via Docker Compose and Kubernetes (K3s). The infrastructure uses GitOps principles with ArgoCD for K8s deployments. This repository constitutes an "Infrastructure as Code" (IaC) project for managing a personal homelab. It leverages a suite of modern DevOps tools to automate the provisioning and configuration of services and infrastructure across various platforms, including bare-metal (via NixOS), Docker, Kubernetes, and cloud providers like AWS.

The project is architected around the principles of reproducibility and declarative configuration, with a strong emphasis on security and automation.

## Core Technologies

*   **Nix & NixOS:** The `flake.nix` files indicate that the project uses the Nix package manager and NixOS for creating reproducible development environments and system configurations. This ensures that anyone (or any machine) can instantiate the exact same environment with the same dependencies.
*   **Docker & Docker Compose:** A significant portion of the services are containerized using Docker and defined in `docker-compose.yml` files. This allows for easy deployment and management of services like `audiobookshelf`, `traefik`, `authelia`, and more.
*   **Kubernetes (k8s):** The `k8s` directory contains manifests for deploying applications into a Kubernetes cluster.
*   **ArgoCD:** The presence of `argocd` in `flake.nix` and the application manifests in `k8s/apps` indicate that ArgoCD is used for GitOps-style continuous delivery of the Kubernetes applications.
*   **Terraform/OpenTofu:** The `incus`, `proxmox` and `aws` directories contain Terraform configurations for provisioning infrastructure on Incus (a lightweight VM hypervisor), Proxmox and Amazon Web Services, respectively.
*   **Ansible:** The `hosts` directory, particularly `hosts/pizero/flake.nix` with its `ansible` dependency, suggests that Ansible is used for configuration management of specific hosts.
*   **Traefik:** Traefik is used as a reverse proxy and ingress controller for both Docker and Kubernetes environments, providing automated service discovery, SSL termination with Let's Encrypt, and authentication via Authelia.
*   **Sops:** `sops` is used for managing secrets. The `.sops.yaml` file defines rules for encrypting sensitive data within YAML files using `age` encryption.

## Architecture

### Compute Provisioning
- **Proxmox**: Uses OpenTofu/Terraform modules in `proxmox/` to provision VM templates and VMs
  - Modules: `ubuntu_template`, `proxmox_vm`
  - Environments: `proxmox/environments/prod/`
- **Incus**: Provisions LXC containers and VMs via Terraform in `incus/`
  - Creates Kubernetes cluster with 1 server and 2 worker nodes

### Configuration Management
- **Ansible**: `hosts/` contains playbooks for host configuration
  - `hosts/ubuntu-vm/`: K3s cluster setup, Docker, NFS, core utilities
  - `hosts.ini`: Inventory files for target hosts

### Application Deployments

#### Kubernetes (k8s/)
- **GitOps**: ArgoCD manages application deployments from `k8s/apps/`
- **Structure**: Each app has its own directory with manifests or kustomize configs
  - Some apps use base/overlays pattern (e.g., `paperless/base/`, `paperless/overlays/production/`)
  - Others use flat structure with kustomization files
- **Infrastructure Components**:
  - **cert-manager**: TLS certificate management via Let's Encrypt
  - **traefik**: Ingress controller and reverse proxy
  - **cnpg**: CloudNativePG operator for PostgreSQL clusters
  - **longhorn**: Distributed block storage
  - **csi-driver-nfs**: NFS storage provisioner
  - **reflector**: Secret/ConfigMap synchronization across namespaces
  - **sops-secrets-operator**: Encrypted secrets management
- **Applications**: immich, paperless, audiobookshelf, filebrowser, qbittorrent, atuin, wallabag, ollama, monitoring

#### Docker Compose (docker/)
- Standalone Docker Compose stacks for services not yet migrated to K8s
- Each service in its own directory with `docker-compose.yml`

## Common Commands

### Development Environment

The repository uses Nix flakes for development dependencies:
```bash

# Enter dev shell (with direnv)
direnv allow

# Or manually
nix develop
```

Available tools in dev shell: `age`, `sops`, `ssh-to-age`, `argocd`

### Kubernetes

#### Initial cluster setup
```bash

# Install ArgoCD
helmfile apply -f k8s/argocd/helmfile.yml

# Install core infrastructure
kubectl apply -f k8s/apps/cert-manager.yml \
              -f k8s/apps/sops-secrets-operator.yml \
              -f k8s/apps/traefik.yml

# Deploy an application via ArgoCD
kubectl apply -f k8s/apps/<app-name>.yml
```

#### Working with individual apps
```bash

# Apply kustomize-based app
kubectl apply -k k8s/<app-name>/

# For apps with overlays
kubectl apply -k k8s/<app-name>/overlays/production/
```

#### Installing infrastructure with helmfile
```bash

# Install a Helm chart (cert-manager, traefik, longhorn, etc.)
helmfile apply -f k8s/<component>/helmfile.yml
```

### Ansible

#### Run playbooks on hosts
```bash
cd hosts/ubuntu-vm

# Run full playbook
ansible-playbook -i hosts.ini -K -u ubuntu-base local.yml

# Run specific tags (e.g., k3s setup)
ansible-playbook local.yml -b --tags k3s -i hosts.ini

# Ping hosts
ansible all -i '10.0.3.248,' -m ping -u ubuntu

# Ad-hoc command
ansible <group-name> -a 
```

### Terraform/OpenTofu

#### Proxmox VMs
```bash
cd proxmox/environments/prod
tofu init
tofu plan
tofu apply
```

#### Incus containers
```bash
cd incus
terraform init
terraform plan
terraform apply
```

### Secrets Management (SOPS + age)

#### Encrypt/decrypt secrets
```bash

# Encrypt
sops encrypt secret.yml > secret.sops.yml

# Decrypt
sops decrypt secret.sops.yml > secret.yml

# Edit encrypted file in-place
sops secret.sops.yml
```

#### Create age key from SSH key
```bash

# Private key
ssh-to-age -private-key -i ~/.ssh/id_ed25519 -o key.txt

# Public key
ssh-to-age -i ~/.ssh/id_ed25519.pub -o public_key.txt
```

#### Create Kubernetes secret for SOPS
```bash
kubectl create secret generic sops-age-key-file \
  --from-file=key=keys.txt -n sops
```

## Key Files

- `.sops.yaml`: SOPS configuration with age public key and encryption rules
- `flake.nix`: Nix development environment definition
- `k8s/apps/*.yml`: ArgoCD Application manifests pointing to app directories
- `k8s/README.md`: Additional K8s setup instructions
- `hosts/ubuntu-vm/k3s.yaml`: K3s cluster setup playbook

## Important Patterns

### TLS Certificates
1. cert-manager must be installed in cluster
2. Create Certificate resource in app's namespace
3. Reference the generated secret name in Ingress `tls.secretName`

### K3s Cluster
- High availability setup with 3 servers using distributed etcd
- Load balancer balances traffic between servers
- To use kubectl locally: copy `/etc/rancher/k3s/k3s.yml` and set `KUBECONFIG`

### Storage
- **NFS**: `nfs-delete` and `nfs-retain` storage classes for persistent volumes
- **Longhorn**: Distributed block storage for stateful workloads
- PostgreSQL databases use CloudNativePG operator with persistent volumes

### Secret Files
All `*secret.yml` and `*secret.yaml` files are gitignored. Use `.sops.yml` encrypted versions.
Encrypted files have `.sops.yml` or `.sops.yaml` suffix.
