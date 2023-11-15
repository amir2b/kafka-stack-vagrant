#!/usr/bin/env bash

## Environments
INSTALATION_PATH="/vagrant"
IP=${IP:-192.168.56.11}
CONNECT_DEBEZIUM_VERSION=${CONNECT_DEBEZIUM_VERSION:-2.3.2}
CONNECT_MYSQL_VERSION=${CONNECT_MYSQL_VERSION:-8.0.33}
CONNECT_JDBC_VERSION=${CONNECT_JDBC_VERSION:-10.7.4}
KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS:-localhost:9092}
CONNECT_KAFKA_USERNAME=${CONNECT_KAFKA_USERNAME:-cdc}
CONNECT_KAFKA_PASSWORD=${CONNECT_KAFKA_PASSWORD:-password}

export DEBIAN_FRONTEND=noninteractive

set -e

sudo apt-get install -y unzip
# sudo yum install -y unzip

## Create connectors directory
sudo mkdir /opt/kafka/{connect,connectors}

## Config
# ToDo: listeners on all interfaces
sudo sed -Ei "s/^(bootstrap\.servers)=.*/\1=${KAFKA_BOOTSTRAP_SERVERS}/" /opt/kafka/config/connect-distributed.properties
sudo sed -Ei "s;^#(rest\.advertised\.host\.name)=.*;\1=${IP};" /opt/kafka/config/connect-distributed.properties
sudo sed -Ei "s;^#(rest\.advertised\.port)=.*;\1=8083;" /opt/kafka/config/connect-distributed.properties
sudo sed -Ei "s;^#(plugin\.path)=.*;\1=/opt/kafka/connect;" /opt/kafka/config/connect-distributed.properties
# sudo sed -Ei "s;^#(offset\.storage\.replication\.factor)=.*;\1=3;" /opt/kafka/config/connect-distributed.properties
# sudo sed -Ei "s;^#(offset\.storage\.partitions)=.*;\1=15;" /opt/kafka/config/connect-distributed.properties
# sudo sed -Ei "s;^#(config\.storage\.replication\.factor)=.*;\1=3;" /opt/kafka/config/connect-distributed.properties
# sudo sed -Ei "s;^#(status\.storage\.replication\.factor)=.*;\1=3;" /opt/kafka/config/connect-distributed.properties
# sudo sed -Ei "s;^#(status\.storage\.partitions)=.*;\1=6;" /opt/kafka/config/connect-distributed.properties
{
    echo
    echo "#rest.extension.classes=org.apache.kafka.connect.rest.basic.auth.extension.BasicAuthSecurityRestExtension"
    echo
    echo "security.protocol=SASL_PLAINTEXT"
    echo "sasl.mechanism=PLAIN"
    echo "sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="${CONNECT_KAFKA_USERNAME}" password="${CONNECT_KAFKA_PASSWORD}";"
    echo
    echo "producer.security.protocol=SASL_PLAINTEXT"
    echo "producer.sasl.mechanism=PLAIN"
    echo "producer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="${CONNECT_KAFKA_USERNAME}" password="${CONNECT_KAFKA_PASSWORD}";"
    echo
    echo "consumer.security.protocol=SASL_PLAINTEXT"
    echo "consumer.sasl.mechanism=PLAIN"
    echo "consumer.sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="${CONNECT_KAFKA_USERNAME}" password="${CONNECT_KAFKA_PASSWORD}";"

} | sudo tee -a /opt/kafka/config/connect-distributed.properties

echo "user: password" | sudo tee /opt/kafka/config/connect.password

## Download debezium-connector-mysql
if [ ! -f "$INSTALATION_PATH/cache/debezium-connector-mysql-${CONNECT_DEBEZIUM_VERSION}.Final-plugin.tar.gz" ]; then
    wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/${CONNECT_DEBEZIUM_VERSION}.Final/debezium-connector-mysql-${CONNECT_DEBEZIUM_VERSION}.Final-plugin.tar.gz -P $INSTALATION_PATH/cache/
fi
sudo tar -xzf "$INSTALATION_PATH/cache/debezium-connector-mysql-${CONNECT_DEBEZIUM_VERSION}.Final-plugin.tar.gz" -C /opt/kafka/connect/

# https://www.confluent.io/hub/confluentinc/kafka-connect-jdbc
sudo unzip "$INSTALATION_PATH/configs/kafka-connect-plugins/confluentinc-kafka-connect-jdbc-${CONNECT_JDBC_VERSION}.zip" -d /opt/kafka/connect/

## https://dev.mysql.com/downloads/connector/j/
sudo cp "$INSTALATION_PATH/configs/kafka-connect-plugins/mysql-connector-j-${CONNECT_MYSQL_VERSION}.jar" /opt/kafka/connect/

## Add ACL to kakfa
/opt/kafka/bin/kafka-acls.sh --bootstrap-server localhost:9092 --command-config /opt/kafka/config/admin.conf --add --allow-principal User:cdc --producer --consumer --topic '*' --group connect-cluster

## Firewall
sudo cp "$INSTALATION_PATH/configs/ufw/kafka" /etc/ufw/applications.d/
sudo ufw allow kafka-connect

# sudo firewall-cmd --permanent --add-port=8083/tcp
# sudo firewall-cmd --reload
# sudo firewall-cmd --list-all

## systemd
sudo cp $INSTALATION_PATH/configs/systemd/kafka-connect.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now kafka-connect
# sudo systemctl status kafka-connect
# sudo systemctl restart kafka-connect
# sudo journalctl -f -u kafka-connect
