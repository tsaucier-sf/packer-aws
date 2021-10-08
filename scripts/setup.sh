#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"

sudo apt update
sudo apt upgrade -y
sudo apt install -y \
  jq \
  git \
  curl \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release

## install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io
sudo usermod -aG docker $USER

## microk8s
sudo snap install microk8s --classic
sudo ufw allow in on cni0 && sudo ufw allow out on cni0
sudo ufw default allow routed
