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
