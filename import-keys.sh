#!/bin/bash

kubectl exec -it git-vault-cli -- /bin/bash -c "
  gpgsm --import root-cert.pem
  gpgsm --batch --pinentry-mode loopback --import git-identity.p12
"
