#!/bin/bash

# Source the ROOT_TOKEN
source .env
ROOT_TOKEN=$(echo "$ROOT_TOKEN" | tr -d '[:space:]')

kubectl exec -it git-vault-cli -- /bin/bash -c "
  export VAULT_ADDR="http://vault:8200"
  export ROOT_TOKEN=\"$ROOT_TOKEN\"
  
  vault login $ROOT_TOKEN
  
  export VAULT_SIGN_PATH=gpg/sign/test/sha2-256
  export VAULT_VERIFY_PATH=gpg/verify/test

  mkdir test && cd test
  git init
  touch test
  git add test
  git commit -S -m "signed"
  git log --show-signature
"
