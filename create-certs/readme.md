# Script for creating certificate signing requests (csr)

## certs.sh

This script creates Transport Layer Security (TLS) Certficate Signing Requests and fills in the required information. This repetative task is usually required once a year. For the project in which I was involved, we had TLS certificates for both the frontend ingress and the backend ingress load balancers.

Included is a printout of the final certificate decoded from base64. In my experience, this was uploaded to a Certificate Authority (CA) and returned with a certificate.

The Intermediate and Root Certificates were included as part of the certificate chain. These certificates are stored in the following places depending on the cloud provider.
    AWS - Certificates Manager
        Both Primary & Secondary
    Azure - Key Vault
        Certificates are concatinated together to form 1 large certificate chain
    GCP - Google Secrets Manager
        Certificates are concatinated together to form 1 large certificate chain
