#!/bin/bash

# Source the ROOT_TOKEN
source .env
ROOT_TOKEN=$(echo "$ROOT_TOKEN" | tr -d '[:space:]')

kubectl exec -it git-vault-cli -- /bin/bash -c "
  export VAULT_ADDR=\"http://vault:8200\"
  export ROOT_TOKEN=\"$ROOT_TOKEN\"
  
  vault login \$ROOT_TOKEN
  vault plugin register -sha256=214bc51c41ab7ab71d874f8b075f17dacaa57b52ef06a9e06f59fc4b6829e630 secret vault-gpg-plugin
  vault secrets enable -path=gpg -plugin-name=vault-gpg-plugin plugin
  wget https://github.com/martinbaillie/vaultsign/releases/download/v1.0.0/vaultsign-linux-amd64
  chmod +x vaultsign-linux-amd64
  git config --global user.email \"git-user@example.com\"
  git config --global user.name \"git-user\"
  git config --global gpg.program /vaultsign-linux-amd64

  # Use printf to debug the token if needed
  printf 'Using ROOT_TOKEN: %s\n' \"\$ROOT_TOKEN\"

  curl -X POST --header \"X-Vault-Token: \$ROOT_TOKEN\" -d '{\"real_name\":\"git-user\",\"email\":\"git-user@example.com\",\"key_bits\":4096,\"generate\":true}' \"http://vault:8200/v1/gpg/keys/test\"
"

