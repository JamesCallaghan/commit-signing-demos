# Git Commit Signing Demos

## Introduction

This repo contains demos of commit signing using S/MIME and a [vault-gpg-plugin](https://github.com/LeSuisse/vault-gpg-plugin).

## S/MIME commit signing example

### Demo

Spin up a kind cluster with Vault to provide X.509s and a test container to verify that we can sign commits with certs:

```bash
make dev
```

Wait until all pods are running, and then set up Vault, pressing return when prompted, to enter an empty passphrase:

```bash
./vault-setup.sh
./import-keys.sh
```

Exec into the test container:

```bash
kubectl exec -it git-vault-cli -- /bin/bash
```

Run the following in the test container shell:

```bash
echo disable-crl-checks >> ~/.gnupg/gpgsm.conf
echo allow-mark-trusted >> ~/.gnupg/gpg-agent.conf

export FINGERPRINT=$(gpgsm --list-keys | grep fingerprint | head -n 1 | sed 's/.*fingerprint: //' | tr -d ' :')
export ROOT_ID=$(gpgsm --list-keys | egrep '(key usage|ID)' | grep -B 1 certSign | awk '/ID/ {print $2}')
echo "$FINGERPRINT S" >> ~/.gnupg/trustlist.txt
gpgconf --reload gpgsm
gpgsm --list-keys --with-validation $ROOT_ID

git config --global user.email "git-user@example.com"
git config --global user.name "git-user.example.com"
export signingkey=$( gpgsm --list-secret-keys | egrep '(key usage|ID)' | grep -B 1 digitalSignature | awk '/ID/ {print $2}' )
git config --global user.signingkey $signingkey
git config --global gpg.format x509
git config --global gpg.x509.program /usr/bin/gpgsm
```

Create a new directory, initialise a git repository, and sign a commit:

```bash
mkdir test && cd test
git init
touch test
git add test
git commit -S -m "signed"
```

View the signed commit:

```bash
git log --show-signature
```

### Teardown

Exit the test container shell and run:

```bash
make down
```

## Signing plugin example

### Demo run

This example uses [vaultsign](https://github.com/martinbaillie/vaultsign) and [vault-gpg-plugin](https://github.com/LeSuisse/vault-gpg-plugin)

Start an instance of Vault and the test container:

```bash
make plugin
```

When the Vault pod is Running, initialise Vault:

```bash
make initialise
```

Export the root token:

```bash
export ROOT_TOKEN=...
```

Run the following command 3 times, each time inputting a different unseal key:

```bash
make unseal
```

The Vault pod should now show as Ready:

```bash
kubectl get po
```

Register the Vault GPG plugin and create a test user key:

```bash
./plugin-setup.sh
```

Test a signed commit:

```bash
./sign-with-plugin.sh
```

### Demo Teardown

Exit the test container shell and run:

```bash
make down
```
