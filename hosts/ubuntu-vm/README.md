# K3s

## Ping a host

```bash
ansible all -i '10.0.3.248,' -m ping -u ubuntu
```

## Run a playbook

```bash
ansible-playbook -i hosts.ini -K -u ubuntu-base local.yml
```

## Convert to a template for proxmox

```bash
ansible-playbook -i hosts.ini -K -u ubuntu-base -t make-template  local.yml
```

## Run an ad-hoc command on a host

Here, `ubuntuvm` is a group defined in `hosts.ini`.

```bash
ansible ubuntuvm -a 'hostname'
```

## Find all online hosts in the network

`sudo nmap -sn 192.168.1.0/24`

## Setup K3s

- add ip addresses to `hosts.ini` of all the servers and nodes
- add ip addresses of load balancer and servers in `haproxy.conf` file

```bash
ansible-playbook local.yml -b --tags k3s -i hosts.ini
```

## K3s installation

We have a load balancer that balances between the 3 k3s servers in high
availability mode.
The servers use distributed etcd as its datastore.

To get `kubectl` working in dev machine:

1. Copy `k3s.yml` file from `/etc/rancher/k3s/k3s.yml` onto the dev machine.
2. `export KUBECONFIG=./k3s.yaml`
3. `kubectl get nodes`
