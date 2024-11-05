.PHONY: all
all: up vault build

.PHONY: up
up:
	kind create cluster --name git-signing-cluster

.PHONY: down
down:
	kind delete cluster --name git-signing-cluster

.PHONY: vault
vault:
	helm install vault hashicorp/vault --set "server.dev.enabled=true"

.PHONY: build
build:
	docker build -t git-vault-test-container:v1 .
	kind load docker-image git-vault-test-container:v1 --name git-signing-cluster
	sleep 5
	kubectl apply -f helper.yaml
