# Getting started

1. Install ArgoCD with `helmfile apply -f helmfile.yml`
2. Install rest of the applications with `kubectl apply -f cert-manager.yml -f sops-secret-operator.yml -f traefik.yml`

> [!NOTE]
> issuing ssl certificates might take some time

## Creating tls certificates for an app

0. Install cert-manager in the cluster
1. Create a certificate in the same namespace as the app.
2. Update app's ingress's tls configuration to point to the secret's name generated with the certificate.

## create a secret for age key

```bash
kubectl create secret generic sops-age-key-file --from-file=key=keys.txt -n sops
```
