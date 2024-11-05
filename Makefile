.PHONY: dev
dev: up vault-dev build-test-container

.PHONY: plugin
plugin: up plugin-build build-test-container vault-plugin

.PHONY: up
up:
	kind create cluster --name git-signing-cluster

.PHONY: down
down:
	kind delete cluster --name git-signing-cluster

.PHONY: vault-dev
vault-dev:
	helm install vault hashicorp/vault --set "server.dev.enabled=true"

.PHONY: vault-plugin
vault-plugin:
	helm install vault hashicorp/vault -f values.yaml

.PHONY: build-test-container
build-test-container:
	docker build -t git-vault-test-container:v1 .
	kind load docker-image git-vault-test-container:v1 --name git-signing-cluster
	sleep 5
	kubectl apply -f helper.yaml

.PHONY: plugin-build
plugin-build:
	docker build -t vault-gpg-plugin:latest gpg-plugin
	kind load docker-image vault-gpg-plugin:latest --name git-signing-cluster

.PHONY: initialise
initialise:
	kubectl exec -it vault-0 -- vault operator init

.PHONY: unseal
unseal:
	kubectl exec -it vault-0 -- vault operator unseal


