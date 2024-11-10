#!/bin/sh

init_output=$(vault operator init -key-shares=5 -key-threshold=3)
initial_root_token=$(echo "$init_output" | grep 'Initial Root Token:' | awk '{print $NF}')
export VAULT_TOKEN=$initial_root_token
echo "VAULT_TOKEN: $initial_root_token"
unseal_key_1=$(echo "$init_output" | grep 'Unseal Key 1:' | awk '{print $NF}')
unseal_key_2=$(echo "$init_output" | grep 'Unseal Key 2:' | awk '{print $NF}')
unseal_key_3=$(echo "$init_output" | grep 'Unseal Key 3:' | awk '{print $NF}')
vault operator unseal "$unseal_key_1"
vault operator unseal "$unseal_key_2"
vault operator unseal "$unseal_key_3"
echo "Vault has been unsealed successfully!"
