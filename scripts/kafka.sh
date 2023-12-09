#!/usr/bin/env bash

## Environments
INSTALATION_PATH="/vagrant"
KAFKA_VERSION=${KAFKA_VERSION:-3.6.0}
KAFKA_ID=${KAFKA_ID:-1}
KAFKA_CONTROLLER=${KAFKA_CONTROLLER:-1@192.168.56.11:9093}
IP=${IP:-192.168.56.11}

export DEBIAN_FRONTEND=noninteractive

set -e

## Install java
sudo apt-get install -y default-jre

## Create kafka user
sudo adduser --group --system --no-create-home --home /var/lib/kafka kafka

## Download kafka if not exists
if [ ! -f "$INSTALATION_PATH/cache/kafka_2.13-${KAFKA_VERSION}.tgz" ]; then
    # wget https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz -P "$INSTALATION_PATH/cache/"
    wget https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz -P "$INSTALATION_PATH/cache/"
fi

## Copy kafka to /opt/
sudo tar -xzf "$INSTALATION_PATH/cache/kafka_2.13-${KAFKA_VERSION}.tgz" -C /opt/
sudo ln -s "kafka_2.13-${KAFKA_VERSION}" /opt/kafka
# sudo chown root:root /opt/kafka/ -R

## Create lib and log directory
sudo mkdir /var/{lib,log}/kafka
sudo chown kafka:kafka /var/{lib,log}/kafka/

## Configuration
sudo sed -Ei "s;^(listeners)=.*;\1=SASL_PLAINTEXT://:9092,CONTROLLER://:9093;" /opt/kafka/config/kraft/server.properties
sudo sed -Ei "s;^(advertised\.listeners)=.*;\1=SASL_PLAINTEXT://${IP}:9092;" /opt/kafka/config/kraft/server.properties
sudo sed -Ei "s/^(inter\.broker\.listener\.name)=.*/\1=SASL_PLAINTEXT/" /opt/kafka/config/kraft/server.properties
sudo sed -Ei "s/^(listener\.security\.protocol\.map)=.*/\1=SASL_PLAINTEXT:SASL_PLAINTEXT,CONTROLLER:SASL_PLAINTEXT/" /opt/kafka/config/kraft/server.properties
sudo sed -Ei "s;^(log\.dirs)=.*;\1=/var/lib/kafka;" /opt/kafka/config/kraft/server.properties
sudo sed -Ei "s/^(node\.id)=.*/\1=${KAFKA_ID}/" /opt/kafka/config/kraft/server.properties
sudo sed -Ei "s/^(controller\.quorum\.voters)=.*/\1=${KAFKA_CONTROLLER}/" /opt/kafka/config/kraft/server.properties
sudo sed -Ei "s/^#(log\.retention\.bytes)=.*/\1=10737418240/" /opt/kafka/config/kraft/server.properties
{
    echo
    echo "security.protocol=SASL_PLAINTEXT"
    echo "sasl.enabled.mechanisms=PLAIN"
    echo "sasl.mechanism.controller.protocol=PLAIN"
    echo "sasl.mechanism.inter.broker.protocol=PLAIN"
    echo
    # https://docs.confluent.io/platform/current/kafka/authorization.html
    echo "authorizer.class.name=org.apache.kafka.metadata.authorizer.StandardAuthorizer"
    # echo "allow.everyone.if.no.acl.found=false"
    echo "super.users=User:admin"
    echo
    # https://developer.ibm.com/articles/benefits-compression-kafka-messaging/
    echo "compression.type=gzip"
    echo
    echo "#auto.create.topics.enable=false"
} | sudo tee -a /opt/kafka/config/kraft/server.properties
sudo cp "$INSTALATION_PATH/configs/admin.conf" /opt/kafka/config/
sudo cp "$INSTALATION_PATH/configs/kafka-jaas.conf" /opt/kafka/config/

## Generate UUID
if [ ! -f "$INSTALATION_PATH/cache/kafka-uuid" ]; then
    /opt/kafka/bin/kafka-storage.sh random-uuid | sudo tee "$INSTALATION_PATH/cache/kafka-uuid"
fi
cp "$INSTALATION_PATH/cache/kafka-uuid" /opt/kafka/config/kraft/uuid
sudo -u kafka /opt/kafka/bin/kafka-storage.sh format -t $(cat /opt/kafka/config/kraft/uuid) -c /opt/kafka/config/kraft/server.properties

## Firewall
sudo cp "$INSTALATION_PATH/configs/ufw/kafka" /etc/ufw/applications.d/
sudo ufw allow kafka
sudo ufw allow kafka-jmx

# sudo firewall-cmd --permanent --add-port=9092/tcp
# sudo firewall-cmd --permanent --add-port=9093/tcp
# sudo firewall-cmd --permanent --add-port=9099/tcp
# sudo firewall-cmd --reload
# sudo firewall-cmd --list-all

## systemd
sudo cp "$INSTALATION_PATH/configs/systemd/kafka.service" /lib/systemd/system/
sudo sed -i "s/127\.0\.0\.1/$IP/" /lib/systemd/system/kafka.service
sudo systemctl daemon-reload
sudo systemctl enable --now kafka
# sudo systemctl status kafka
# sudo systemctl restart kafka
# sudo journalctl -f -u kafka
