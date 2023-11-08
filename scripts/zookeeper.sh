#!/usr/bin/env bash

## Environments
ZOOKEEPER_VERSION=${ZOOKEEPER_VERSION:-3.9.0}
ZOOKEEPER_ID=${ZOOKEEPER_ID:-1}

export DEBIAN_FRONTEND=noninteractive

set -e

## Install java
sudo apt install -y default-jre

## Create zookeeper user
sudo adduser --group --system --no-create-home --home /var/lib/zookeeper zookeeper

## Download zookeeper if not exists
if [ ! -f "/vagrant/cache/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" ]; then
    wget -P /vagrant/cache/ https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz
fi

## Copy zookeeper to /opt/
sudo tar -xzf "/vagrant/cache/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" -C /opt/
sudo ln -s "/opt/apache-zookeeper-${ZOOKEEPER_VERSION}-bin" /opt/zookeeper
# sudo chown root:root /opt/zookeeper/ -R

## Create lib and log directory
sudo mkdir /var/{lib,log}/zookeeper
sudo chown zookeeper:zookeeper /var/{lib,log}/zookeeper/

## Config
sudo cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg
sudo sed -Ei 's/(initLimit)=.*/\1=5/' /opt/zookeeper/conf/zoo.cfg
sudo sed -Ei 's/(syncLimit)=.*/\1=2/' /opt/zookeeper/conf/zoo.cfg
sudo sed -Ei 's,(dataDir)=.*,\1=/var/lib/zookeeper,' /opt/zookeeper/conf/zoo.cfg
{
    echo 'server.1=192.168.56.11:2888:3888' 
    echo 'server.2=192.168.56.12:2888:3888'
    echo 'server.3=192.168.56.13:2888:3888'
} | sudo tee -a /opt/zookeeper/conf/zoo.cfg
echo 'ZOO_LOG_DIR="/var/log/zookeeper"' | sudo tee /opt/zookeeper/conf/zookeeper-env.sh
echo $ZOOKEEPER_ID | sudo -u zookeeper tee /var/lib/zookeeper/myid
# sudo chown zookeeper:zookeeper /var/lib/zookeeper/myid

## Firewall
sudo ufw allow 2181/tcp comment Zookeeper

## systemd
sudo cp /vagrant/configs/systemd/zookeeper.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now zookeeper
# sudo systemctl status zookeeper
# sudo systemctl restart zookeeper
