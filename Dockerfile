FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    gnupg \
    jq \
    ca-certificates && \
    curl -Lo /tmp/vault.zip https://releases.hashicorp.com/vault/1.18.0/vault_1.18.0_linux_amd64.zip && \
    unzip /tmp/vault.zip -d /usr/local/bin/ && \
    rm /tmp/vault.zip && \
    chmod +x /usr/local/bin/vault && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV VAULT_ADDR="http://127.0.0.1:8200"

ENTRYPOINT ["/bin/bash"]
