## Creating tls certificates for an app

0. Install cert-manager in the cluster
1. Create a certificate in the same namespace as the app.
2. Update app's ingress's tls configuration to point to the secret's name generated with the certificate.
