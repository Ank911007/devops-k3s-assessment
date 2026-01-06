# devops-k3s-assessment
This repository contains my solution for the Infrastructure DevOps Intern Assessment.
The goal of this task was to set up and manage a small production-like infrastructure on Hetzner Cloud, deploy an application on Kubernetes, debug failures, and explain decisions clearly.

Environment Used
OS: Ubuntu 24.04
Container Runtime: Docker
Kubernetes: k3s (single node)
Package Manager: Helm v3
Application: Open WebUI

Part 1: VM & Kubernetes Setup
Docker Installation
docker was installed to run containers and support Kubernetes workloads.

Commands used:
Add Docker's official GPG key:

sudo apt update
sudo apt upgrade -y
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

Add the repository to Apt sources:

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl status docker
docker version
docker ps
docker images

k3s Installation

k3s was used because it is lightweight, easy to manage, and suitable for early-stage startups.

Command:
curl -sfL https://get.k3s.io | sh -     #Official install command
mkdir -p ~/.kube    #Create .kube directory
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config   #Copy kubeconfig
sudo chown $(id -u):$(id -g) ~/.kube/config   #Fix permissions
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
source ~/.bashrc      #Export KUBECONFIG
systemctl status k3s    #Verify k3s Service
kubectl get pods -A   #Check Cluster Components
kubectl get nodes -o wide   #Confirm Single-Node Setup

Part 2: Application Deployment (Helm)
Helm Installation
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash 

Verify Helm Installation
helm version

Add Open WebUI Helm Repository
helm repo add open-webui https://helm.openwebui.com/

Update Helm Repository Index
helm repo update

Create Namespace
kubectl create namespace openwebui

Dry-Run Helm Installation
helm install webui open-webui/open-webui \
  --namespace openwebui \
  --set service.type=ClusterIP \
  --dry-run

  Install Open WebUI
  helm install webui open-webui/open-webui \
  --namespace openwebui \
  --set service.type=ClusterIP

  Validation:
  kubectl get all -n openwebui


Part 3: OIDC Authentication Setup
OIDC configuration was applied using a Helm values file.

values-oidc.yaml
oidc:
  clientId: "test"
  clientSecret: ""
  issuer: "https://<YOUR_DOMAIN>/auth/realms/hyperplane/.well-known/openid-configuration"
  scopes:
    - openid
    - profile
    - email

Apply configuration:
helm upgrade webui open-webui/open-webui \
  --namespace openwebui \
  --values helm/values-oidc.yaml


Debugging
Issue Observed
After enabling OIDC, the application pod failed to start and entered CrashLoopBackOff.
How I Debugged
kubectl get pods -n openwebui
kubectl describe pod <pod-name> -n openwebui
kubectl logs <pod-name> -n openwebui


Root Cause
The OIDC provider was using a self-signed TLS certificate, which the application container did not trust.

Fix
The correct solution is to:
Add the custom CA certificate as a Kubernetes Secret
Mount it into the application container
Update the container trust store

Why This Works
This allows secure TLS communication without disabling certificate verification.


This solution prioritizes simplicity, clarity, and production thinking while keeping costs and complexity low — suitable for an early-stage startup.
