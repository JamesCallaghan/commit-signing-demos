#!/bin/bash

export UNSEAL_KEY=$(kubectl logs vault-0 | grep Unseal | cut -d':' -f2 | tr -d ' ')

kubectl exec -it git-vault-cli -- /bin/bash -c "
  export VAULT_ADDR="http://vault:8200"
  vault operator unseal $UNSEAL_KEY
  vault login root
  vault secrets enable pki

  vault write pki/root/generate/internal \
    common_name="example.com" \
    ttl=8760h

  vault read -field=certificate pki/cert/ca > root-cert.pem

  vault write pki/config/urls \
    issuing_certificates="http://vault:8200/v1/pki/ca" \
    crl_distribution_points="http://vault/v1/pki/crl"

  vault write pki/roles/git-client \
    allowed_domains="example.com" \
    allow_subdomains=true \
    max_ttl="72h"

  vault write -format=json pki/issue/git-client common_name="git-user.example.com" ttl="24h" > cert.json

  jq -r .data.certificate < cert.json > git-cert.pem
  jq -r .data.private_key < cert.json > git-key.pem

  openssl pkcs12 -export -in git-cert.pem -inkey git-key.pem -out git-identity.p12 -name "Git Signing Key" -passout pass:
"
