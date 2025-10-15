# Using sops and age

## Create age key from ssh private key

```bash
ssh-to-age -private-key -i /home/omen/.ssh/id_ed25519 -o key.txt
```

## Create age key from ssh public key

```bash
ssh-to-age -i /home/omen/.ssh/id_ed25519.pub -o public_key.txt
```

## Encrypt using sops

```bash
sops encrypt secret.yml > secret.sops.yml
```

## Decrypt using sops

```bash
sops decrypt secret.sops.yml > secret.yml
```
