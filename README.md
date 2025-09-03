# Lesson 7 - Kubernetes with Helm

## Prerequisites
- AWS CLI configured with default profile in `~/.aws/config` and `~/.aws/credentials`
- kubectl, Helm, Docker
- Terraform >= 1.5
- (Ingress) A running Ingress Controller in the cluster (e.g. nginx) and DNS pointing to the controller's public address
- (TLS) cert-manager installed in the cluster

## Deploy infrastructure
```bash
terraform init -upgrade
terraform apply
