#!/usr/bin/env bash
#
# https://docs.docker.com/engine/install/ubuntu/

## Environments
INSTALATION_PATH="/vagrant"

export DEBIAN_FRONTEND=noninteractive

set -e

## Add Shecan
sudo sed -i "1inameserver 178.22.122.100" /etc/resolv.conf

# Add Docker's official GPG key:
# sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## Remove Shecan
sudo sed -i '1d' /etc/resolv.conf

# Add the registry-mirrors:
echo -e '{\n\t"registry-mirrors": ["https://registry.docker.ir", "https://docker.arvancloud.com", "https://docker.iranrepo.ir", "https://dockerhub.ir", "https://m.docker-registry.ir", "https://docker.iranserver.com"]\n}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
