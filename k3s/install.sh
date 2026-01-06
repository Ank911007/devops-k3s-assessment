# k3s/install.sh
#!/bin/bash

echo "Installing k3s..."
sudo apt update && sudo apt upgrade -y
curl -sfL https://get.k3s.io | sh -
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
source ~/.bashrc

echo "k3s installation completed"
sudo systemctl status k3s
kubectl get nodes
kubectl get pods -A
