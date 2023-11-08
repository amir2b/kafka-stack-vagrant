#!/usr/bin/env bash

## Environments
NODE_COUNT=${NODE_COUNT:-1}
NODE_PREFIX_IP=${NODE_PREFIX_IP:-192.168.56.1}

export DEBIAN_FRONTEND=noninteractive

set -e

# sudo apt install -y needrestart
sudo sed -Ei "s/^#?(\\\$nrconf\{restart\}) =.*/\1 = 'a';/" /etc/needrestart/needrestart.conf
sudo needrestart -u NeedRestart::UI::stdio -r a

## Update repositories
sudo apt-get update -y
# sudo apt-get upgrade -y
# sudo apt-get autoremove -y

## Add hosts
sudo sed -i "/kafka/d" /etc/hosts
for i in $(seq $NODE_COUNT); do
    echo -e "$NODE_PREFIX_IP$i\tkafka$i" | sudo tee -a /etc/hosts
done

## Config firewall
sudo sed -Ei "s/^(IPV6)=.*/\1=no/" /etc/default/ufw
sudo ufw allow OpenSSH
sudo ufw disable && sudo ufw --force enable
